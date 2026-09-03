# Parity ledger

Status is deliberately red until each row is exercised against the frozen source baseline and exact packaged candidate.

| ID | Surface/state | Interaction and persistence boundary | Status |
| --- | --- | --- | --- |
| launch.permission-required | First launch without Accessibility | Explain/request permission; recover after denial; relaunch | untested |
| menu.default | Menu-bar menu, ordinary modifier state | Open menu; inspect enabled actions, shortcuts, settings, ignore, quit | untested |
| menu.option | Menu-bar menu while Option is held | Reveal logging/about alternate item | untested |
| settings.shortcuts | Shortcuts tab, default and edited | Record/clear shortcuts; extra shortcuts; persist relaunch | untested |
| shortcut.unique-assignment | All shortcut recorders/import/startup | Reject a duplicate, name its owner, normalize legacy duplicates | pass |
| settings.snap-areas | Snap Areas tab | Configure edge/corner mappings and modifier behavior; persist | untested |
| settings.general | General tab | Exercise every visible control; import/export/reset; persist | untested |
| settings.exhaustive-reference-audit | Every Settings screen/state/control versus installed `/Applications/Rectangle.app` | Capture paired full-window screenshots and accessibility trees at identical geometry; compare visual structure, text, controls, interactions, side effects, and relaunch persistence | **HIGH-PRIORITY TODO — unresolved: candidate visibly differs; exhaustive paired audit not yet run** |
| action.halves | Normal resizable window | Left/right/top/bottom/center half and cycling | untested |
| action.corners | Normal resizable window | Four quarters and corner cycling | untested |
| action.thirds | Normal resizable window | Thirds and two-thirds on landscape/portrait | untested |
| action.fourths-and-three-fourths | Normal resizable window | Fourth and three-fourths positions | untested |
| action.sixths-eighths-ninths-twelfths-sixteenths | Extra sizes | Every additional grid action and repeated-cycle behavior | untested |
| action.maximize-size-center-restore | Normal resizable window | Maximize variants, smaller/larger, center, restore | untested |
| action.move | Normal resizable window | Directional move and fixed-size edge alignment | untested |
| action.displays | Multi-display window | Next/previous display, screen ordering, cursor movement | unresolved: only one display connected |
| action.multi-window | Multiple app windows | Tile all, cascade all, cascade active app, reverse all | untested |
| snapping.drag | Draggable normal window | Edge/corner drag, footprint, cancel, unsnap restore | untested |
| ignore.application | Frontmost app | Ignore/unignore from menu and URL; shortcut registration changes | untested |
| url.execute-action | Candidate URL scheme | Execute every documented action without foreground activation | untested |
| url.execute-task | Candidate URL scheme | Ignore/unignore supplied bundle ID | untested |
| titlebar.green-button | Configured titlebar/green button behavior | Execute override and restore paths | untested |
| config.import-export | Configuration files | Export, import, malformed input, startup import, archive rename | untested |
| login-item | Launch on login | Toggle, read back system state, relaunch | untested |
| updates | Update settings | No Rectangle feed/key; disabled until candidate-owned infrastructure exists | unresolved: owner infrastructure required |
| logging | Debug logging window | Open, generate action, redact dynamic values as needed, close | untested |
| persistence.identity | Candidate defaults domain | Settings persist under candidate identity without reading Rectangle preferences | untested |
| packaging.identity | Built/installed app | Product name, bundle ID, URL scheme, signature, assets, credits | untested |
| app.presence.dock | Installed app, default launch | Dock and Command-Tab presence; Dock reopen path | pass |
| app.presence.menu-status | Installed app, crowded menu bar | Create visible labeled status item and survive relaunch | unresolved: Control Center clips third-party item |

The completion manifest is the machine-readable authority. This table is the human review surface and will expand when a newly reachable state is discovered.
