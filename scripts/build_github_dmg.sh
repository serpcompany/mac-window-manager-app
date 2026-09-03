#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: scripts/build_github_dmg.sh SEMVER RELEASE_COMMIT [OUTPUT_DMG]" >&2
  exit 2
fi

version="$1"
release_commit="$2"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "SEMVER must be MAJOR.MINOR.PATCH" >&2
  exit 2
fi

repo_root=$(cd "$(dirname "$0")/.." && pwd)
output_path="${3:-$repo_root/dist/Window-Manager-$version.dmg}"
if [[ "$output_path" != /* ]]; then
  output_path="$repo_root/$output_path"
fi
if [[ -e "$output_path" ]]; then
  echo "Output already exists: $output_path" >&2
  exit 1
fi
if [[ -n "$(git -C "$repo_root" status --porcelain)" ]]; then
  echo "Working tree must be clean before building a release DMG" >&2
  exit 1
fi

git -C "$repo_root" fetch origin --prune
if ! git -C "$repo_root" merge-base --is-ancestor "$release_commit" origin/main; then
  echo "Release commit must be contained in origin/main: $release_commit" >&2
  exit 1
fi
release_commit=$(git -C "$repo_root" rev-parse "$release_commit^{commit}")

signing_identity=$(security find-identity -v -p codesigning | awk '/Developer ID Application: Matthew Schumacher \(847HR8U8D9\)/ {print $2; exit}')
if [[ -z "$signing_identity" ]]; then
  echo "No valid Developer ID Application identity for team 847HR8U8D9" >&2
  exit 1
fi

work_dir=$(mktemp -d /tmp/window-manager-release.XXXXXX)
source_dir="$work_dir/source"
cleanup() {
  if git -C "$repo_root" worktree list --porcelain | grep -Fqx "worktree $source_dir"; then
    git -C "$repo_root" worktree remove --force "$source_dir"
  fi
  case "$work_dir" in
    /tmp/window-manager-release.*) rm -rf -- "$work_dir" ;;
  esac
}
trap cleanup EXIT

git -C "$repo_root" worktree add --detach "$source_dir" "$release_commit"
archive_path="$work_dir/WindowManager.xcarchive"
app_path="$archive_path/Products/Applications/Window Manager.app"
dmg_root="$work_dir/dmg-root"
unsigned_dmg="$work_dir/Window-Manager-$version.dmg"

xcodebuild clean archive \
  -project "$source_dir/Rectangle.xcodeproj" \
  -scheme Rectangle \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$archive_path" \
  DEVELOPMENT_TEAM=847HR8U8D9 \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$signing_identity" \
  PROVISIONING_PROFILE_SPECIFIER='' \
  APP_STORE_PROFILE_SPECIFIER='' \
  APP_STORE_LAUNCHER_PROFILE_SPECIFIER='' \
  CODE_SIGN_ENTITLEMENTS='' \
  ENABLE_HARDENED_RUNTIME=YES \
  OTHER_CODE_SIGN_FLAGS='--timestamp' \
  MARKETING_VERSION="$version"

codesign --verify --deep --strict --verbose=2 "$app_path"
mkdir -p "$dmg_root"
ditto "$app_path" "$dmg_root/Window Manager.app"
ln -s /Applications "$dmg_root/Applications"
hdiutil create -volname 'Window Manager' -srcfolder "$dmg_root" -format UDZO "$unsigned_dmg"
codesign --force --timestamp --sign "$signing_identity" "$unsigned_dmg"

asc notarization submit --file "$unsigned_dmg" --wait --poll-interval 15s --timeout 1h
xcrun stapler staple "$unsigned_dmg"

mkdir -p "$(dirname "$output_path")"
ditto "$unsigned_dmg" "$output_path"
"$repo_root/scripts/verify_github_dmg.sh" "$version" "$output_path"
shasum -a 256 "$output_path"
echo "Created GitHub release installer: $output_path"
