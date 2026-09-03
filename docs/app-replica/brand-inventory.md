# Brand and operator-separation inventory

The licensed source may be reused under MIT, but its product identity and operator infrastructure are not candidate defaults. Colors sampled from Rectangle identify replacement locations; they do not define the candidate palette.

| ID | Category | Observed Rectangle value | Disposition | Working replacement / decision | Verification |
| --- | --- | --- | --- | --- | --- |
| product.name | Name | Rectangle | replace | Rectangle Clone (working name; final owner decision) | Search sources and built strings |
| product.bundle | Identifier | com.knollsoft.Rectangle | replace | co.serp.rectangleclone | Inspect built Info.plist and defaults domain |
| launcher.bundle | Identifier | com.knollsoft.RectangleLauncher | replace | co.serp.rectangleclone.launcher | Inspect built helper Info.plist |
| tests.bundle | Identifier | dev.ryanhanson.RectangleTests | replace | co.serp.rectangleclone.tests | Inspect build settings |
| url.scheme | Integration | rectangle | replace | rectangleclone | Launch URL action and inspect Info.plist |
| app.icon | Artwork | Rectangle icon, credited to upstream designers | redesign | Original candidate icon required; temporary development asset must be labeled | Compare source and built assets |
| status.icon | Artwork | Rectangle menu-bar glyph | redesign | Original candidate status glyph required | Compare menu bar and asset hashes |
| window-position.icons | Functional artwork | Window layout diagrams | owner-decision | Retain only if MIT provenance is sufficient; otherwise redraw original functional diagrams | Asset inventory and owner approval |
| product.copy | Copy | Rectangle names and upstream messaging | replace | Candidate-specific copy | Search localized strings and runtime UI |
| copyright | Legal | Ryan Hanson copyright | keep-system | Preserve MIT notice; add candidate copyright only after owner supplies legal name | Inspect About, Info.plist, LICENSE |
| source.credits | Attribution | Spectacle, contributors, icon authors | keep-system | Preserve accurate upstream attribution | README/About review |
| updater.feed | Service | rectangleapp.com updates.xml | remove | Disabled; candidate-owned feed requires owner decision | Static search and network exercise |
| updater.key | Security identity | Upstream Sparkle public key | remove | No key until candidate update signing is provisioned | Inspect Info.plist and built strings |
| signing.team | Security identity | XSYZ3E4B7D | replace | Owner's existing Developer ID team `847HR8U8D9` | codesign readback |
| support.urls | Operator endpoint | rectangleapp.com and upstream GitHub links | replace | Repository/support destinations require owner decision | Link and strings audit |
| defaults.domain | Persistence | com.knollsoft.Rectangle | replace | co.serp.rectangleclone | Fresh launch and plist audit |
| status.autosave | Persistence | Generic status-item visibility record | replace | `co.serp.rectangleclone.statusItem` | Relaunch with menu icon enabled and inspect candidate defaults |
| update.framework | Third party | Sparkle | remove | Removed until a candidate-owned update design exists | Dependency and runtime audit |
| masshortcut | Third party | rxhanson/MASShortcut fork | keep-system | Retain under its license with attribution | Package resolution and license audit |
| colors.type.motion | Visual system | System controls plus upstream styling | redesign | Establish original semantic tokens after baseline behavior is proven | Runtime surface comparison |
| release.infrastructure | Operator endpoint | upstream releases/Homebrew/download site | remove | No release destination configured | Static and runtime network audit |

No product-identity row is owner-approved as final merely because a working development replacement is listed here.
