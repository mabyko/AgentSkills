# Mobile Canonical Team Identities

Use this reference for canonical Android/iOS team identities. Replace example values with project-specific IDs and names from the user's docs or native project files.

Do not use personal/local-testing IDs in this mode.

Validate Android and Apple identifiers separately. If a project uses characters that are valid on one platform but invalid on another, keep platform-specific IDs instead of forcing one shared string. If deriving an identifier slug from a display name, propose the normalized lowercase result and ask before editing unless the user already approved that exact ID. Replace only explicit separators such as spaces, hyphens, and underscores; for example, `Test APP` can become Android segment `test_app` and Apple segment `test-app`, while `TestAPP` should be proposed as `testapp`.

Preserve existing explicit Apple bundle identifier casing. If an Apple bundle ID contains uppercase characters while Android IDs are lowercase, ask whether to preserve Apple casing or convert it for cross-platform consistency before editing.

## Example Flavor Matrix

| Flavor | Purpose | iOS Bundle ID | Android Application ID | Display Name |
| --- | --- | --- | --- | --- |
| `dev` | Local development | `com.company.appname.dev` | `com.company.appname.dev` | `Example App (DEV)` |
| `test` | Release-mode device testing outside local debug assumptions | `com.company.appname.test` | `com.company.appname.test` | `Example App (TEST)` |
| `beta` | TestFlight / Google Play testing candidate | `com.company.appname.beta` | `com.company.appname.beta` | `Example App (BETA)` |
| `prod` | App Store / Google Play production | `com.company.appname` | `com.company.appname` | `Example App` |

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

- `namespace = "com.company.appname"`
- `defaultConfig.applicationId = "com.company.appname"`
- `manifestPlaceholders["appName"] = "Example App"`

Example suffixes and labels:

- `dev`: `.dev`, `Example App (DEV)`
- `test`: `.test`, `Example App (TEST)`
- `beta`: `.beta`, `Example App (BETA)`
- `prod`: no suffix, `Example App`

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

If `.vscode/launch.json` exists, preserve existing configurations and append or merge only missing canonical entries. Use `toolArgs` for `--flavor`; use `flutterMode` only for `debug`, `profile`, or `release`.

## Safety

Signing, export, TestFlight, App Store, Google Play, and CI/CD release settings require separate human decisions. Stop and report if those settings need confirmation.

## Acceptance Checks

- `dev`, `test`, `beta`, `prod` produce distinct app identities.
- `prod` remains the canonical production ID and display name.
- `beta + debug`, `beta + profile`, and `beta + release` keep distinct meanings.
- Existing `.vscode/launch.json` entries are preserved.
- Flutter/Dart app logic is not changed.
