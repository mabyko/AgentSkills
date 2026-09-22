# xcconfig Guardrail Setup

Goal before organization registration: every app, extension, and widget resolves to a distinct sacrificial bundle ID without local overrides. Tracked active build/signing values contain neither the organization namespace nor a personal `DEVELOPMENT_TEAM`; documentation and comments may describe them. Each developer overrides locally with an untracked file.

Substitute real values for `myapp`, `com.acme.myapp`, and `alice` throughout; resolve them from the user or project docs first.

## Files

`Config/Base.xcconfig` — checked in:

```xcconfig
// Build setting defaults.
//
// Bundle ID guardrail: cloning and building this repo uses the sacrificial ID
// (forked.myapp.local). The canonical ID is absent from active build settings,
// so automatic signing cannot register it by accident.
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

Name the setting after the product (`MYAPP_BUNDLE_ID`, not `BUNDLE_ID`) so included xcconfigs from other sources cannot collide. `#include?` is the optional-include directive: a missing `Local.xcconfig` is not an include error. Device builds may still require local signing credentials. Keep the recipe comment in `Base.xcconfig` — it is the onboarding doc teammates actually see.

## Steps

1. Create `Config/Base.xcconfig` as above.
2. Integrate it with the existing configuration chain for the requested targets. Preserve existing base configurations and generated includes; include the guardrail from them where appropriate.
3. Set the main app's `PRODUCT_BUNDLE_IDENTIFIER = $(MYAPP_BUNDLE_ID)`. Preserve each extension/widget suffix: for example, an existing `.widget` target becomes `$(MYAPP_BUNDLE_ID).widget`. Give independent apps their own product-named settings and sacrificial defaults. Record the target-to-ID mapping; never assign all targets the same complete ID.
4. Remove any `DEVELOPMENT_TEAM` lines from `project.pbxproj`, keeping `CODE_SIGN_STYLE = Automatic`; the xcconfig value then applies as-is.
5. Add `Config/Local.xcconfig` to `.gitignore`.
6. Create the developer's own `Local.xcconfig` with their personal namespace and team ID.

## Optional Development Build Name

When development and release builds may be installed together, give Debug a distinct display name in the checked-in base configuration:

```xcconfig
APP_DISPLAY_NAME = MyApp
APP_DISPLAY_NAME[config=Debug] = MyApp Dev
INFOPLIST_KEY_CFBundleDisplayName = $(APP_DISPLAY_NAME)
```

`INFOPLIST_KEY_CFBundleDisplayName` applies when Xcode generates the Info.plist; otherwise set the checked-in plist's `CFBundleDisplayName` to `$(APP_DISPLAY_NAME)`. Set `PRODUCT_NAME = $(APP_DISPLAY_NAME)` only when the built `.app` filename must differ too. Keep shared name defaults in `Base.xcconfig`; identity-specific names may override them as described below. The bundle ID guardrail remains unchanged.

## Multiple Teams and Build Modes

Use only the identities requested. Personal, Team B, and organization identities can each have Release and Debug builds; additional teams follow the same pattern. These are naming conventions, not Apple-defined categories. Preserve existing IDs unless migration is requested.

| Identity | Mode | Example bundle ID | Signing team | Example display name |
| --- | --- | --- | --- | --- |
| Personal | Release | `com.acme.myapp.alice` | Developer's chosen team | MyApp Alice |
| Personal | Debug | `com.acme.myapp.alice.dev` | Same personal team | MyApp Alice Dev |
| Team B | Release | `com.acme.myapp.teamb` | Team owning the Team B IDs | MyApp B |
| Team B | Debug | `com.acme.myapp.teamb.dev` | Same Team B signing team | MyApp B Dev |
| Organization | Release | `com.acme.myapp` | Organization team | MyApp |
| Organization | Debug | `com.acme.myapp.dev` | Organization team | MyApp Dev |

Resolve Team B's actual Apple Team ID separately from its label. An internal B team may share the organization's Team ID; a separate Apple Developer team uses its own. Validate suffixes and reject collisions across all requested identities and targets. Preserve extension/widget suffixes after the complete app ID, for example `com.acme.myapp.teamb.dev.widget`.

