#!/usr/bin/env bash
set -euo pipefail

app_path="${1:-/Applications/Window Manager.app}"
bundle_id="com.serp.windowmanager"
executable="$app_path/Contents/MacOS/Window Manager"

failures=0

if ! pgrep -f "$executable" >/dev/null; then
  echo "RED: Window Manager process is not running"
  failures=$((failures + 1))
else
  echo "PASS: Window Manager process is running"
fi

ls_ui_element=$(/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$app_path/Contents/Info.plist")
if [[ "$ls_ui_element" == "true" ]]; then
  echo "INFO: Dock icon is intentionally hidden (LSUIElement=true)"
else
  echo "INFO: Dock icon is enabled"
fi

hide_menu=$(defaults read "$bundle_id" hideMenubarIcon 2>/dev/null || echo 0)
if [[ "$hide_menu" == "1" ]]; then
  echo "RED: menu-bar icon is hidden by hideMenubarIcon=1"
  failures=$((failures + 1))
else
  echo "PASS: menu-bar icon preference is enabled"
fi

status_item_count=$(swift -e 'import AppKit
import ApplicationServices
func copy(_ element: AXUIElement, _ attribute: String) -> AnyObject? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else { return nil }
    return value
}
guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.serp.windowmanager" }) else {
    print(0)
    exit(0)
}
let root = AXUIElementCreateApplication(app.processIdentifier)
let children = (copy(root, kAXChildrenAttribute) as? [AXUIElement]) ?? []
var count = 0
for child in children where (copy(child, kAXRoleAttribute) as? String) == kAXMenuBarRole as String {
    for item in (copy(child, kAXChildrenAttribute) as? [AXUIElement]) ?? [] {
        let title = copy(item, kAXTitleAttribute) as? String ?? ""
        guard title.isEmpty else { continue }
        let menus = (copy(item, kAXChildrenAttribute) as? [AXUIElement]) ?? []
        let menuItems = menus.flatMap { (copy($0, kAXChildrenAttribute) as? [AXUIElement]) ?? [] }
        if menuItems.contains(where: { (copy($0, kAXTitleAttribute) as? String) == "Quit Window Manager" }) {
            count += 1
        }
    }
}
print(count)')

if (( status_item_count > 0 )); then
  echo "PASS: Window Manager status item is present in the menu bar"
else
  echo "RED: Window Manager status item is absent from the menu bar"
  failures=$((failures + 1))
fi

window_names=$(swift -e 'import CoreGraphics
let rows = (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]) ?? []
for row in rows where (row[kCGWindowOwnerName as String] as? String) == "Window Manager" {
    if let name = row[kCGWindowName as String] as? String { print(name) }
}')

if grep -q '^Authorize Window Manager$' <<<"$window_names"; then
  echo "RED: Accessibility authorization is not active; hotkeys cannot initialize"
  failures=$((failures + 1))
else
  echo "PASS: Accessibility onboarding is no longer visible"
fi

if (( failures > 0 )); then
  echo "RED: $failures runtime readiness failure(s)"
  exit 1
fi

echo "GREEN: runtime prerequisites are ready for hotkey testing"
