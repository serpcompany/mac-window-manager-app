#!/usr/bin/env bash
set -euo pipefail

app_path="${1:-/Applications/Rectangle Clone.app}"
expected_bundle_id="co.serp.rectangleclone"
expected_team_id="847HR8U8D9"

if [[ ! -d "$app_path" ]]; then
  echo "Missing app: $app_path" >&2
  exit 1
fi

plist="$app_path/Contents/Info.plist"
executable="$app_path/Contents/MacOS/Rectangle Clone"

actual_bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")
actual_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$plist")
actual_scheme=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleURLTypes:0:CFBundleURLSchemes:0' "$plist")
team_id=$(codesign -dv --verbose=4 "$app_path" 2>&1 | sed -n 's/^TeamIdentifier=//p')

[[ "$actual_bundle_id" == "$expected_bundle_id" ]]
[[ "$actual_name" == "Rectangle Clone" ]]
[[ "$actual_scheme" == "rectangleclone" ]]
[[ "$team_id" == "$expected_team_id" ]]

codesign --verify --deep --strict "$app_path"
file "$executable" | grep -q 'universal binary'
file "$executable" | grep -q 'arm64'
file "$executable" | grep -q 'x86_64'

if rg -a -q 'rectangleapp\.com|com\.knollsoft\.Rectangle|XSYZ3E4B7D|SUPublicEDKey|Sparkle' "$app_path"; then
  echo "Forbidden upstream identity or updater material found in app bundle" >&2
  exit 1
fi

echo "PASS: signed universal Rectangle Clone artifact has isolated identity"
