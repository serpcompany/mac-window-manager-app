# Issue #4 source verification — 2026-09-04

Scope: screenshot-defined fresh-install and explicit Restore Defaults profile on `codex/issue-4-default-profile`. This is source/build evidence only; it is not installed-runtime or Settings-parity evidence.

## Deterministic profile checks

- Focused test selection: `ShippingDefaultProfileTests`, `ConfigImportTests`, and `DefaultsExportTests`.
- Result: 16 tests passed, 0 failures.
- The profile-specific suite asserts all 31 assigned shortcut identities, every other active window action's explicit empty/unassigned state, uniqueness, landscape and portrait mappings, all Issue #4 General values, true-empty-domain gating, nonempty-domain protection, ordinary upgrade preservation, explicit reset, and Codable config round-trip.
- The import test verifies that a shipping-profile export keeps omitted shortcut actions explicitly unassigned rather than exposing legacy registered defaults.

## Full regression

- Command: `xcodebuild test -project Rectangle.xcodeproj -scheme Rectangle -destination 'platform=macOS' -derivedDataPath /tmp/rectangle-issue4-tests CODE_SIGNING_ALLOWED=NO`
- Result: 323 tests passed, 0 failures.
- Result bundle: `/tmp/rectangle-issue4-tests-final/Logs/Test/Test-Rectangle-2026.09.04_02-59-32-+0900.xcresult`.
- The formerly environment-sensitive Todo hotkey test helper now retries from a bounded set of globally free identities; all 8 tests passed across 3 iterations (24 executions).

## Clean signed candidate build

- Command: `xcodebuild clean build -project Rectangle.xcodeproj -scheme Rectangle -configuration Release -destination 'generic/platform=macOS' -derivedDataPath /tmp/rectangle-issue4-signed-release-final-2`
- Result: build succeeded for universal `arm64` + `x86_64`.
- `scripts/verify_release.sh` result: `PASS: signed universal Rectangle Clone artifact has isolated identity`.
- Bundle identifier: `co.serp.rectangleclone`.
- Developer ID team: `847HR8U8D9`.
- Executable SHA-256: `e2ddf1eecc4e5f365f2a8d08f00be23ea95ce48ac1f25c8928ff7c29c497c802`.
- Static source and built-bundle searches found none of the forbidden upstream identifiers, signing team, update domain, public key, or Sparkle material.
- `git diff --check` passed.

## Deliberately red gates

- The completion validator remains red, as required; the exhaustive reference inventory, installed/manual acceptance, and independent verification are incomplete.
- A Developer ID-signed issue-branch build has not replaced `/Applications/Rectangle Clone.app`, and no candidate defaults domain was reset during this source pass.
- The required physical actions and login-item readback remain untested for this commit.
- **HIGH-PRIORITY UNRESOLVED TODO:** exhaustively audit every Settings screen/state/control against `/Applications/Rectangle.app` with paired same-geometry screenshots and accessibility trees. The candidate currently looks different, so no Settings or clone-parity claim is warranted.

## Installed-reset defects repaired after the first verification pass

The first installed Restore Defaults exercise found two defects even though the underlying source profile was correct:

- Toggle Todo was stored as Control-Option-Command-B (`modifierFlags=1835008`) instead of Command-B (`1048576`). The Settings controller rebound an already-bound `MASShortcutView` during the reset/config notification cycle. Its stale pre-reset shortcut could write Control-Option modifiers back into the new assignment. Restore now disconnects both Todo recorder bindings before replacing defaults, and reconnection always unbinds first so it is idempotent.
- Snap Areas reloaded mapping popups but not its toggle controls. The underlying `hapticFeedbackOnSnap=1` and `footprintAnimationDurationMultiplier=0.75` were correct while Haptic Feedback and Animate Footprint remained visibly off. Both reset and config-import notifications now reload toggle state and mappings together.

Regression evidence after both repairs:

- `ShippingDefaultProfileUIReloadTests`: 2 passed, 0 failed. The tests exercise real `MASShortcutView` bindings and real `NSButton` state reloads.
- Full suite: 325 passed, 0 failed. Result bundle: `/tmp/rectangle-issue4-hotfix-tests/Logs/Test/Test-Rectangle-2026.09.04_04-00-26-+0900.xcresult`.
- Clean signed Release build: `/tmp/rectangle-issue4-hotfix-signed-release/Build/Products/Release/Rectangle Clone.app`.
- `scripts/verify_release.sh`: passed.
- Executable SHA-256: `fa43a9e4a94351826bf07c50bbe3c60c4a5beba5f50acf5152612b1261f80d44`.

The installed app was deliberately not replaced or reset in this repair pass. Both fixes still require a fresh installed UI readback by the coordinating agent.
