# Flutter Flavorizr

Use this reference when a Flutter project already uses `flutter_flavorizr`, contains `flavorizr.yaml`, defines `flavorizr:` in `pubspec.yaml`, or the user explicitly asks to use Flutter Flavorizr.

Do not add `flutter_flavorizr` as a new dependency unless the user asks for Flavorizr-based generation. Prefer the existing manual platform setup when the project is already configured without Flavorizr.

## What It Manages

Flutter Flavorizr is a dev-time generator for Android, iOS, and macOS flavor setup. It reads flavor configuration and can generate or update native and Flutter files.

It supports:

- Android `applicationId`, manifest app name, icons, Firebase, res values, build config fields, and custom Gradle config.
- iOS `bundleId`, xcconfig files, schemes, build targets, Info.plist, icons, launch screens, variables, includes, and Firebase.
- macOS `bundleId`, xcconfig/config files, schemes, build targets, Info.plist, icons, variables, includes, and Firebase.
- IDE configs for VS Code or IntelliJ IDEA.

## Configuration File

Prefer a standalone `flavorizr.yaml` for new Flavorizr config. The older `pubspec.yaml` `flavorizr:` wrapper is documented as deprecated for future 3.x versions.

Minimal shape:

```yaml
flavors:
  dev:
    app:
      name: "Example App (DEV)"
    android:
      applicationId: "com.company.appname.dev"
    ios:
      bundleId: "com.company.appname.dev"
    macos:
      bundleId: "com.company.appname.dev"
```

Keep the existing project's flavor names (`dev`, `test`, `beta`, `prod`, or otherwise) unless the user asks to rename them.

## Safety

- Validate IDs using this skill's platform rules before writing `flavorizr.yaml`.
- Do not write example IDs literally.
- When `flavorizr.yaml` and native platform files both exist, do not assume either one is source of truth. Reconcile canonical/personal identity policy first; if they conflict, ask which side should win before editing.
- Preserve unknown or extra flavors in `flavorizr.yaml` unless the user explicitly asks to remove or rename them. If expected flavors are missing, ask whether to add them, map existing flavors to the expected policy, or leave the current flavor set unchanged.
- If environment flavors and custom flavors coexist, do not auto-generate the full cross-product. Ask whether to use flattened names such as `custom_flavor_a_beta` or keep independent flavors. For independent custom flavors, VS Code launch configs should default to `flutterMode: "debug"` unless the user asks for profile/release entries.
- Do not run Flavorizr on a non-clean or heavily customized project without warning; its own docs say it works better on new/clean Flutter projects.
- Do not use `-f` / `--force` unless the user explicitly approves.
- Default processors can create Flutter app entry files and pages; avoid those processors when the user only wants native platform identity setup.
- Treat signing, store release, provisioning, notarization, CI/CD, Firebase, and AGConnect config as separate decisions unless explicitly requested.

## Processor Guidance

For native identity setup only, prefer a focused processor list instead of the full default set.

Typical Android/iOS-only processors:

```bash
flutter pub run flutter_flavorizr -p android:androidManifest,android:flavorizrGradle,android:buildGradle,ios:podfile,ios:xcconfig,ios:buildTargets,ios:schema,ios:plist,ide:config
```

Add macOS processors only when macOS identities are requested:

```bash
flutter pub run flutter_flavorizr -p macos:podfile,macos:xcconfig,macos:configs,macos:buildTargets,macos:schema,macos:plist
```

Avoid processors such as `flutter:app`, `flutter:pages`, `flutter:main`, icons, launch screens, Firebase, AGConnect, or dummy assets unless the user explicitly wants those generated.

## Workflow

1. Detect existing Flavorizr usage: `pubspec.yaml`, `flavorizr.yaml`, generated flavor files, or project docs.
2. If Flavorizr is not present, ask before adding it.
3. Resolve real app IDs and display names from user input or project files.
4. Write or update `flavorizr.yaml` with platform-specific IDs.
5. Recommend the narrow processor command; do not run it automatically if it may overwrite customized files.
6. After running, inspect the generated diff before reporting success.
