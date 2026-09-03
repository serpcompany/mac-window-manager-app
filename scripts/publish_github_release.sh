#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/publish_github_release.sh SEMVER RELEASE_COMMIT --dmg PATH [--app-store-version VERSION] [--notes-file PATH] [--confirm]

Preflight a submitted Mac App Store version, then create its annotated Git tag
and matching GitHub prerelease. Once Apple releases the version, the same
command promotes the prerelease. Remote mutation occurs only with --confirm.
EOF
}

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 2
fi

version="$1"
release_commit="$2"
shift 2

notes_file=""
dmg_path=""
app_store_version="$version"
confirm="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dmg)
      if [[ $# -lt 2 ]]; then
        echo "--dmg requires a path" >&2
        exit 2
      fi
      dmg_path="$2"
      shift 2
      ;;
    --app-store-version)
      if [[ $# -lt 2 ]]; then
        echo "--app-store-version requires a version" >&2
        exit 2
      fi
      app_store_version="$2"
      shift 2
      ;;
    --notes-file)
      if [[ $# -lt 2 ]]; then
        echo "--notes-file requires a path" >&2
        exit 2
      fi
      notes_file="$2"
      shift 2
      ;;
    --confirm)
      confirm="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "SEMVER must be MAJOR.MINOR.PATCH" >&2
  exit 2
fi
if [[ ! "$app_store_version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "App Store version must contain two or three numeric components" >&2
  exit 2
fi

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

expected_repo="serpcompany/mac-window-manager-app"
app_id="6808371833"
tag="v$version"

for command_name in asc gh git jq; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
done

if [[ -n "$notes_file" && ! -f "$notes_file" ]]; then
  echo "Release notes file does not exist: $notes_file" >&2
  exit 2
fi
if [[ -z "$dmg_path" || ! -f "$dmg_path" ]]; then
  echo "A release DMG is required via --dmg" >&2
  exit 2
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree must be clean before publishing a release" >&2
  exit 1
fi

origin_url=$(git remote get-url origin)
case "$origin_url" in
  "https://github.com/$expected_repo"|"https://github.com/$expected_repo.git"|"git@github.com:$expected_repo"|"git@github.com:$expected_repo.git") ;;
  *)
    echo "Expected origin for $expected_repo, got $origin_url" >&2
    exit 1
    ;;
esac
gh repo view "$expected_repo" --json nameWithOwner --jq .nameWithOwner >/dev/null

git fetch origin --prune --tags

if ! git merge-base --is-ancestor "$release_commit" origin/main; then
  echo "Release commit must be contained in origin/main: $release_commit" >&2
  exit 1
fi
release_commit=$(git rev-parse "$release_commit^{commit}")

project_file=$(git show "$release_commit:Rectangle.xcodeproj/project.pbxproj")
project_versions=$(printf '%s\n' "$project_file" | sed -n 's/.*MARKETING_VERSION = \([^;]*\);/\1/p' | sort -u)
if [[ "$project_versions" != "$app_store_version" && "$project_versions" != "$version" ]]; then
  echo "Release commit marketing version is '$project_versions', expected '$app_store_version' or '$version'" >&2
  exit 1
fi

"$repo_root/scripts/verify_github_dmg.sh" "$version" "$dmg_path"
asset_name=$(basename "$dmg_path")

version_json=$(asc versions list --app "$app_id" --version "$app_store_version" --platform MAC_OS --output json)
version_count=$(printf '%s' "$version_json" | jq '.data | length')
if [[ "$version_count" != "1" ]]; then
  echo "Expected one App Store version $app_store_version; found $version_count" >&2
  exit 1
fi
app_store_state=$(printf '%s' "$version_json" | jq -r '.data[0].attributes.appStoreState')
case "$app_store_state" in
  READY_FOR_DISTRIBUTION|READY_FOR_SALE)
    release_kind="full"
    ;;
  WAITING_FOR_REVIEW|IN_REVIEW|PENDING_DEVELOPER_RELEASE|PENDING_APPLE_RELEASE|PROCESSING_FOR_DISTRIBUTION)
    release_kind="prerelease"
    ;;
  *)
    echo "App Store version $app_store_version is $app_store_state; it is neither under review nor released" >&2
    exit 1
    ;;
esac

tag_exists="false"
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  tag_exists="true"
  tag_commit=$(git rev-parse "$tag^{commit}")
  if [[ "$tag_commit" != "$release_commit" ]]; then
    echo "Existing tag $tag points to $tag_commit, expected $release_commit" >&2
    exit 1
  fi
  if [[ "$(git cat-file -t "$tag")" != "tag" ]]; then
    echo "Existing tag $tag is lightweight; an annotated release tag is required" >&2
    exit 1
  fi
