# App Store Connect 1.0 state

Recorded 2026-09-04 (Asia/Tokyo).

- App: Mac Window Manager (`6808371833`)
- Bundle ID: `com.serp.windowmanager`
- Version: 1.0 (`7a92c15a-2073-417d-a0b2-7dc0b2bc0765`)
- Build: 2 (`86a7091b-2336-4810-8838-f73ebf2be6ee`), processing state `VALID`
- Release source commit: `97785c04c1c96642d0bf946b96e9318fe6ac7804`
- Build attached to version: yes
- Encryption: exempt / does not use non-exempt encryption
- Category: Productivity
- Copyright: 2026 Matthew Schumacher
- Content rights: does not use third-party storefront content
- Age rating declaration: all objectionable-content fields none/false
- Support: https://serp.store/support
- Privacy policy: https://serp.store/legal/privacy
- Screenshot set: APP_DESKTOP (`90227cec-3864-414c-947f-85e4b39c30f7`)
- Screenshot assets: `1cf4cb4e-518f-4676-aa1e-d488ab119f69`, `ec242a44-e746-4f03-9974-7862e85b1588`, `51e2fe55-80b8-4cf2-b17e-d2bf6485c75a`, `20bf977a-1430-4658-b50f-c1af214a55ee`, and `1ab90520-7429-4d72-95dd-9b4ce3211e96`, complete
- Price: US $9.99 base price
- Availability: all 175 current storefronts; new storefronts enabled
- App Review contact: configured
- App Privacy: published as “Data Not Collected” on 2026-09-04 (Asia/Tokyo)
- Review submission: `0adf89f0-3a22-4677-8f8e-ac13a1412307`
- Submitted: 2026-09-03T22:46:40.155Z
- Current state: `WAITING_FOR_REVIEW`
- GitHub SemVer: `1.0.0` (App Store version `1.0`)
- Git tag: annotated `v1.0.0`, resolving to release source commit `97785c04c1c96642d0bf946b96e9318fe6ac7804`
- GitHub Release: https://github.com/serpcompany/mac-window-manager-app/releases/tag/v1.0.0
- GitHub state: published prerelease while Apple review is pending
- Installer asset: `Window-Manager-1.0.0.dmg`
- Installer SHA-256: `cb11173380bf336b188307b82f4c017d2e61c1d4d7f84584a5ab904319f39c6f`
- Installer signing: Developer ID Application, team `847HR8U8D9`, hardened runtime, universal Intel/Apple silicon
- Apple notarization: accepted submission `cbe08978-6005-4e27-bcdc-cb391d8bfdb5`; ticket stapled and Gatekeeper accepted

The first build was withdrawn after a storefront audit found an effectively blank compiled icon, a single permission-only screenshot, weak copy, and an underpriced listing. Build 2 removes the faulty Icon Composer source, uses the verified high-contrast asset catalog icon, supplies five real-UI screenshots, expands the sales copy, and sets the base price to $9.99. The canonical readiness check and review doctor reported zero blocking issues before resubmission. The public API cannot verify App Privacy publication, so its published state was verified in the signed-in App Store Connect UI. Version 1.0 and its current review item report `WAITING_FOR_REVIEW`. GitHub uses the normalized SemVer `v1.0.0`; its prerelease and notarized DMG were replaced to target the repaired source commit and will be promoted after Apple reports the version ready for distribution.
