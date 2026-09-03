# Rectangle Clone

Rectangle Clone is a rebranded macOS window manager derived from the MIT-licensed [Rectangle](https://github.com/rxhanson/Rectangle) project. It keeps Rectangle's window-management behavior while using an isolated development identity:

- Product: **Rectangle Clone**
- Bundle identifier: `co.serp.rectangleclone`
- URL scheme: `rectangleclone://`
- Preferences: `~/Library/Preferences/co.serp.rectangleclone.plist`
- Startup config: `~/Library/Application Support/Rectangle Clone/RectangleCloneConfig.json`

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

open '.derived/Build/Products/Debug/Rectangle Clone.app'
```

macOS Accessibility approval is tied to the candidate bundle and signature. Do not expect Rectangle's existing permission to carry over.

## Use

Rectangle Clone is a menu-bar utility. Open the four-pane menu icon, choose a window action, or use the configured shortcuts. Drag-to-snap and the full set of extra grid sizes are retained from upstream.

Execute an action by URL without intentionally foregrounding the app:

```bash
open -g 'rectangleclone://execute-action?name=left-half'
```

The full action vocabulary and hidden preferences are documented in [TerminalCommands.md](TerminalCommands.md).

## Update boundary

Automatic updates are disabled in this development identity. The fork does not contact Rectangle's appcast, use Rectangle's Sparkle key, or publish through Rectangle's release infrastructure. A candidate-owned feed and signing key can be added after the owner approves a distribution identity.

## Verification

The upstream source baseline builds and passes 310 tests. The rebranded candidate is tracked separately in [the parity ledger](docs/app-replica/parity-ledger.md) and [completion manifest](docs/app-replica/completion-manifest.json). A green unit suite is supporting evidence, not a claim of complete installed-runtime parity.

## License and provenance

The source is used under the MIT License; see [LICENSE](LICENSE). Upstream Rectangle copyright and attribution are retained. The purple four-pane app icon and menu-bar mark in this fork were independently authored for the working development identity; final brand approval remains with the owner.
