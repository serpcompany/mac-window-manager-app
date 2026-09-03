# Contributing

Keep changes focused, preserve the existing test-backed window-calculation behavior, and add deterministic tests for behavioral changes.

Run the full suite before submitting changes:

```bash
xcodebuild -project Rectangle.xcodeproj -scheme Rectangle \
  -configuration Debug -derivedDataPath .derived \
  CODE_SIGNING_ALLOWED=NO test
```

Do not add Rectangle's bundle IDs, signing team, update keys, appcast, domains, credentials, or release destinations. Contributions remain licensed under the repository's MIT License.

Runtime claims require evidence from the exact candidate bundle. Permission, shortcut, drag-to-snap, login-item, URL, and persistence behavior cannot be marked verified from unit tests alone.
