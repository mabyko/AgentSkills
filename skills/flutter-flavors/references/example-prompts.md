# Example Prompts

Use these prompts as starting points. Replace app names, IDs, and scope with the real project values.

## Canonical Mobile Setup With Explicit IDs

```text
Use $flutter-flavors to set up Android and iOS flavors for canonical team builds.

App display name: Test APP
Android base applicationId: com.acme.test_app
iOS base bundle identifier: com.acme.test-app

Create dev, test, beta, and prod identities.
Do not change signing, store, or CI/CD settings.
Preserve existing unrelated launch configs and app logic.
```

## Canonical Mobile Setup From App Name

```text
Use $flutter-flavors to set up Android and iOS flavors for TestAPP.

I have not chosen final app IDs yet.
Please inspect existing project docs and native files first.
If no source of truth exists, propose Android and iOS IDs before editing.
```

## Audit Existing Setup

```text
Use $flutter-flavors to audit the current Android/iOS flavor setup.

Check dev, test, beta, and prod app identities, display names, VS Code launch configs, and build mode usage.
Do not edit files; report mismatches and questions only.
```

## Switch Personal To Canonical

```text
Use $flutter-flavors to switch the current Android/iOS setup from personal testing IDs to canonical team IDs.

Use project docs and native files as source of truth.
Do not change Flutter/Dart app logic.
Do not change signing, export, TestFlight, App Store, Google Play, or CI/CD settings without asking.
```

## Personal Device Testing

```text
Use $flutter-flavors to configure personal Apple Developer/local device testing identities for Android and iOS.

This is not a TestFlight, App Store, Google Play, or CI/CD release setup.
Stop if Xcode signing, provisioning, capabilities, or profiles require manual confirmation.
```

## Invalid Shared ID Check

```text
Use $flutter-flavors to review this proposed ID policy before editing:

Use com.acme.test-app for all platforms.

Tell me whether Android and iOS need different IDs and propose valid alternatives.
```

## macOS Extension

```text
Use $flutter-flavors to extend the existing dev/test/beta/prod setup to macOS.

Inspect macos/ and existing project docs first.
If macOS bundle IDs, display names, signing, or notarization policy are missing, ask before editing.
```

## Web, Windows, And Linux Planning

```text
Use $flutter-flavors to plan dev/test/beta/prod support for web, Windows, and Linux.

Do not edit yet.
Inspect existing platform files and report what identity/profile/package metadata policy is needed for each platform.
```

## Flutter Flavorizr Config

```text
Use $flutter-flavors to create a Flutter Flavorizr config for Android, iOS, and macOS.

Use flavorizr.yaml, not pubspec.yaml flavorizr wrapper.
Do not run the generator yet.
Use dev, test, beta, and prod.
Ask before deriving app IDs from the app display name.
Avoid generating Flutter pages, main files, icons, launch screens, Firebase, or AGConnect unless I ask.
```

## Merge Environment And Variant Flavors

```text
Use $flutter-flavors to merge dev/test/beta/prod into an existing flavorizr.yaml that already has custom_flavor_a and custom_flavor_b.

Keep custom_flavor_a and custom_flavor_b as independent custom flavors.
Do not generate custom_flavor_a_dev or custom_flavor_b_beta combinations.
For .vscode/launch.json, add custom_flavor_a and custom_flavor_b as debug-only launch configs unless I ask for profile/release entries.
```
