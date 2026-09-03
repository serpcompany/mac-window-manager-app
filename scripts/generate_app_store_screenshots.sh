#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
raw_dir="$repo_root/metadata/screenshots/raw/build2"
output_dir="$repo_root/metadata/screenshots/en-US/desktop"
icon_path="$repo_root/Rectangle/Assets.xcassets/AppIcon.appiconset/mac512pts2x.png"

if ! command -v magick >/dev/null 2>&1; then
  echo "Missing required command: magick" >&2
  exit 2
fi

for source_name in shortcuts layouts snap-areas general permission; do
  if [[ ! -f "$raw_dir/$source_name.jpeg" ]]; then
    echo "Missing raw screenshot: $raw_dir/$source_name.jpeg" >&2
    exit 2
  fi
done

mkdir -p "$output_dir"

render() {
  local source_name="$1"
  local output_name="$2"
  local title="$3"
  local subtitle="$4"

  magick \
    -size 1440x900 'gradient:#09090c-#1b1427' \
    -fill '#7c3cff' -draw 'roundrectangle 0,0 12,900 0,0' \
    \( "$icon_path" -resize 76x76 \) -gravity northwest -geometry +64+46 -composite \
    -gravity northwest -font Helvetica-Neue-Bold -pointsize 48 -fill '#ffffff' \
    -annotate +164+86 "$title" \
    -font Helvetica-Neue -pointsize 24 -fill '#c7c5cf' \
    -annotate +166+130 "$subtitle" \
    \( "$raw_dir/$source_name.jpeg" -resize '1180x610' -bordercolor '#4a4655' -border 2 \
       \( +clone -background '#000000' -shadow 55x18+0+18 \) +swap -background none -layers merge +repage \) \
    -gravity south -geometry +0+50 -composite \
    -alpha off -depth 8 -strip -colorspace sRGB "$output_dir/$output_name"
}

render shortcuts 01-shortcuts.png \
  'Put every window in its place' \
  'Custom shortcuts make halves, corners, center, and maximize instant.'

render layouts 02-layouts.png \
  'Go beyond basic split screen' \
  'Use thirds, fourths, sixths, and multi-display commands without touching the mouse.'

render snap-areas 03-snap-areas.png \
  'Drag. Snap. Done.' \
  'Drop a window at an edge or corner and see exactly where it will land.'

render general 04-workflow.png \
  'Fits the way you work' \
  'Launch at login, keep it in the menu bar, and tune your workspace behavior.'

render permission 05-private.png \
  'Local and private by design' \
  'No account, analytics, ads, or tracking. Grant one macOS permission and get to work.'

echo "Generated five App Store screenshots in $output_dir"
