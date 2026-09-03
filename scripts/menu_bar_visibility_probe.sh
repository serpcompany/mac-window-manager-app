#!/usr/bin/env bash
set -euo pipefail

app_path="${1:-/Applications/Rectangle Clone.app}"
bundle_token="co.serp.rectangleclone"

pkill -x 'Rectangle Clone' 2>/dev/null || true
sleep 1
open "$app_path"
sleep 3

events=$(/usr/bin/log show --last 5s --style compact \
  --predicate "process == 'ControlCenter' AND eventMessage CONTAINS[c] '$bundle_token'")

if grep -q 'Moving host to blocked list' <<<"$events"; then
  echo "RED: Control Center blocked the Rectangle Clone status item from the visible menu bar"
  exit 1
fi

if ! grep -q 'Created instance .* in .menuBar' <<<"$events"; then
  echo "RED: no visible menu-bar placement was observed for Rectangle Clone"
  exit 1
fi

echo "GREEN: Control Center placed Rectangle Clone in the visible menu bar"
