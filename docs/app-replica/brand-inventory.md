# Window Manager brand and operator-separation inventory

The owner approved the final product identity in Issues #5 and #9. Rectangle remains identified only for factual MIT attribution or internal inherited source terminology.

| ID | Category | Reference value | Disposition | Approved replacement / decision | Verification |
| --- | --- | --- | --- | --- | --- |
| product.name | Name | Rectangle / prior candidate name | replace | Window Manager | Built plist and installed Finder/Dock/About/menu/settings |
| product.bundle | Identifier | upstream/prior candidate IDs | replace | `com.serp.windowmanager` | Build settings, bundle, defaults |
| launcher.bundle | Identifier | upstream/prior helper IDs | replace | `com.serp.windowmanager.launcher` | Embedded helper and login item |
| tests.bundle | Identifier | upstream/prior test IDs | replace | `com.serp.windowmanager.tests` | Build settings |
| url.scheme | Integration | upstream/prior schemes | replace | `windowmanager` | Built plist and URL exercise |
| defaults.support | Persistence | upstream/prior locations | replace | `com.serp.windowmanager`, `Window Manager/`, `WindowManagerConfig.json` | Fresh launch and filesystem audit |
| status.autosave | Persistence | generic/prior record | replace | `com.serp.windowmanager.statusItem` | Relaunch probe |
| app.icon | Artwork | upstream/purple development icon | redesign | Owner-supplied opaque SERP artwork | Asset manifest, build, installed captures |
| status.icon | Artwork | upstream glyph | redesign | Owner-supplied transparent SERP mark | Hashes and installed light/dark captures |
| window-position.icons | Functional artwork | MIT source diagrams | keep-system | Retain as MIT-licensed functional diagrams | LICENSE/catalog audit |
| product.copy | Copy | upstream/prior candidate names | replace | Window Manager; factual attribution remains | Source/built-string search |
| license.attribution | Legal | MIT notices and credits | keep-system | Preserve accurately | Distribution audit |
| owner.legal-copy | Legal | Not supplied | owner-decision | Legal entity/copyright wording required | Owner approval |
| updater | Service/security | Rectangle appcast, key, Sparkle UI | remove | No updater | Dependency/source/bundle/network search |
| signing.team | Security | `XSYZ3E4B7D` | replace | `847HR8U8D9` | Build settings/signature |
| support.privacy | Endpoints | Upstream endpoints | owner-decision | Public owner-controlled URLs required | Owner approval/link audit |
| release.infrastructure | Distribution | Upstream release channels | remove | Local Mac App Store scaffold | Script audit/ASC records |
| masshortcut | Third party | rxhanson/MASShortcut | keep-system | Retain under MIT | Package/license audit |
| app-store-metadata | Distribution | None | redesign | English (U.S.) version 1.0 scaffold | Local metadata validation |
| privacy.manifest | Privacy | None | redesign | No tracking/collection; UserDefaults CA92.1 | Built manifest/owner ASC confirmation |

Inventory completeness remains blocked by installed visual proof, owner legal copy, support/privacy destinations, and signed Mac App Store artifact inspection.
