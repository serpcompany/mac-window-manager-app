#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
source_dir="$repo_root/docs/app-replica/assets/window-manager/sources"
generated_dir="$repo_root/docs/app-replica/assets/window-manager/generated"
appicon_dir="$repo_root/Rectangle/Assets.xcassets/AppIcon.appiconset"
status_dir="$repo_root/Rectangle/Assets.xcassets/StatusTemplate.imageset"
layered_dir="$repo_root/Rectangle/AppIcon.icon/Assets"

require_hash() {
  local expected="$1"
  local path="$2"
  local actual
  actual=$(shasum -a 256 "$path" | awk '{print $1}')
  [[ "$actual" == "$expected" ]] || {
    echo "Hash mismatch for $path: expected $expected, got $actual" >&2
    exit 1
  }
}

require_hash 593a0a02a4e9abed1739dd5c6ebadf99318ed55fd9c5ad0b1c90756ea3c1acca "$source_dir/favicon.svg"
require_hash 03c94b8d0c598e93023b224695c0d86f79a3d99ff0190f1ef0b4797489d39924 "$source_dir/favicon.png"
require_hash be75f385d114ec37a8b338131721e71edf24d686afac93785dbe538bd8eec7c7 "$source_dir/serp-3000x3000.png"
require_hash 03c94b8d0c598e93023b224695c0d86f79a3d99ff0190f1ef0b4797489d39924 "$source_dir/arrow-logo-black-up.png"

mkdir -p "$generated_dir/AppIcon.iconset" "$appicon_dir" "$status_dir" "$layered_dir"

render_png() {
  local source="$1"
  local pixels="$2"
  local destination="$3"
  magick "$source" -filter Lanczos -resize "${pixels}x${pixels}!" -strip \
    -define png:exclude-chunks=date,time "$destination"
}

while IFS=' ' read -r filename pixels; do
  render_png "$source_dir/serp-3000x3000.png" "$pixels" "$appicon_dir/$filename"
done <<'SIZES'
mac016pts1x.png 16
mac016pts2x.png 32
mac032pts1x.png 32
mac032pts2x.png 64
mac128pts1x.png 128
mac128pts2x.png 256
mac256pts1x.png 256
mac256pts2x.png 512
mac512pts1x.png 512
mac512pts2x.png 1024
SIZES

cp "$appicon_dir/mac016pts1x.png" "$generated_dir/AppIcon.iconset/icon_16x16.png"
cp "$appicon_dir/mac016pts2x.png" "$generated_dir/AppIcon.iconset/icon_16x16@2x.png"
cp "$appicon_dir/mac032pts1x.png" "$generated_dir/AppIcon.iconset/icon_32x32.png"
cp "$appicon_dir/mac032pts2x.png" "$generated_dir/AppIcon.iconset/icon_32x32@2x.png"
cp "$appicon_dir/mac128pts1x.png" "$generated_dir/AppIcon.iconset/icon_128x128.png"
cp "$appicon_dir/mac128pts2x.png" "$generated_dir/AppIcon.iconset/icon_128x128@2x.png"
cp "$appicon_dir/mac256pts1x.png" "$generated_dir/AppIcon.iconset/icon_256x256.png"
cp "$appicon_dir/mac256pts2x.png" "$generated_dir/AppIcon.iconset/icon_256x256@2x.png"
cp "$appicon_dir/mac512pts1x.png" "$generated_dir/AppIcon.iconset/icon_512x512.png"
cp "$appicon_dir/mac512pts2x.png" "$generated_dir/AppIcon.iconset/icon_512x512@2x.png"
iconutil -c icns "$generated_dir/AppIcon.iconset" -o "$generated_dir/WindowManager.icns"

for scale in 1 2 3; do
  pixels=$((22 * scale))
  output="$status_dir/WindowManagerStatusTemplate${scale}x.png"
  rsvg-convert -w "$pixels" -h "$pixels" -o "$output" "$source_dir/favicon.svg"
  magick "$output" -strip -define png:exclude-chunks=date,time "$output"
done

sed 's/fill="#000000"/fill="#ffffff"/' "$source_dir/favicon.svg" > "$layered_dir/Mark.svg"

# Review sheets intentionally use fixed geometry and colors so regenerated
# output is byte-stable and useful on both light and dark appearances.
magick montage \
  "$appicon_dir/mac016pts1x.png" "$appicon_dir/mac032pts1x.png" \
  "$appicon_dir/mac128pts1x.png" "$appicon_dir/mac256pts1x.png" \
  "$appicon_dir/mac512pts1x.png" "$appicon_dir/mac512pts2x.png" \
  -thumbnail '192x192>' -tile 3x2 -geometry 208x208+8+8 -background '#f2f2f2' \
  -strip -define png:exclude-chunks=date,time "$generated_dir/app-icons-light.png"
magick montage \
  "$appicon_dir/mac016pts1x.png" "$appicon_dir/mac032pts1x.png" \
  "$appicon_dir/mac128pts1x.png" "$appicon_dir/mac256pts1x.png" \
  "$appicon_dir/mac512pts1x.png" "$appicon_dir/mac512pts2x.png" \
  -thumbnail '192x192>' -tile 3x2 -geometry 208x208+8+8 -background '#202124' \
  -strip -define png:exclude-chunks=date,time "$generated_dir/app-icons-dark.png"

for background in light dark; do
  color='#f2f2f2'
  [[ "$background" == dark ]] && color='#202124'
  magick -size 360x120 "xc:$color" \
    \( "$status_dir/WindowManagerStatusTemplate1x.png" -resize 44x44 \) -gravity West -geometry +45+0 -composite \
    \( "$status_dir/WindowManagerStatusTemplate2x.png" -resize 44x44 \) -gravity Center -composite \
    \( "$status_dir/WindowManagerStatusTemplate3x.png" -resize 44x44 \) -gravity East -geometry +45+0 -composite \
    -strip -define png:exclude-chunks=date,time "$generated_dir/status-icons-$background.png"
done

echo "Generated Window Manager brand assets."
