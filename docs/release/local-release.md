# Local release preparation

## Candidate

- Product: Window Manager
- Version/build: 1.0 (1)
- Platform: macOS
- Main bundle ID: `com.serp.windowmanager`
- Login item: `com.serp.windowmanager.launcher`
- Team: `847HR8U8D9`
- Category configured in the bundle: Productivity

Release configurations use Apple Distribution signing and sandboxed release entitlements for both the main app and launcher. Local unsigned builds can verify compilation and identity, but they are not submission artifacts.

## Owner-authorized release sequence

Only after the blockers are resolved and a dry run is reviewed:

```bash
APP_STORE_PROFILE_SPECIFIER="Window Manager Mac App Store" \
APP_STORE_LAUNCHER_PROFILE_SPECIFIER="Window Manager Launcher Mac App Store" \
scripts/archive_app_store.sh
asc metadata validate --dir ./metadata --output table
asc metadata plan --app "$APP_ID" --version 1.0 --platform MAC_OS --dir ./metadata --review-dir .asc/metadata/review
```

The repository intentionally contains no command with `--confirm` and performs no remote mutation by itself.
