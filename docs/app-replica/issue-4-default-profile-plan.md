# Issue #4 — owner default profile implementation plan

Status: source implementation and deterministic verification complete; installed/manual acceptance and Settings parity remain red.

Post-install repair note: the first installed reset exposed missing Snap Areas toggle refresh. That defect has UI-adjacent regression coverage and installed readback. Todo Mode, Stage Manager integration, and General → Extras were subsequently removed from scope by the owner and are not part of the shipping profile.

## Scope

Encode the three owner screenshots from 2026-09-04 as the candidate-owned shipping profile. Apply that profile only to a truly fresh candidate defaults domain and when the user explicitly chooses **Restore Default Shortcuts & Snap Areas**. An ordinary version upgrade must not rewrite any existing shortcut, snap-area, or General preference.

The profile covers:

- every assigned and intentionally unassigned window shortcut shown in Issue #4;
- landscape and portrait snap mappings plus the four visible snap behaviors;
- the General settings recorded in Issue #4;
- deterministic export/import of the resulting stored profile.

The candidate must not read `com.knollsoft.Rectangle`, restore upstream update infrastructure, or weaken duplicate-shortcut rejection.

## Implementation

1. Define one typed `ShippingDefaultProfile` used by shortcut registration, fresh-install initialization, explicit restore, and tests.
2. Detect a fresh install from the absence of the candidate-owned `lastVersion` marker. Persist the profile before runtime managers are initialized, then write the normal version markers. Leave the upgrade path unchanged.
3. On explicit restore, clear every candidate shortcut key first so intentionally unassigned actions stay unassigned, write the canonical assignments and behavior settings, refresh cached Defaults objects, and notify dependent UI/runtime managers.
4. Test every shortcut key code/modifier pair, every unassigned action, uniqueness, snap mappings, General values, fresh-install gating, upgrade preservation, restore behavior, and export/import round-trip.
5. Run focused tests, the full suite, clean build, identity checks, static forbidden-identity search, `git diff --check`, and the completion validator.

## Acceptance still requiring installed/manual evidence

- Reset the Developer ID-signed installed candidate to a truly fresh candidate domain and capture the visible profile.
- Exercise Left, Right, Maximize, Restore, one Third, and one Sixth against real windows.
- Confirm the login item state via the system service and verify persistence through quit/relaunch.

## HIGH-PRIORITY UNRESOLVED TODO — exhaustive Settings parity audit

Before any clone-parity claim, exhaustively audit **every Settings screen, reachable state, and control** against the installed `/Applications/Rectangle.app` reference. The candidate currently looks different. For Shortcuts, Snap Areas, General, nested/extra controls, dialogs, record/clear states, scrolling, and import/export/reset flows, capture paired full-window screenshots and accessibility trees at identical geometry; compare text, ordering, visibility, control type, enabled/selected/focused state, spacing, typography, icons, and persistence/side effects. Add one parity-ledger row per `surface × state × interaction × persistence boundary` and keep each row unresolved until paired visual/accessibility and behavioral evidence passes. This Issue #4 implementation does **not** complete or waive that audit.
