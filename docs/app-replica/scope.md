# Rectangle Clone scope

## Authorization and source

The owner asked on 2026-09-04 for a clone/fork of the open-source Rectangle app and explicitly identified <https://github.com/rxhanson/Rectangle> as the source. Rectangle is MIT licensed. The retained `LICENSE` file governs reused source and assets.

- Authoritative source: `https://github.com/rxhanson/Rectangle`
- Frozen source commit: `bf86a4b7d3dd246b895f149a99b39bcb89f22bfd`
- Source version/build at that commit: `1.100` / `106`
- Local behavioral reference: `/Applications/Rectangle.app`
- Installed reference identity: `com.knollsoft.Rectangle`
- Installed reference version/build: `0.98` / `104`
- Installed executable SHA-256: `6049540f3467cc190415b52af152795d41f83ef6c70447a0e162c42079ec633a`
- Installed architecture: universal `arm64` + `x86_64`
- Installed minimum macOS: `10.15`
- Installed signature: Developer ID Application, team `XSYZ3E4B7D`, notarized and stapled

The source commit is the functional baseline. The older installed build is supporting behavioral and visual evidence; any source/reference difference is recorded rather than guessed.

## Candidate identity

- Working product name: **Rectangle Clone**
- Working bundle identifier: `co.serp.rectangleclone`
- Working URL scheme: `rectangleclone`
- Intended use: an independently buildable, rebranded macOS window manager derived from the licensed Rectangle source
- Distribution: local development artifact signed with the owner's existing Developer ID identity; notarization, update infrastructure, final name, and public-release destination remain owner decisions

## Literal finish line

This is an unqualified clone request, so the claim is `complete-reference`: preserve every reachable behavior from the frozen source while separating product identity and operator-controlled infrastructure. No functional exclusions have been approved.

The first acceptance unit is: launch the exact candidate bundle, satisfy Accessibility authorization, move a normal app window to the left half using the menu or shortcut, restore it, quit/relaunch, and repeat successfully with candidate preferences isolated from Rectangle.

## Frozen observation environment

- macOS `26.5.2` build `25F84`
- Apple M3 Max
- Built-in 3456 × 2234 Retina display
- Theme: Dark
- Locale: `en_US`
- Installed reference default surface captured at `docs/app-replica/evidence/0.98/reference/settings-shortcuts-default-dark.jpeg`
- Accessibility permission is identity-sensitive and must be verified against the final candidate bundle, not inherited from Rectangle.

## Private or dynamic data

User shortcut preferences, ignored-app lists, logs, window titles, and filesystem paths are dynamic. Evidence must avoid copying private values where they are not necessary to prove behavior.

## Explicit non-claims

The candidate is not Rectangle, is not endorsed by Rectangle's authors, and must not use their signing identity, bundle IDs, update keys, appcast, domains, support channels, or release infrastructure. Final trademark clearance and final original brand artwork remain owner decisions.
