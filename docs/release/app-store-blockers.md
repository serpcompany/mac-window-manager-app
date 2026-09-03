# Version 1.0 App Store blockers

The local candidate identity and metadata scaffold are prepared, but submission remains blocked. Do not infer or fabricate these owner/account facts:

- App Store Connect app ID, app-info ID, macOS version ID, uploaded build ID, and submission ID.
- A registered `com.serp.windowmanager` identifier and `com.serp.windowmanager.launcher` helper identifier under team `847HR8U8D9`.
- Current Apple Distribution certificate and Mac App Store provisioning profiles for both identifiers.
- Seller/legal entity and copyright text.
- Public support URL and privacy-policy URL.
- App Privacy questionnaire answers confirmed by the owner. The source audit currently finds local preferences and no candidate analytics, advertising, sign-in, or updater service; this is not authority to answer App Store Connect legal attestations.
- Age-rating questionnaire answers, territories/availability, price, category confirmation, review contact, review notes, and any demo credentials.
- Mac App Store screenshots captured from the exact signed, provisioned, installed release candidate.
- A successful strict App Store readiness validation and owner-authorized submission.

There is also a technical distribution blocker: the exact Mac App Store sandbox build must be installed and its system-wide Accessibility window-control workflow exercised. Source inspection and unit tests cannot prove that the App Sandbox permits the required AX behavior. If the sandboxed build cannot control other apps after authorization, the product is not eligible for this release lane without an Apple-approved entitlement or a different distribution decision.
