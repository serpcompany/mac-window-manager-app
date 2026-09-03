# Issue #4 installed reset verification — 2026-09-04

Installed artifact: `/Applications/Rectangle Clone.app`

- Branch: `codex/issue-4-default-profile`
- Source commit: `33b3a5ed84a1e58ed4760627db2146d87a91959a`
- Executable SHA-256: `fa43a9e4a94351826bf07c50bbe3c60c4a5beba5f50acf5152612b1261f80d44`
- Developer ID signature and universal `arm64` + `x86_64` verification passed before installation.
- Existing candidate preferences were backed up outside the repository before reset.
- The explicit **Restore Default Shortcuts & Snap Areas** confirmation was accepted in the installed app.

## Direct UI observations

- Core Shortcuts match the owner profile, including the required assigned and empty states.
- Expanded Thirds, Sixths, Fourths, Three Fourths, and Move actions match the owner profile.
- General shows Launch on login on, menu-bar hiding off, adjacent-display repeated commands, 0 px gaps, keyboard restrictions off, cursor movement on, title-bar double-click off, Todo on, 400 px/right Todo layout, 190 px Stage Manager area, and green-button override on.
- Toggle Todo is exactly `⌘B` (`keyCode=11`, `modifierFlags=1048576`).
- Reflow Todo is exactly `⌃⌥N` (`keyCode=45`, `modifierFlags=786432`).
- Snap windows, unsnap restore, Haptic Feedback, and Animate Footprint all display on immediately after reset.
- Landscape snap selectors match the screenshot profile.
- Installed defaults duplicate-identity audit result: `[]`.

## Candidate captures

- `installed/shortcuts-after-reset.jpeg`
- `installed/extra-shortcuts-after-reset.jpeg`
- `installed/snap-areas-after-reset.jpeg`
- `installed/general-after-reset.jpeg`

These are candidate-only captures. They do not satisfy the required paired Settings differential audit against `/Applications/Rectangle.app`.

## Remaining gates

- Physically exercise the Issue #4 action matrix under the restored shortcuts.
- Verify launch-item state and quit/relaunch persistence.
- Perform the exhaustive paired Rectangle/Rectangle Clone Settings screenshot and accessibility audit.
