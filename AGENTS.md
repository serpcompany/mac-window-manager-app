# Agent instructions

## Mission

Maintain an independently identified, behavior-preserving fork of the MIT-licensed Rectangle macOS app.

## Boundaries

- Preserve `LICENSE` and accurate upstream attribution.
- Never restore `com.knollsoft.*`, team `XSYZ3E4B7D`, Rectangle's Sparkle key/appcast, upstream credentials, or upstream release infrastructure.
- Keep candidate preferences and Application Support data isolated from Rectangle.
- Do not claim complete parity while `scripts/validate_completion_manifest.py docs/app-replica/completion-manifest.json` is red.
- Do not mark permission-sensitive or OS-integrated behavior verified from source inspection or unit tests alone.
- Final product name, legal namespace, signing team, update service, support destination, and release destination require owner decisions.

## Verification

Run `git diff --check`, the full Xcode test suite, a clean candidate build, built-bundle identity checks, static identity searches, and the completion validator. Preserve runtime evidence under `docs/app-replica/evidence/`.

## Releases

For any version/build change, App Store submission, Git tag, or GitHub Release, follow `docs/release/local-release.md`. A release is complete only when the approved App Store version has an annotated `v<version>` tag and a published GitHub Release targeting the exact commit used for its uploaded build.
