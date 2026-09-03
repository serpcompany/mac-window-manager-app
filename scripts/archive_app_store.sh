#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
archive_path="${1:-$repo_root/build/Window Manager.xcarchive}"
export_path="${2:-$repo_root/build/AppStoreExport}"
export_options_path="${APP_STORE_EXPORT_OPTIONS_PATH:-$repo_root/config/AppStoreExportOptions.plist}"

if [[ -z "${APP_STORE_PROFILE_SPECIFIER:-}" || -z "${APP_STORE_LAUNCHER_PROFILE_SPECIFIER:-}" ]]; then
  echo "Set APP_STORE_PROFILE_SPECIFIER and APP_STORE_LAUNCHER_PROFILE_SPECIFIER to reviewed Mac App Store provisioning profile names." >&2
  exit 2
fi

if [[ ! -f "$export_options_path" ]]; then
  echo "Create $export_options_path from config/AppStoreExportOptions.plist.example with the reviewed profile names." >&2
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

xcodebuild -exportArchive \
  -archivePath "$archive_path" \
  -exportPath "$export_path" \
  -exportOptionsPlist "$export_options_path" \
  -allowProvisioningUpdates

package_path=$(find "$export_path" -maxdepth 1 -type f -name '*.pkg' -print -quit)
if [[ -z "$package_path" ]]; then
  echo "Export completed without producing a .pkg in $export_path" >&2
  exit 3
fi

echo "Created archive: $archive_path"
echo "Exported package: $package_path"
