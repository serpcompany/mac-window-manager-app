# Window Manager

Window Manager is a rebranded macOS window manager derived from the MIT-licensed [Rectangle](https://github.com/rxhanson/Rectangle) project. It keeps Rectangle's window-management behavior while using an isolated development identity:

- Product: **Window Manager**
- Bundle identifier: `com.serp.windowmanager`
- URL scheme: `windowmanager://`
- App presence: Dock, Command-Tab, and menu-bar status item enabled by default
- Preferences: `~/Library/Preferences/com.serp.windowmanager.plist`
- Startup config: `~/Library/Application Support/Window Manager/WindowManagerConfig.json`

This is currently a local development build, not an official Rectangle release and not endorsed by Rectangle's authors.

## Build and test

Requirements: macOS 10.15 or newer and Xcode.

```bash
xcodebuild \
  -project Rectangle.xcodeproj \
  -scheme Rectangle \
  -configuration Debug \
  -derivedDataPath .derived \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Build a runnable local bundle:

```bash
xcodebuild \
  -project Rectangle.xcodeproj \
  -scheme Rectangle \
  -configuration Debug \
  -derivedDataPath .derived \
  build

open '.derived/Build/Products/Debug/Window Manager.app'
```

macOS Accessibility approval is tied to the candidate bundle and signature. Do not expect Rectangle's existing permission to carry over.

## Use

Window Manager is a regular Dock app with a menu-bar status item. Click the Dock icon to reopen Settings, open the four-pane menu item when macOS has space to display it, choose a window action, or use the configured shortcuts. Drag-to-snap and the full set of extra grid sizes are retained from upstream.

macOS couples Dock and Command-Tab presence, so both are enabled together. On a crowded or notched menu bar, macOS may clip third-party status items; the Dock icon remains the reliable recovery path.

Execute an action by URL without intentionally foregrounding the app:

```bash
open -g 'windowmanager://execute-action?name=left-half'
```

The full action vocabulary and hidden preferences are documented in [TerminalCommands.md](TerminalCommands.md).

## Update boundary

Automatic updates are disabled in this development identity. The fork does not contact Rectangle's appcast, use Rectangle's Sparkle key, or publish through Rectangle's release infrastructure. A candidate-owned feed and signing key can be added after the owner approves a distribution identity.

## Releases

Mac App Store submissions are mirrored with strict `vMAJOR.MINOR.PATCH` tags and GitHub prereleases, then promoted after Apple approval. Every GitHub release includes a universal Developer ID–signed, Apple-notarized `.dmg` installer; the receipt-bound Mac App Store package is kept separate. See [the release runbook](docs/release/local-release.md).

## Verification

The upstream source baseline builds and passes 310 tests. The rebranded candidate passes 314 tests, including candidate-specific shortcut-conflict and Dock-identity checks. It is tracked separately in [the parity ledger](docs/app-replica/parity-ledger.md) and [completion manifest](docs/app-replica/completion-manifest.json). A green unit suite is supporting evidence, not a claim of complete installed-runtime parity.

## License and provenance

The source is used under the MIT License; see [LICENSE](LICENSE). Upstream Rectangle copyright and attribution are retained. The purple four-pane app icon and menu-bar mark in this fork were independently authored for the working development identity; final brand approval remains with the owner.
