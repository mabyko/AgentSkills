# Mobile Flavor Identities (Canonical and Personal)

Use this reference for Android/iOS flavor identities. Replace example values with project-specific IDs and names from the user's docs or native project files. Identifier validation and slug-derivation rules live in `identifier-rules.md`; do not restate or override them here.

Two identity sets share the same structure:

- **Canonical**: team identities for shared development and release paths.
- **Personal**: Apple Developer/local device testing identities. Never use personal IDs for TestFlight, App Store, Google Play, or CI/CD release unless a human explicitly decides that release path.

## Example Flavor Matrix

Canonical:

| Flavor | Purpose | iOS Bundle ID | Android Application ID | Display Name |
| --- | --- | --- | --- | --- |
| `dev` | Local development | `com.company.appname.dev` | `com.company.appname.dev` | `Example App (DEV)` |
| `test` | Release-mode device testing outside local debug assumptions | `com.company.appname.test` | `com.company.appname.test` | `Example App (TEST)` |
| `beta` | TestFlight / Google Play testing candidate | `com.company.appname.beta` | `com.company.appname.beta` | `Example App (BETA)` |
| `prod` | App Store / Google Play production | `com.company.appname` | `com.company.appname` | `Example App` |

Personal: use the same matrix with base ID `com.company.appname.personal` (so `dev` becomes `com.company.appname.personal.dev`, personal `prod` is `com.company.appname.personal`) and append `Personal` to display names, e.g. `Example App (DEV Personal)`, `Example App (Personal)`. Personal `prod` is production-like local testing only, never the canonical production identity.

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

Apply the Android `applicationId` policy from `identifier-rules.md`.

Example base values (canonical; for personal, append `.personal` to the IDs and `(Personal)` to the label):

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

Apply the Apple bundle identifier policy from `identifier-rules.md`.

`ios/Runner/Info.plist` should reference build settings:

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

## VS Code

If `.vscode/launch.json` exists, preserve existing configurations and append or merge only missing entries for the requested identity set. Use `toolArgs` for `--flavor`; use `flutterMode` only for `debug`, `profile`, or `release`.

## Safety

Signing, export, TestFlight, App Store, Google Play, and CI/CD release settings require separate human decisions. Stop and report if those settings need confirmation.

Personal mode additionally: before running iOS personal flavors on physical devices, confirm Apple Developer account, Bundle IDs, signing team, required capabilities, and provisioning profiles for the selected personal identifier. If Xcode requires manual signing, capability, or provisioning profile confirmation, stop and ask for human confirmation in Xcode.

## Acceptance Checks

- `dev`, `test`, `beta`, `prod` produce distinct app identities for the requested identity set.
- Canonical `prod` remains the canonical production ID and display name; personal `prod` remains production-like only and is never treated as a canonical team release ID.
- `beta + debug`, `beta + profile`, and `beta + release` keep distinct meanings.
- Existing `.vscode/launch.json` entries are preserved.
- Flutter/Dart app logic is not changed.
