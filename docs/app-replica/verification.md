# Verification status

Status: **Window Manager local release candidate compiles; App Store signing, installed runtime acceptance, and complete parity remain blocked.**

## Issue #9 local evidence

- Final full Debug test suite: 273 tests passed after removing retired Extras-only implementation and tests.
- Signed sandboxed universal Mac App Store archive and signed installer export succeeded at `/tmp/Window Manager.xcarchive` and `/tmp/WindowManagerAppStoreExport/Window Manager.pkg`.
- Built identity: Window Manager 1.0 (1), `com.serp.windowmanager`, `windowmanager`, embedded `com.serp.windowmanager.launcher`.
- Built privacy manifest: present and plist-valid.
- Source and artifact forbidden searches: no Shortcut Coach identity, `com.knollsoft.*`, `XSYZ3E4B7D`, upstream appcast/update key, old candidate bundle ID, or old candidate display name.
- Canonical metadata: `asc metadata validate --dir ./metadata --output table` reports 0 errors and 0 warnings.
- Stage Manager and General → Extras UI/registration/menu/URL/config wiring are absent; the retired calculation factory routes, stack badge, and overlap-offset implementations are removed. Legacy names remain only for deletion, decoding compatibility, and regression assertions.
- Owner artwork hashes are enforced by `scripts/generate_brand_assets.sh`; legacy and layered icon catalogs compile.

Evidence is under `docs/app-replica/evidence/issue-9/local/` and the asset package under `docs/app-replica/assets/window-manager/`.

## Installed behavior already established on the prior candidate

Earlier Developer ID candidate work exercised Accessibility reauthorization, Dock presence, a physical left-half shortcut, and the menu-bar visibility investigation. Those observations belong to the old candidate identity and do not verify this final Mac App Store candidate.

macOS can clip third-party status items on crowded/notched menu bars and exposes no public never-clip priority API. Window Manager therefore keeps the item enabled by default, uses a fixed square template item with a unique autosave identity and accessibility label, prevents system-removal persistence, and remains reachable through its ordinary Dock/app menu. Issue #7 still requires owner-visible installed proof under the current display arrangement.

## Remaining gates

- App Store Connect app/version creation, upload, processing, strict validation, and submission. Bundle IDs, certificates, profiles, signed archive, and signed installer export are complete.
- Exact signed `/Applications/Window Manager.app` install and menu-bar, Dock, shortcuts, settings, persistence, Accessibility, login-item, URL, config, quit/relaunch exercises.
- Screenshots/accessibility trees from that exact artifact, including Settings without Stage Manager or Extras and SERP artwork in Finder/Dock/About/menu bar.
- Sandbox compatibility for system-wide Accessibility window control.
- Owner legal/support/privacy/review/availability/age-rating decisions listed in `docs/release/app-store-blockers.md`.
- Paired in-scope audit and independent fresh-context verification. The completion validator is expected to remain red.
