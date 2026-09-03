# Verification status

Status: **Reconstructed source fork; identity and installed launch verified; Accessibility-dependent workflow pending.**

## Deterministic source evidence

- Frozen upstream commit: `bf86a4b7d3dd246b895f149a99b39bcb89f22bfd`.
- Unmodified upstream Debug build succeeded.
- Unmodified upstream suite passed 310/310 tests.
- Rebranded candidate suite passed 310/310 tests after the identity and updater changes.
- Candidate Debug and universal Release archives build successfully.

## Installed candidate evidence

- Installed path: `/Applications/Rectangle Clone.app`.
- Product/bundle/URL identity: `Rectangle Clone`, `co.serp.rectangleclone`, `rectangleclone`.
- Architecture: universal `arm64` + `x86_64`.
- Signature: Developer ID Application, owner team `847HR8U8D9`.
- `codesign --verify --deep --strict` passes.
- Installed executable SHA-256 exactly matches the archived source executable.
- Installed app launches and presents the rebranded Accessibility onboarding window.
- Built-product search finds none of the upstream bundle IDs, signing team, appcast, update key, update domain, or Sparkle framework.

The first Release archive exposed a real Team-ID mismatch between an ad-hoc app and the embedded Sparkle framework. The candidate removed Sparkle and its UI entry points, rebuilt with the owner's stable Developer ID identity, and relaunched successfully. The broken intermediate installed copies and packages were moved to Trash with descriptive names and remain recoverable.

## Brand evidence

- New four-pane app icon and menu-bar glyph are independently authored in this repository.
- Visible product strings and localized Rectangle brand tokens were replaced with the working identity.
- Upstream MIT license and accurate attribution remain.
- Final product name, legal owner copy, support destination, notarization, and release destination remain owner decisions.

## Unresolved runtime gates

- The Accessibility row visible in System Settings was created by an earlier signature. The stable installed app still reports untrusted until that row is toggled off and on for the stable code requirement.
- The primary left-half → restore → relaunch workflow has not yet been exercised.
- Settings, drag-to-snap, URL actions, ignore/unignore, import/export, login item, and the exhaustive action matrix remain untested as installed behavior.
- Multi-display behavior cannot be directly exercised with the current one-display environment.
- Candidate-owned update infrastructure is intentionally absent.
- No independent verifier was authorized, so the completion gate remains red.

## Runtime defects found during installed testing

- The first candidate status item reused macOS's generic `Item-0` visibility record. A pre-existing hidden record immediately rewrote `hideMenubarIcon` to `1` on every launch. A unique autosave name alone still allowed macOS to persist it hidden. The status item now uses `co.serp.rectangleclone.statusItem` and makes the in-app **Hide menu bar icon** preference the sole visibility authority; `scripts/diagnose_runtime.sh` is the installed-runtime regression check.

## Current artifact

- App: `/Applications/Rectangle Clone.app`
- ZIP: `dist/Rectangle-Clone-1.100-local.zip`
- ZIP SHA-256: `6458eb57355000ed0770ae2fd01db90afc4aa342572e8a6cc158b92194f4c5ec`
