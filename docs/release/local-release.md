# Release runbook

## Candidate

- Product: Window Manager
- Platform: macOS
- Main bundle ID: `com.serp.windowmanager`
- Login item: `com.serp.windowmanager.launcher`
- Team: `847HR8U8D9`
- App Store Connect app ID: `6808371833`
- Category configured in the bundle: Productivity

Release configurations use Apple Distribution signing and sandboxed release entitlements for both the main app and launcher. Local unsigned builds can verify compilation and identity, but they are not submission artifacts.

## 1. Prepare and submit the App Store build

Start from a clean `main` synchronized with `origin/main`. Set `VERSION` to the Xcode marketing version and preserve `RELEASE_COMMIT` with the build evidence; that commit is the later tag target.

```bash
VERSION="1.1"
APP_ID="6808371833"
RELEASE_COMMIT="$(git rev-parse HEAD)"

APP_STORE_PROFILE_SPECIFIER="Window Manager Mac App Store" \
APP_STORE_LAUNCHER_PROFILE_SPECIFIER="Window Manager Launcher Mac App Store" \
scripts/archive_app_store.sh
asc metadata validate --dir ./metadata --output table
asc metadata plan --app "$APP_ID" --version "$VERSION" --platform MAC_OS --dir ./metadata --review-dir .asc/metadata/review
```

Complete the normal App Store upload, readiness validation, dry run, and confirmed review submission. Record the version ID, build ID, submission ID, and `RELEASE_COMMIT` under `docs/app-replica/evidence/`.

## 2. Publish the matching GitHub prerelease

Once Apple accepts the review submission and reports it as waiting for or in review, run the GitHub release harness once without `--confirm` and inspect its target:

```bash
scripts/publish_github_release.sh "$VERSION" "$RELEASE_COMMIT"
```

Publish the tag and prerelease after the preflight names the intended version, commit, tag, and App Store state:

```bash
scripts/publish_github_release.sh "$VERSION" "$RELEASE_COMMIT" --confirm
```

To supply curated release notes, add `--notes-file path/to/release-notes.md` to both commands. Otherwise GitHub generates notes from merged changes.

The harness creates and pushes an annotated `v<version>` tag, then publishes a matching GitHub prerelease in `serpcompany/mac-window-manager-app`. It is resumable when the correct tag or release already exists. It never attaches the exported `.pkg`: Mac App Store packages are receipt-bound submission artifacts, not direct-download installers.

## 3. Promote after Apple release

When Apple reports `READY_FOR_DISTRIBUTION` (or legacy `READY_FOR_SALE`), run the same preflight and confirmed command again. The harness verifies that the tag still targets the uploaded build commit and promotes the existing prerelease to a full, latest GitHub Release.

## Completion

A release is complete when all of these are recorded and agree:

- App Store version and uploaded build
- exact source commit used for that build
- annotated `v<version>` tag resolving to that commit
- published, non-draft GitHub Release for that tag; prerelease while Apple review is pending, full release after Apple distribution
- App Store and runtime evidence required by `AGENTS.md`
