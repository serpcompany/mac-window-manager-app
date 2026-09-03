#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
archive_path="${1:-$repo_root/build/Window Manager.xcarchive}"

if [[ -z "${APP_STORE_PROFILE_SPECIFIER:-}" || -z "${APP_STORE_LAUNCHER_PROFILE_SPECIFIER:-}" ]]; then
  echo "Set APP_STORE_PROFILE_SPECIFIER and APP_STORE_LAUNCHER_PROFILE_SPECIFIER to reviewed Mac App Store provisioning profile names." >&2
  exit 2
fi

xcodebuild clean archive \
  -project "$repo_root/Rectangle.xcodeproj" \
  -scheme Rectangle \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$archive_path" \
  DEVELOPMENT_TEAM=847HR8U8D9 \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY='Apple Distribution' \
  APP_STORE_PROFILE_SPECIFIER="$APP_STORE_PROFILE_SPECIFIER" \
  APP_STORE_LAUNCHER_PROFILE_SPECIFIER="$APP_STORE_LAUNCHER_PROFILE_SPECIFIER" \
  OTHER_CODE_SIGN_FLAGS="--timestamp"

echo "Created archive: $archive_path"
