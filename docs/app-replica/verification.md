# Verification status

Status: **Reconstructed source fork; signed installed launch, Accessibility, Dock presence, and primary left-half hotkey verified. Exhaustive parity remains pending.**

## Deterministic source evidence

- Frozen upstream commit: `bf86a4b7d3dd246b895f149a99b39bcb89f22bfd`.
- Unmodified upstream Debug build succeeded.
- Unmodified upstream suite passed 310/310 tests.
- Rebranded candidate suite passed 314/314 tests after the identity, updater, duplicate-shortcut, and Dock changes.
- Candidate Debug and universal Release archives build successfully.

## Installed candidate evidence

- Installed path: `/Applications/Window Manager.app`.
- Product/bundle/URL identity: `Window Manager`, `com.serp.windowmanager`, `windowmanager`.
- Architecture: universal `arm64` + `x86_64`.
- Signature: Developer ID Application, owner team `847HR8U8D9`.
- `codesign --verify --deep --strict` passes.
- Installed executable SHA-256 exactly matches the archived source executable.
- The rebranded Accessibility onboarding and stale-grant recovery paths were exercised; the installed app is currently trusted.
- Built-product search finds none of the upstream bundle IDs, signing team, appcast, update key, update domain, or Sparkle framework.

The first Release archive exposed a real Team-ID mismatch between an ad-hoc app and the embedded Sparkle framework. The candidate removed Sparkle and its UI entry points, rebuilt with the owner's stable Developer ID identity, and relaunched successfully. The broken intermediate installed copies and packages were moved to Trash with descriptive names and remain recoverable.

## Brand evidence

- New four-pane app icon and menu-bar glyph are independently authored in this repository.
- Visible product strings and localized Rectangle brand tokens were replaced with the working identity.
- Upstream MIT license and accurate attribution remain.
- Final product name, legal owner copy, support destination, notarization, and release destination remain owner decisions.

## Unresolved runtime gates

- The stale Accessibility row was removed and the exact installed Developer ID-signed app was added again. The authorization window remains closed after relaunch and the runtime-readiness probe is green.
- The physical left-half hotkey passed; a complete left-half → restore → relaunch sequence still requires one paired evidence pass.
- Settings, drag-to-snap, URL actions, ignore/unignore, import/export, login item, and the exhaustive action matrix remain untested as installed behavior.
- Multi-display behavior cannot be directly exercised with the current one-display environment.
- Candidate-owned update infrastructure is intentionally absent.
- No independent verifier was authorized, so the completion gate remains red.
- Issue #4's screenshot-defined shipping profile is implemented and source-tested on its issue branch, but the signed issue-branch artifact has not yet replaced the installed app and its manual action matrix has not been exercised.
- The first installed reset exposed stale Todo recorder modifiers and Snap Areas toggles that did not refresh. The Snap Areas refresh defect is repaired and covered at its UI-adjacent seam. Todo Mode was later removed from scope by the owner and its UI, shortcuts, menu commands, layout behavior, and persistence are absent from the candidate.
- **HIGH-PRIORITY UNRESOLVED TODO:** the candidate Settings UI visibly differs from `/Applications/Rectangle.app`. Exhaustively audit every Settings screen/state/control with paired same-geometry screenshots, accessibility trees, interactions, side effects, and relaunch persistence before making any Settings or clone-parity claim.

## Runtime defects found during installed testing

- The first candidate status item reused macOS's generic `Item-0` visibility record. A pre-existing hidden record immediately rewrote `hideMenubarIcon` to `1` on every launch. A unique autosave name alone still allowed macOS to persist it hidden. The status item now uses `com.serp.windowmanager.statusItem` and makes the in-app **Hide menu bar icon** preference the sole visibility authority; `scripts/diagnose_runtime.sh` is the installed-runtime regression check.
- Toggling the original Accessibility row did not repair it. macOS logged `Failed to match existing code requirement`. Removing the stale row and adding `/Applications/Window Manager.app` created a matching grant; the installed app then passed the readiness probe.
- A real TextEdit window moved through `windowmanager://execute-action?name=left-half`, proving the authorized window-control path. Carbon did not accept injected `CGEvent` keystrokes, so a physical shortcut press remains the required hotkey-delivery check rather than a synthetic false failure.
- The owner physically exercised ⌥⌘← after the permission repair and confirmed that the installed app moved the window.
- Duplicate shortcut validators reject conflicts and name the owning action. Startup/import cleanup preserves the first action in canonical order and removes later duplicates; the installed candidate defaults contain no duplicate identities.
- The installed app uses regular activation policy and appears in the Dock accessibility tree. This intentionally differs from Rectangle's `LSUIElement` behavior at the owner's request.
- The menu-bar status item uses a fixed square length, an explicit template image, a candidate-owned autosave name, and a Window Manager accessibility label. Control Center still reports the item as blocked from the visible right-side menu bar on this crowded system; there is no public third-party `neverClip` API. The normal top-left app menu and Dock icon remain visible.
- Issue #4 commit `33b3a5e` was installed and its explicit Restore Defaults flow was exercised. Core/extra Shortcuts, General, and Snap Areas match the requested profile in direct candidate observation; candidate captures and raw defaults are recorded in `docs/app-replica/evidence/issue-4/installed-reset-verification.md`. This remains candidate-only evidence, not the required paired Rectangle Settings audit.

## Current artifact

- App: `/Applications/Window Manager.app`
- ZIP: `dist/Rectangle-Clone-1.100-local.zip`
- ZIP SHA-256: `13f992c407f68528da2147861ff06e1c0f8e7ba169e382ed7bf8256fbfca12be`
