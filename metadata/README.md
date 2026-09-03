# Window Manager App Store metadata

This is the canonical local metadata scaffold for macOS version 1.0. Validate it with:

```bash
asc metadata validate --dir ./metadata --output table
```

Before any remote plan or push, the owner must supply the missing support URL, privacy-policy URL, legal seller/copyright text, age-rating answers, review contact and notes, availability, pricing, and App Store Connect identifiers. Those values are deliberately absent rather than guessed.

No command in this repository creates an App Store Connect record, certificate, profile, version, or review submission.