Register the requested organization IDs under the organization team before enabling that identity, including Debug when requested. Verify existing Team B IDs belong to its selected team; register new shared Team B IDs under that team before enabling them. A bundle ID plus a different `DEVELOPMENT_TEAM` does not create a second app identity or transfer ownership. See [Apple's App ID registration guidance](https://developer.apple.com/help/account/identifiers/register-an-app-id). Release alone does not select an App Store/TestFlight distribution workflow.

For local switching, keep the existing Debug/Release configurations and the optional `Local.xcconfig` include. Store each requested identity in a separate file under git-ignored `Config/Identities/`. Each file defines the Release and Debug IDs, signing team, and display names together. For example, `Config/Identities/TeamB.xcconfig`:

```xcconfig
MYAPP_BUNDLE_ID = com.acme.myapp.teamb
MYAPP_BUNDLE_ID[config=Debug] = com.acme.myapp.teamb.dev
DEVELOPMENT_TEAM = <team-b-apple-team-id>
APP_DISPLAY_NAME = MyApp B
APP_DISPLAY_NAME[config=Debug] = MyApp B Dev
```

Use the corresponding matrix values for personal and organization files. Substitute actual Team IDs before use. In `Base.xcconfig`, place the shared display-name defaults and Info.plist mapping **before** `#include? "Local.xcconfig"`, so the selected identity's names override them. Keep `PRODUCT_BUNDLE_IDENTIFIER` derived from `MYAPP_BUNDLE_ID` for all targets; remove higher-priority target/project literals that mask the selected ID, team, or display name.

Make `Config/Local.xcconfig` select exactly one identity, replacing any previous inline identity settings:

```xcconfig
#include "Identities/TeamB.xcconfig"
```

Use a required include here: an explicitly selected but missing identity must produce a configuration diagnostic rather than silently selecting another identity. Xcode supports nested includes and configuration conditions; see [Apple's xcconfig guidance](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project). Keep `Config/Local.xcconfig` and `Config/Identities/` git-ignored. Before organization registration, tracked active values still contain only sacrificial IDs and no signing team.

If one-click scheme selection or CI needs all identities available together, reuse the project's existing scheme/configuration or flavor structure; add named configurations only when needed. Match conditional settings to their actual names (`[config=Debug]` does not cover `Debug-TeamB`). After organization registration, shared team configurations may be tracked for exact IDs already owned by the intended team; keep personal values local and fresh-checkout defaults sacrificial. Check Run, Test, Profile, and Archive mappings explicitly so an archive uses the requested identity and build mode.

Verify every requested identity in both modes using resolved build settings, including `DEVELOPMENT_TEAM`, display name, and each extension/widget ID. Check ID-bound entitlements and provisioning profiles against the selected team; resolve any App Group, keychain group, or iCloud sharing intentionally. Without local overrides, confirm sacrificial IDs and no inherited personal/team signing value. Preserve the user's original selection after checks.

## Signing Team (`DEVELOPMENT_TEAM`)

Selecting a team in Xcode's Signing & Capabilities UI writes `DEVELOPMENT_TEAM = <team-id>` into the tracked `project.pbxproj`: a public repo then commits a personal team ID, contributors inherit signing errors for a team they are not in, and every fresh checkout repeats the setup. For local identities, keep `DEVELOPMENT_TEAM` alongside the bundle ID in `Local.xcconfig` or its selected identity file instead. Registered shared-team configurations may be tracked as described above. A team ID is not a secret — it ships in every signed binary — so this is repo hygiene and contributor friction, not secrecy.

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

- Search tracked project files, xcconfigs, plists, entitlements, export options, and CI configuration for the real organization namespace and `DEVELOPMENT_TEAM`. Inspect each hit: before organization registration, active build/signing values must contain no organization namespace or personal team ID. Documentation, comments, and variable references are allowed; zero raw text matches is not the acceptance criterion.
- `git check-ignore Config/Local.xcconfig` → ignored.
- Inspect resolved build settings for the actual schemes/configurations and every affected app, extension, and widget: distinct sacrificial IDs without `Local.xcconfig`, the selected personal/team/organization IDs with it, preserving target suffixes and checking `DEVELOPMENT_TEAM`. Run an available unsigned or simulator build and report any signing verification that could not run.
- With `Local.xcconfig`, compare the side-by-side identity settings:

  ```sh
  for configuration in Debug Release; do
    xcodebuild -configuration "$configuration" -showBuildSettings \
      | grep -E 'PRODUCT_BUNDLE_IDENTIFIER|DEVELOPMENT_TEAM|APP_DISPLAY_NAME'
  done
  ```

  Debug and Release must resolve to different bundle IDs and display names, and the intended signing team for each identity. For multiple identities, repeat with each selection; supply the actual project/workspace and scheme when needed.

Editing Signing & Capabilities in the Xcode UI can write literal IDs and `DEVELOPMENT_TEAM` back into `project.pbxproj` — repeat the active-value audit after any signing UI change.

## Fresh Checkouts (Clone, `git worktree`, CI)

`Local.xcconfig` is untracked, so it does not follow into a new clone, a `git worktree add` checkout, or a CI workspace. Builds there fall back to the sacrificial ID — that is the guardrail working as designed, not a bug to fix.

Never "fix" a sacrificial-ID build by typing the canonical ID into Xcode signing settings. Restore the personal identity instead by symlinking or copying the override from the main checkout:

```bash
ln -s <main-checkout>/Config/Local.xcconfig Config/Local.xcconfig
```

Keep the original in the main checkout and symlink it from each worktree; a worktree setup hook can automate the link. xcconfig `#include?` expands neither `~` nor build variables, so a shared per-user path cannot be included directly; the symlink or copy is the practical route.

When `Local.xcconfig` selects an identity file, also make its `Config/Identities/` dependency available in the new checkout. Copy or link the matching directory together with the selector, preserving relative include paths. CI must select the intended identity explicitly rather than inherit a developer's current local selection.

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
