# Identifier Rules

Use this reference before writing any Android `applicationId`, Apple bundle identifier, or `flavorizr.yaml` ID. This file owns identifier validation and slug derivation; other references defer to it.

## Android

`applicationId` policy:

- At least two dot-separated segments.
- Each segment starts with a lowercase letter.
- Segment characters are lowercase letters, digits, or `_`.
- Never use `-` or uppercase.

This is stricter than raw Android build syntax on purpose. Java/Kotlin package naming, Play operations, and team consistency are cleaner with lowercase-only IDs.

## Apple (iOS and macOS)

Bundle identifier policy:

- Allowed characters are letters, digits, `-`, and `.`.
- Never use `_`.
- Identifiers are case-insensitive to Apple, but existing casing is still meaningful to the project.

Preserve existing explicit Apple bundle identifier casing. If an Apple bundle ID contains uppercase characters while Android IDs are lowercase, ask before changing Apple casing for cross-platform consistency.

Registration safety — Apple App ID global uniqueness, automatic-signing registration, personal-team hazards — is owned by the `apple-bundle-id-guardrails` skill; consult it before entering any Apple bundle ID into a signing configuration.

## Cross-Platform

Do not blindly copy one platform's ID to another when `-`, `_`, case, or segment rules differ. The same logical app usually needs `com.acme.test_app` on Android and `com.acme.test-app` on Apple platforms.

## Slug Derivation From Display Names

Prefer existing explicit IDs over derived slugs. Derive a slug only when no explicit ID exists.

When deriving:

- Propose the normalized lowercase result and ask before editing, unless the user already approved that exact ID.
- Replace only explicit separators: spaces, hyphens, and underscores.
- Do not infer word boundaries from casing.

Examples:

| Display name | Android segment | Apple segment | Note |
| --- | --- | --- | --- |
| `Test APP` | `test_app` | `test-app` | Space is an explicit separator. |
| `TestAPP` | `testapp` | `testapp` | No explicit separator; do not split on casing. |

## Example IDs

Never apply example IDs such as `com.company.appname` or `Example App` literally. Resolve real IDs from user input first, then project docs and native files. If unavailable or conflicting, ask before editing.
