# Verification status

Status: **Window Manager local release candidate compiles; App Store signing, installed runtime acceptance, and complete parity remain blocked.**

## Issue #9 local evidence

- Full Debug test suite: 319 tests passed before the asset/release batch; final rerun is required after all changes.
- Clean unsigned universal Release build: succeeded for arm64 and x86_64 at `/tmp/window-manager-issue9-release/Build/Products/Release/Window Manager.app`.
- Built identity: Window Manager 1.0 (1), `com.serp.windowmanager`, `windowmanager`, embedded `com.serp.windowmanager.launcher`.
- Built privacy manifest: present and plist-valid.
- Source and artifact forbidden searches: no Shortcut Coach identity, `com.knollsoft.*`, `XSYZ3E4B7D`, upstream appcast/update key, old candidate bundle ID, or old candidate display name.
- Canonical metadata: `asc metadata validate --dir ./metadata --output table` reports 0 errors and 0 warnings.
- Stage Manager and General → Extras UI/runtime wiring are absent; legacy keys are enumerated only for deletion and regression tests.
- Owner artwork hashes are enforced by `scripts/generate_brand_assets.sh`; legacy and layered icon catalogs compile.

Evidence is under `docs/app-replica/evidence/issue-9/local/` and the asset package under `docs/app-replica/assets/window-manager/`.

## Installed behavior already established on the prior candidate

Earlier Developer ID candidate work exercised Accessibility reauthorization, Dock presence, a physical left-half shortcut, and the menu-bar visibility investigation. Those observations belong to the old candidate identity and do not verify this final Mac App Store candidate.

macOS can clip third-party status items on crowded/notched menu bars and exposes no public never-clip priority API. Window Manager therefore keeps the item enabled by default, uses a fixed square template item with a unique autosave identity and accessibility label, prevents system-removal persistence, and remains reachable through its ordinary Dock/app menu. Issue #7 still requires owner-visible installed proof under the current display arrangement.

## Remaining gates

- Mac App Store bundle-ID registration, Apple Distribution certificate, profiles, signed archive/export, upload, processing, strict validation, and submission.
- Exact signed `/Applications/Window Manager.app` install and menu-bar, Dock, shortcuts, settings, persistence, Accessibility, login-item, URL, config, quit/relaunch exercises.
- Screenshots/accessibility trees from that exact artifact, including Settings without Stage Manager or Extras and SERP artwork in Finder/Dock/About/menu bar.
- Sandbox compatibility for system-wide Accessibility window control.
- Owner legal/support/privacy/review/availability/age-rating decisions listed in `docs/release/app-store-blockers.md`.
- Paired in-scope audit and independent fresh-context verification. The completion validator is expected to remain red.
