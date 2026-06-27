---
name: flutter-flavors
description: "Use when setting up, auditing, or switching Flutter flavors, flutter_flavorizr, flavorizr.yaml, and platform-specific environment identities across Android, iOS, macOS, web, Windows, and Linux, including dev/test/beta/prod app IDs, display names, launch configs, build modes, signing boundaries, and distribution safety."
---

# Flutter Flavors

Use this skill when the user asks to configure, audit, or switch Flutter flavors, build environments, app IDs, display names, launch configs, or platform-specific app identities.

## Core Rule

Flutter flavor/environment and Flutter build mode are separate axes.

- Flavor/environment defines which app identity or deployment profile is built.
- Build mode (`debug`, `profile`, `release`) defines how the Flutter runtime is compiled.
- Do not use `profile` as a synonym for `beta`.
- Do not use `release` as a synonym for `prod`.
- Do not apply example IDs (`com.company.appname`, `Example App`) literally. Resolve real IDs from user input first, then project docs/native files; if unavailable or conflicting, ask before editing.
- Validate identifiers per platform before editing. Android `applicationId` segments must start with a lowercase letter and use only lowercase letters, digits, or `_`; do not use uppercase in Android IDs. Apple bundle identifiers use letters, digits, `-`, and `.` and are case-insensitive. Do not blindly copy one platform's ID to another when `-`, `_`, case, or segment rules differ.
- If deriving an identifier slug from an app display name, propose the normalized lowercase result and ask before editing unless the user already approved that exact ID. Example: `Test APP` can become Android segment `test_app` and Apple segment `test-app`, but prefer existing explicit IDs over derived slugs.
- When deriving slugs, replace only explicit separators such as spaces, hyphens, and underscores. Do not infer word boundaries from casing; for example, propose `TestAPP` as `testapp` and ask before applying it.
- Preserve existing explicit Apple bundle identifier casing. If an Apple bundle ID contains uppercase characters while Android IDs are lowercase, ask before changing Apple casing for cross-platform consistency.
- When Flavorizr config and native platform files both exist, treat them as separate sources until reconciled. Before applying canonical or personal changes, identify which one is source of truth and update the other to match; if they conflict, ask before editing.
- Preserve unknown or extra flavors unless the user explicitly asks to remove or rename them. If applying canonical or personal policy, ask whether extra flavors should be updated, mapped, or left untouched.
- If multiple flavor meanings coexist, such as environment flavors (`dev`, `test`, `beta`, `prod`) plus custom flavors (`custom_flavor_a`, `custom_flavor_b`), ask whether to flatten combinations or keep them independent. When kept independent, add VS Code debug launch configs for custom-only flavors unless the user requests profile/release variants.

## Scope

Current bundled references cover generic Android/iOS mobile setup:

- Read `references/mobile-canonical.md` for canonical team identities.
- Read `references/mobile-personal.md` for personal Apple Developer/local device testing identities.
- Read `references/flutter-flavorizr.md` when a project already uses `flutter_flavorizr`, has `flavorizr.yaml`, or the user asks to generate/manage Flutter Flavorizr configuration.
- Read `references/example-prompts.md` only when the user asks for example prompts or usage examples.

For macOS, web, Windows, or Linux, first inspect existing project docs and native platform files. Only apply platform-specific identity changes when the requested target and source of truth are clear. Otherwise, report the likely files and ask for a platform policy.

If the user invokes only `$flutter-flavors` without a concrete task, ask for the intended action and do not edit files.

## Workflow

1. Identify requested target: canonical, personal, switch canonical to personal, switch personal to canonical, audit only, or add a new platform policy.
2. Load only the relevant reference file.
3. Inspect existing Android/iOS/macOS/web/Windows/Linux project files before editing.
4. Preserve unrelated launch configs, schemes, build files, signing settings, and app logic.
5. Stop and report when signing, export, store, CI/CD, provisioning, capabilities, notarization, package identity, or release-path decisions need human confirmation.
6. Verify with the smallest available Flutter/native check that does not require unavailable signing credentials.

## Platform Notes

- Android uses Gradle Kotlin DSL product flavors, lowercase `applicationId`, and manifest label placeholders.
- iOS and macOS use Xcode schemes/build configurations, bundle identifiers, display names, and signing settings.
- Web usually uses deployment environment/profile settings rather than a native installable flavor.
- Windows/Linux usually use package/app metadata and build-time environment profiles rather than Android-style product flavors.

## Output

Report what identity set was applied or audited, which platform files changed, which checks ran, and any human decisions still required.
