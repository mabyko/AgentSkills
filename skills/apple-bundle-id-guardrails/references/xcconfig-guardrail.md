# xcconfig Guardrail Setup

Goal: a clean clone builds with a sacrificial bundle ID, neither the canonical ID nor any personal `DEVELOPMENT_TEAM` exists in tracked files, and each developer overrides locally with an untracked file.

Substitute real values for `myapp`, `com.acme.myapp`, and `alice` throughout; resolve them from the user or project docs first.

## Files

`Config/Base.xcconfig` — checked in:

```xcconfig
// Build setting defaults.
//
// Bundle ID guardrail: cloning and building this repo uses the sacrificial ID
// (forked.myapp.local). The canonical ID (com.acme.myapp) exists nowhere in the
// repo, so automatic signing cannot register it by accident.
// For personal builds, create an untracked Local.xcconfig next to this file:
//
//   MYAPP_BUNDLE_ID = com.acme.myapp.<github-handle>
//   MYAPP_BUNDLE_ID[config=Debug] = com.acme.myapp.<github-handle>.dev
//   DEVELOPMENT_TEAM = <team-id>
//
MYAPP_BUNDLE_ID = forked.myapp.local

#include? "Local.xcconfig"
```

`Config/Local.xcconfig` — git-ignored, each developer creates their own:

```xcconfig
MYAPP_BUNDLE_ID = com.acme.myapp.alice
MYAPP_BUNDLE_ID[config=Debug] = com.acme.myapp.alice.dev
DEVELOPMENT_TEAM = ABCDE12345
```

Name the setting after the product (`MYAPP_BUNDLE_ID`, not `BUNDLE_ID`) so included xcconfigs from other sources cannot collide. `#include?` is the optional-include directive: a missing `Local.xcconfig` is not an error, so clean clones still build. Keep the recipe comment in `Base.xcconfig` — it is the onboarding doc teammates actually see.

## Steps

1. Create `Config/Base.xcconfig` as above.
2. Attach it as the base configuration for the project or targets: Xcode project Info tab → Configurations, or `baseConfigurationReference` in `project.pbxproj`.
3. In every target's build settings, set `PRODUCT_BUNDLE_IDENTIFIER = $(MYAPP_BUNDLE_ID)`, replacing any literal ID in `project.pbxproj`.
4. Remove any `DEVELOPMENT_TEAM` lines from `project.pbxproj`, keeping `CODE_SIGN_STYLE = Automatic`; the xcconfig value then applies as-is.
5. Add `Config/Local.xcconfig` to `.gitignore`.
6. Create the developer's own `Local.xcconfig` with their personal namespace and team ID.

## Optional Development Build Appearance

When development and release builds may be installed together, make Debug visually distinct in the checked-in base configuration:

```xcconfig
APP_DISPLAY_NAME = MyApp
APP_DISPLAY_NAME[config=Debug] = MyApp Dev
INFOPLIST_KEY_CFBundleDisplayName = $(APP_DISPLAY_NAME)

ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
ASSETCATALOG_COMPILER_APPICON_NAME[config=Debug] = AppIcon-Dev
```

Add both `AppIcon` and `AppIcon-Dev` to the asset catalog. `INFOPLIST_KEY_CFBundleDisplayName` applies when Xcode generates the Info.plist; otherwise set the checked-in plist's `CFBundleDisplayName` to `$(APP_DISPLAY_NAME)`. Set `PRODUCT_NAME = $(APP_DISPLAY_NAME)` only when the built `.app` filename must differ too. Xcode supports specializing the primary app icon for Debug and Release configurations ([Configuring your app icon](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)).

The Dock uses that primary app icon. A `MenuBarExtra` or `NSStatusItem` icon is separate: under the project's Debug compilation condition (normally `#if DEBUG`), select a distinct asset such as `MenuBarIcon-Dev`; otherwise use `MenuBarIcon`. Prefer a template image or SF Symbol so the system can adapt it to the current appearance. Skip this step when the app has no menu bar status item.

Keep these values in `Base.xcconfig`, not `Local.xcconfig`: they are shared visual cues, not signing identity. The bundle ID guardrail remains unchanged.

## Signing Team (`DEVELOPMENT_TEAM`)

Selecting a team in Xcode's Signing & Capabilities UI writes `DEVELOPMENT_TEAM = <team-id>` into the tracked `project.pbxproj`: a public repo then commits a personal team ID, contributors inherit signing errors for a team they are not in, and every fresh checkout repeats the setup. Keep `DEVELOPMENT_TEAM` in `Local.xcconfig` alongside the bundle ID instead. A team ID is not a secret — it ships in every signed binary — so this is repo hygiene and contributor friction, not secrecy.

Read the team ID from an installed signing certificate first; this does not touch Xcode's UI or `project.pbxproj`:

1. List valid code-signing identities:

   ```sh
   security find-identity -v -p codesigning
   ```

   The first value on each line is the certificate's SHA-1 digest, and the quoted value is its inferred label ([Apple SecurityTool source](https://github.com/apple-oss-distributions/SecurityTool/blob/main/identity_find.c#L192-L221)):

   ```text
   1) <certificate-sha1> "Apple Development: <email> (<certificate-id>)"
   ```

