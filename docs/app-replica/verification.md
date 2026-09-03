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

## Current artifact

- App: `/Applications/Rectangle Clone.app`
- ZIP: `dist/Rectangle-Clone-1.100-local.zip`
- ZIP SHA-256: `ae3bf25e94a11633d50f9b0757e8e0fd2ea9def3e12de1618e3e7eb30f2aa755`
