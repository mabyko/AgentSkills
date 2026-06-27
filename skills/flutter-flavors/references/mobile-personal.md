# Mobile Personal Testing Identities

Use this reference for personal Apple Developer/local device testing identities. Replace example values with project-specific IDs and names from the user's docs or native project files.

This is not canonical team release identity. Do not use personal IDs for TestFlight, App Store, Google Play, or CI/CD release unless a human explicitly decides that release path.

Validate Android and Apple identifiers separately. If a project uses characters that are valid on one platform but invalid on another, keep platform-specific IDs instead of forcing one shared string. If deriving an identifier slug from a display name, propose the normalized lowercase result and ask before editing unless the user already approved that exact ID. Replace only explicit separators such as spaces, hyphens, and underscores; for example, `Test APP` can become Android segment `test_app` and Apple segment `test-app`, while `TestAPP` should be proposed as `testapp`.

Preserve existing explicit Apple bundle identifier casing. If an Apple bundle ID contains uppercase characters while Android IDs are lowercase, ask whether to preserve Apple casing or convert it for cross-platform consistency before editing.

## Example Flavor Matrix

| Flavor | Purpose | iOS Bundle ID | Android Application ID | Display Name |
| --- | --- | --- | --- | --- |
| `dev` | Local development with debug tooling | `com.company.appname.personal.dev` | `com.company.appname.personal.dev` | `Example App (DEV Personal)` |
| `test` | Local/internal release-mode device testing | `com.company.appname.personal.test` | `com.company.appname.personal.test` | `Example App (TEST Personal)` |
| `beta` | Personal-account beta-like testing only | `com.company.appname.personal.beta` | `com.company.appname.personal.beta` | `Example App (BETA Personal)` |
| `prod` | Personal-account production-like local testing only | `com.company.appname.personal` | `com.company.appname.personal` | `Example App (Personal)` |

## Command Matrix

```bash
flutter run --flavor dev --debug
flutter run --flavor test --release
flutter run --flavor beta --debug
flutter run --flavor beta --profile
flutter build apk --flavor beta --release
flutter build appbundle --flavor prod --release
flutter build ios --flavor test --release
flutter build ipa --flavor beta --release
flutter build ipa --flavor prod --release
```

## Android

Use Kotlin DSL in `android/app/build.gradle.kts`. Configure an `environment` flavor dimension and product flavors `dev`, `test`, `beta`, `prod`.

Android `applicationId` policy: at least two dot-separated segments, each segment starts with a lowercase letter, and segment characters are lowercase letters, digits, or `_`. Do not use `-` or uppercase in Android IDs. This is stricter than the raw Android build syntax on purpose; Java/Kotlin package naming, Play operations, and practical team consistency are cleaner with lowercase-only IDs.

Example base values:

- `namespace = "com.company.appname.personal"`
- `defaultConfig.applicationId = "com.company.appname.personal"`
- `manifestPlaceholders["appName"] = "Example App (Personal)"`

Example suffixes and labels:

- `dev`: `.dev`, `Example App (DEV Personal)`
- `test`: `.test`, `Example App (TEST Personal)`
- `beta`: `.beta`, `Example App (BETA Personal)`
- `prod`: no suffix, `Example App (Personal)`

`android/app/src/main/AndroidManifest.xml` should use:

```xml
<application
    android:label="${appName}"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
</application>
```

## iOS

Represent flavor identity with schemes/build configurations that set:

- `PRODUCT_BUNDLE_IDENTIFIER`
- `APP_DISPLAY_NAME`

Apple bundle identifiers allow letters, digits, `-`, and `.` and are case-insensitive. Do not use `_` in Apple bundle IDs.

`ios/Runner/Info.plist` should reference build settings:

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

## VS Code

If `.vscode/launch.json` exists, preserve existing configurations and append or merge only missing personal entries. Use `toolArgs` for `--flavor`; use `flutterMode` only for `debug`, `profile`, or `release`.

## Safety

Before running iOS personal flavors on physical devices, confirm Apple Developer account, Bundle IDs, signing team, required capabilities, and provisioning profiles for the selected personal identifier.

If Xcode requires manual signing, capability, or provisioning profile confirmation, stop and ask for human confirmation in Xcode.

## Acceptance Checks

- `dev`, `test`, `beta`, `prod` produce distinct personal app identities.
- Personal `prod` remains the personal production-like ID and display name.
- Personal IDs are not treated as canonical team release IDs.
- `beta + debug`, `beta + profile`, and `beta + release` keep distinct meanings.
- Existing `.vscode/launch.json` entries are preserved.
- Flutter/Dart app logic is not changed.