fi

remote_tag_exists="false"
if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null 2>&1; then
  remote_tag_exists="true"
fi

release_json=""
if release_json=$(gh release view "$tag" --repo "$expected_repo" --json url,isDraft,isPrerelease,tagName,assets 2>/dev/null); then
  if [[ "$(printf '%s' "$release_json" | jq -r '.isDraft')" != "false" ]]; then
    echo "GitHub Release for $tag exists as a draft" >&2
    exit 1
  fi
  is_prerelease=$(printf '%s' "$release_json" | jq -r '.isPrerelease')
  release_url=$(printf '%s' "$release_json" | jq -r .url)
  asset_exists=$(printf '%s' "$release_json" | jq -r --arg name "$asset_name" 'any(.assets[]; .name == $name)')
  needs_promotion="false"
  if [[ "$release_kind" == "full" && "$is_prerelease" == "true" ]]; then
    needs_promotion="true"
  fi
  if [[ "$asset_exists" == "true" && "$needs_promotion" == "false" ]]; then
    echo "GitHub Release already exists: $release_url"
    exit 0
  fi

  echo "Release update preflight passed"
  echo "  App Store version: $app_store_version ($app_store_state)"
  echo "  Commit: $release_commit"
  echo "  Tag: $tag"
  echo "  DMG: $dmg_path"
  echo "  Upload DMG: $([[ "$asset_exists" == "true" ]] && echo no || echo yes)"
  echo "  Promote prerelease: $needs_promotion"
  echo "  GitHub release: $release_url"
  if [[ "$confirm" != "true" ]]; then
    echo "Dry run only. Re-run with --confirm to update the GitHub Release."
    exit 0
  fi

  if [[ "$asset_exists" != "true" ]]; then
    gh release upload "$tag" "$dmg_path#Window Manager $version (DMG)" --repo "$expected_repo"
  fi
  if [[ "$needs_promotion" == "true" ]]; then
    gh release edit "$tag" --repo "$expected_repo" --prerelease=false --latest
  fi
  release_json=$(gh release view "$tag" --repo "$expected_repo" --json url,isDraft,isPrerelease,tagName,targetCommitish)
  actual_kind=$(printf '%s' "$release_json" | jq -r 'if .isPrerelease then "prerelease" else "full" end')
  expected_kind="$release_kind"
  if [[ "$is_prerelease" == "false" ]]; then
    expected_kind="full"
  fi
  if [[ "$(printf '%s' "$release_json" | jq -r '.isDraft')" != "false" || "$actual_kind" != "$expected_kind" ]]; then
    echo "Updated GitHub Release does not match expected kind $expected_kind" >&2
    exit 1
  fi
  printf '%s\n' "$release_json"
  exit 0
fi

echo "Release preflight passed"
echo "  App Store version: $app_store_version ($app_store_state)"
echo "  Commit: $release_commit"
echo "  Tag: $tag"
echo "  DMG: $dmg_path"
echo "  GitHub release kind: $release_kind"
echo "  GitHub repository: $expected_repo"

if [[ "$confirm" != "true" ]]; then
  echo "Dry run only. Re-run with --confirm to create the tag and GitHub Release."
  exit 0
fi

if [[ "$tag_exists" != "true" ]]; then
  git tag -a "$tag" "$release_commit" -m "Window Manager $version"
fi
if [[ "$remote_tag_exists" != "true" ]]; then
  git push origin "refs/tags/$tag"
fi

release_args=("$tag" "$dmg_path#Window Manager $version (DMG)" --repo "$expected_repo" --verify-tag --title "Window Manager $version")
if [[ "$release_kind" == "prerelease" ]]; then
  release_args+=(--prerelease --latest=false)
else
  release_args+=(--latest)
fi
if [[ -n "$notes_file" ]]; then
  release_args+=(--notes-file "$notes_file")
else
  release_args+=(--generate-notes)
fi

gh release create "${release_args[@]}"
release_json=$(gh release view "$tag" --repo "$expected_repo" --json url,isDraft,isPrerelease,tagName,targetCommitish)
actual_kind=$(printf '%s' "$release_json" | jq -r 'if .isPrerelease then "prerelease" else "full" end')
if [[ "$(printf '%s' "$release_json" | jq -r '.isDraft')" != "false" || "$actual_kind" != "$release_kind" ]]; then
  echo "Created GitHub Release does not match expected kind $release_kind" >&2
  exit 1
fi
printf '%s\n' "$release_json"
