# App Store Connect 1.0 state

Recorded 2026-09-04 (Asia/Tokyo).

- App: Mac Window Manager (`6808371833`)
- Bundle ID: `com.serp.windowmanager`
- Version: 1.0 (`7a92c15a-2073-417d-a0b2-7dc0b2bc0765`)
- Build: 3 (`a4e32754-23da-4e27-a0fe-0118c51a7a57`), processing state `VALID`
- Release source commit: `d609c8cc178ebe38b4e25ab6945fbd63a1d5083f`
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
- Resubmitted: 2026-09-04T03:01:17.792Z
- Current state: `WAITING_FOR_REVIEW`
- GitHub SemVer: `1.0.0` (App Store version `1.0`)
- Git tag: annotated `v1.0.0`, resolving to release source commit `d609c8cc178ebe38b4e25ab6945fbd63a1d5083f`
- GitHub Release: https://github.com/serpcompany/mac-window-manager-app/releases/tag/v1.0.0
- GitHub state: published prerelease while Apple review is pending
- Installer asset: `Window-Manager-1.0.0.dmg`
- Installer SHA-256: `175cc93335f299dc5dc6bbc7f3c63e71c0beb28af4f7755891a7e898406dc060`
- Installer signing: Developer ID Application, team `847HR8U8D9`, hardened runtime, universal Intel/Apple silicon
- Apple notarization: accepted submission `68e9b860-f8c0-450d-a41a-1a09ea8a66c9`; ticket stapled and Gatekeeper accepted

The first build was withdrawn after a storefront audit found an effectively blank compiled icon, a single permission-only screenshot, weak copy, and an underpriced listing. Build 2 fixed the storefront presentation but Apple rejected it under guideline 2.5.1 because its binary referenced the private `__AXUIElementGetWindow` symbol. PR #13 removed the declaration and call, replaced window-ID resolution with public Core Graphics window descriptions matched to public Accessibility data, added regression coverage, and added final-binary deny-list checks. The signed App Store build 3 and notarized GitHub DMG both pass `nm` and `strings` scans with no `AXUIElementGetWindow` reference. Build 3 is attached to the existing review item, which was marked resolved and resubmitted. The public API cannot verify App Privacy publication, so its published state was verified in the signed-in App Store Connect UI. Version 1.0 and its current review submission report `WAITING_FOR_REVIEW`.
