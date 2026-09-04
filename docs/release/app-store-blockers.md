# Version 1.0 App Store status

Mac Window Manager 1.0 build 3 was resubmitted to App Review on 2026-09-04T03:01:17.792Z. Submission `0adf89f0-3a22-4677-8f8e-ac13a1412307` is `WAITING_FOR_REVIEW`.

Completed App Store configuration:

- US $9.99 base price, all 175 current storefronts, and automatic availability in new storefronts.
- App Review contact and reviewer instructions, with no demo account required.
- App Privacy published as “Data Not Collected.”
- Expanded sales metadata, category, copyright, content rights, age rating, encryption compliance, build attachment, corrected compiled icon, five validated desktop screenshots, and removal of the private `__AXUIElementGetWindow` API rejected in build 2.

No App Store submission blocker remains. Exact sandbox-runtime Accessibility verification is still pending installation through the Mac App Store; a distribution-signed payload cannot be launched directly without a store receipt. This runtime evidence requirement remains separate from Apple’s review submission state.

The matching GitHub prerelease is `v1.0.0` and includes the Developer ID–signed, notarized, stapled universal installer `Window-Manager-1.0.0.dmg`. It will be promoted to a full release after Apple approval.

Resolved resources are recorded in Issue #9 and #12: app `6808371833`, version `7a92c15a-2073-417d-a0b2-7dc0b2bc0765`, valid build `a4e32754-23da-4e27-a0fe-0118c51a7a57`, and submission `0adf89f0-3a22-4677-8f8e-ac13a1412307`.

## Shipped implementation issues

The implementation work for #4, #5, #7, #9, and #12 is merged into `main`, included in source tag `v1.0.0`, packaged in the notarized GitHub DMG, and included in App Store build 3. Apple review and post-install observation continue through the release monitor rather than keeping shipped code issues open.
