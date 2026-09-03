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
