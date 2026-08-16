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

## Signing Team (`DEVELOPMENT_TEAM`)

Selecting a team in Xcode's Signing & Capabilities UI writes `DEVELOPMENT_TEAM = <team-id>` into the tracked `project.pbxproj`: a public repo then commits a personal team ID, contributors inherit signing errors for a team they are not in, and every fresh checkout repeats the setup. Keep `DEVELOPMENT_TEAM` in `Local.xcconfig` alongside the bundle ID instead. A team ID is not a secret — it ships in every signed binary — so this is repo hygiene and contributor friction, not secrecy.

Harvesting the team ID (current Xcode's Accounts pane does not display it):

1. Select the team once in the Signing & Capabilities UI.
2. Read the `DEVELOPMENT_TEAM` value from `git --no-pager diff --no-color -- '*.pbxproj'`.
3. Move the value into `Local.xcconfig`.
4. Revert the `project.pbxproj` change.

## Verification

- `git grep -n "com\.acme\."` (the real org namespace) over tracked files → zero hits.
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

## Flutter and Generated Projects

The same pattern applies to `ios/Runner.xcodeproj` and `macos/Runner.xcodeproj` in Flutter projects: point flavor or generated xcconfigs (for example `ios/Flutter/Debug.xcconfig`) at the guardrail base, and keep `PRODUCT_BUNDLE_IDENTIFIER` resolving through the product-named setting. Coordinate flavor suffix policy with the `flutter-flavors` skill.
