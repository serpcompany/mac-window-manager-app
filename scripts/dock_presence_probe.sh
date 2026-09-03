#!/usr/bin/env bash
set -euo pipefail

app_path="${1:-/Applications/Rectangle Clone.app}"

[[ $(/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$app_path/Contents/Info.plist") == "false" ]]

swift - <<'SWIFT'
import AppKit
import ApplicationServices

func copy(_ element: AXUIElement, _ attribute: String) -> AnyObject? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else { return nil }
    return value
}

func containsRectangleClone(_ element: AXUIElement, depth: Int = 0) -> Bool {
    guard depth <= 8 else { return false }
    let title = copy(element, kAXTitleAttribute) as? String ?? ""
    let description = copy(element, kAXDescriptionAttribute) as? String ?? ""
    if title == "Rectangle Clone" || description == "Rectangle Clone" { return true }
    return ((copy(element, kAXChildrenAttribute) as? [AXUIElement]) ?? [])
        .contains { containsRectangleClone($0, depth: depth + 1) }
}

guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "co.serp.rectangleclone" }),
      app.activationPolicy == .regular
else {
    fputs("RED: Rectangle Clone is not running with regular Dock activation policy\n", stderr)
    exit(1)
}

guard let dock = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.dock" }),
      containsRectangleClone(AXUIElementCreateApplication(dock.processIdentifier))
else {
    fputs("RED: Rectangle Clone is absent from the Dock accessibility tree\n", stderr)
    exit(1)
}

print("GREEN: Rectangle Clone is present in the Dock with regular activation policy")
SWIFT
