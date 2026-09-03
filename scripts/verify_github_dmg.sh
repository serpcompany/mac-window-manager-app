#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: scripts/verify_github_dmg.sh SEMVER DMG_PATH" >&2
  exit 2
fi

version="$1"
dmg_path="$2"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "SEMVER must be MAJOR.MINOR.PATCH" >&2
  exit 2
fi
if [[ ! -f "$dmg_path" ]]; then
  echo "Missing DMG: $dmg_path" >&2
  exit 2
fi

mount_dir=$(mktemp -d /tmp/window-manager-dmg-mount.XXXXXX)
cleanup() {
  if mount | grep -Fq " on $mount_dir "; then
    hdiutil detach "$mount_dir" >/dev/null
  fi
  rmdir "$mount_dir" 2>/dev/null || true
}
trap cleanup EXIT

xcrun stapler validate "$dmg_path"
spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg_path"
hdiutil attach "$dmg_path" -nobrowse -readonly -mountpoint "$mount_dir" >/dev/null

app_path="$mount_dir/Window Manager.app"
if [[ ! -d "$app_path" || ! -L "$mount_dir/Applications" ]]; then
  echo "DMG must contain Window Manager.app and an Applications symlink" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$app_path"
spctl --assess --type execute --verbose=2 "$app_path"

plist="$app_path/Contents/Info.plist"
actual_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")
actual_bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")
signature_details=$(codesign -dv --verbose=4 "$app_path" 2>&1)
team_id=$(printf '%s\n' "$signature_details" | sed -n 's/^TeamIdentifier=//p')

[[ "$actual_version" == "$version" ]]
[[ "$actual_bundle_id" == "com.serp.windowmanager" ]]
[[ "$team_id" == "847HR8U8D9" ]]
printf '%s\n' "$signature_details" | grep -q '^Authority=Developer ID Application:'
printf '%s\n' "$signature_details" | grep -q '^Timestamp='
printf '%s\n' "$signature_details" | grep -q '^Runtime Version='

executable="$app_path/Contents/MacOS/Window Manager"
file "$executable" | grep -q 'universal binary'
file "$executable" | grep -q 'arm64'
file "$executable" | grep -q 'x86_64'

if rg -a -q 'rectangleapp\.com|com\.knollsoft\.Rectangle|XSYZ3E4B7D|SUPublicEDKey|Sparkle' "$app_path"; then
  echo "Forbidden upstream identity or updater material found in DMG app" >&2
  exit 1
fi

echo "PASS: notarized Developer ID DMG contains universal Window Manager $version"