2. Use the relevant `Apple Development` label to print that certificate's subject:

   ```sh
   security find-certificate -c "Apple Development: <email>" -p \
     | openssl x509 -noout -subject
   ```

   `find-certificate -c` matches the certificate name and `-p` emits PEM ([Apple SecurityTool source](https://github.com/apple-oss-distributions/SecurityTool/blob/main/security.c#L322-L342)); OpenSSL's `-subject` prints the subject and `-noout` suppresses the encoded certificate ([OpenSSL documentation](https://docs.openssl.org/master/man1/openssl-x509/)).

3. Copy the subject's `OU=<team-id>` value into `Local.xcconfig` as `DEVELOPMENT_TEAM = <team-id>`. Apple places the Team ID in a code-signing certificate's subject `OU` field ([TN3161](https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates)).

**Identifier warning:** the parenthesized `<certificate-id>` inside `CN=Apple Development: <email> (<certificate-id>)` is a certificate-name identifier — for a certificate issued to a team member, Apple calls it the Team Member ID — not the signing Team ID. The signing Team ID is the separate `OU=<team-id>` value ([Apple: Code Signing Identifiers Explained](https://developer.apple.com/forums/thread/811970)).

Fallback when no development certificate is installed, or when certificates from multiple teams make the match ambiguous:

1. Select the intended team once in the Signing & Capabilities UI.
2. Read the `DEVELOPMENT_TEAM` value from `git --no-pager diff --no-color -- '*.pbxproj'`.
3. Move the value into `Local.xcconfig`.
4. Revert the `project.pbxproj` change.

## Verification

- `git grep -n "com\.acme\." -- '*.pbxproj' '*.xcconfig' '*.plist' '*.entitlements'` (the real org namespace, build configuration only) → zero hits. Prose documentation is exempt: a macOS app's uninstall instructions need the shipping ID for `tccutil` and the preferences path to work, and Xcode reads no markdown.
- `git grep -n "DEVELOPMENT_TEAM"` over tracked files → zero hits.
- `git check-ignore Config/Local.xcconfig` → ignored.
- `xcodebuild -showBuildSettings | grep PRODUCT_BUNDLE_IDENTIFIER` → sacrificial ID without `Local.xcconfig`, personal ID with it.

Editing Signing & Capabilities in the Xcode UI can write literal IDs and `DEVELOPMENT_TEAM` back into `project.pbxproj` — re-run both greps after any signing UI change.

## Fresh Checkouts (Clone, `git worktree`, CI)

`Local.xcconfig` is untracked, so it does not follow into a new clone, a `git worktree add` checkout, or a CI workspace. Builds there fall back to the sacrificial ID — that is the guardrail working as designed, not a bug to fix.

Never "fix" a sacrificial-ID build by typing the canonical ID into Xcode signing settings. Restore the personal identity instead by symlinking or copying the override from the main checkout:

```bash
ln -s <main-checkout>/Config/Local.xcconfig Config/Local.xcconfig
```

Keep the original in the main checkout and symlink it from each worktree; a worktree setup hook can automate the link. xcconfig `#include?` expands neither `~` nor build variables, so a shared per-user path cannot be included directly; the symlink or copy is the practical route.

## macOS Permissions (TCC)

Apps requesting Accessibility, Input Monitoring, or Screen Recording hold one TCC grant per bundle ID, keyed to the ID plus the code signature. Suffixed personal and `.dev` IDs therefore carry their own grants, isolated from an installed release's.

- Reproduce first-run behaviour by resetting the grant: `tccutil reset Accessibility com.acme.myapp.alice.dev`. Service names are the TCC key minus the `kTCCService` prefix — `Accessibility`, `ListenEvent` (Input Monitoring), `PostEvent`, `ScreenCapture`.
- **`tccutil reset` resolves the bundle ID through LaunchServices and fails with `No such bundle identifier` (OSStatus -10814) when no installed app matches.** Reset before deleting an app, never after. A grant left behind by an already-deleted app is stranded: System Settings hides rows it cannot resolve, so nothing reaches it until something with that ID is installed again. Uninstall instructions that delete the app first are broken; order them permission → app → preferences.
- Deleting an app never revokes its grant. Anything later installed under the same ID inherits it without prompting — the reason a public repo's sacrificial ID matters even for macOS-only projects that skip App ID registration.
- `UserDefaults` splits along the same line: `~/Library/Preferences/<bundle-id>.plist`, or under `~/Library/Containers/<bundle-id>/` when sandboxed. Suffixed IDs keep development settings out of the release's domain.
- Changing a bundle ID orphans both the grant and the preferences domain, so settle it before shipping.
- Writing any file inside a signed `.app` invalidates the signature (`a sealed resource is missing or invalid`), and the TCC grant keyed to that signature goes with it. Settings belong in `UserDefaults`, never in the bundle.

## Flutter and Generated Projects

The same pattern applies to `ios/Runner.xcodeproj` and `macos/Runner.xcodeproj` in Flutter projects: point flavor or generated xcconfigs (for example `ios/Flutter/Debug.xcconfig`) at the guardrail base, and keep `PRODUCT_BUNDLE_IDENTIFIER` resolving through the product-named setting. Coordinate flavor suffix policy with the `flutter-flavors` skill.
