---
name: apple-bundle-id-guardrails
description: "Use when creating a new Xcode or mobile app project, choosing an Apple bundle ID / App ID or signing team, setting up personal, additional-team, or organization Release/Debug identities, configuring macOS TCC permissions, auditing identifier leaks, or resolving App ID registration errors."
---

# Apple Bundle ID Guardrails

This skill owns Apple registration safety and works independently of Flutter. Treat identity (personal, additional team, organization) and build mode (Release, Debug) as separate choices; select the bundle ID and signing team together. Release is a build mode, not permission to publish. Before writing an Apple bundle ID, allow only letters, digits, hyphens, and dots; preserve existing casing and target suffixes. Validate derived IDs before use; preserve existing IDs unless migration is requested.

## Why This Exists

App IDs (explicit bundle IDs) are globally unique across the entire Apple Developer Program, across all teams. Merely running an iOS app on a device lets Xcode automatic signing register the App ID to the currently selected team — including a free personal team, which cannot access the portal Identifiers list, so a wrongly registered ID is hard to reclaim. macOS builds usually skip registration unless a restricted entitlement requires a provisioning profile (TN3125), but apply the same rules to macOS conservatively.

macOS carries a second, independent hazard that does not depend on registration at all. TCC permission grants (Accessibility, Input Monitoring, Screen Recording) are keyed to bundle ID plus code signature, and `UserDefaults` domains are keyed to bundle ID alone. One ID shared between a development build and an installed release means one grant and one preferences domain between them, each overwriting the other — and since macOS never revokes a grant when an app is deleted, a build silently inherits whatever that ID was granted before. Suffixed personal and `.dev` IDs isolate both. Details and the `tccutil` workflow: `references/xcconfig-guardrail.md`.

## Rules

1. Keep the organization's Release ID (`com.<org>.<product>`) and any requested organization Debug ID (`<canonical>.dev`) out of active signing configurations until that organization team has registered each exact ID. A `.dev` suffix does not make an organization-owned ID safe for a personal or another team's signing configuration.
2. New personal development identities use `<canonical>.<github-handle>`; development builds append `.dev` (example shape: `com.acme.myapp.alice.dev`). App ID uniqueness is exact-string, so registering a suffixed ID never blocks the canonical one — a mistake's blast radius is one personal suffix.
3. The first action after the organization team opens is to register every requested organization App ID to it, including Debug and target suffixes. After registration, these IDs may enter the matching organization's configurations; keep personal overrides and side-by-side identity isolation where needed.
4. Before organization registration, repos — public ones especially — carry the canonical ID in no active build or signing configuration: an outside contributor's automatic signing could try to register it. Documentation and non-executable comments are exempt; audit effective setting values, not text mentions. Rule 5 is the mechanism.
5. Before organization registration, check in only a sacrificial ID with no organization namespace (convention: `forked.<product>.local`) and no `DEVELOPMENT_TEAM`; personal and additional-team identities live in git-ignored xcconfig overrides. Setup procedure: `references/xcconfig-guardrail.md`.
6. Additional teams use a distinct validated suffix, such as `<canonical>.teamb` and `<canonical>.teamb.dev`. A team label is not an Apple Team ID: determine whether it means another Apple Developer team or an internal group sharing the organization's team. Check each ID's intended owner; changing `DEVELOPMENT_TEAM` alone does not transfer an App ID. Read **Multiple Teams and Build Modes** in `references/xcconfig-guardrail.md` for the identity matrix and selection procedure.

Resolve real org, product, github-handle, team suffix, and signing-team values from the user or project docs before writing anything; never apply the example IDs literally. Check the full target-to-ID mapping for collisions, including personal handles, team suffixes, and extensions.

## Workflow

1. Identify the branch: new-project or retrofit setup, side-by-side Release/Debug identity, multiple-team setup or switching, audit, personal-ID choice, org-team handover, or registration-error recovery.
2. Setup before organization registration (new project or retrofit): follow `references/xcconfig-guardrail.md`. Done when each app, extension, and widget resolves to its own sacrificial ID without the local override, and tracked active build/signing values contain neither the organization namespace nor a personal team ID. Verify the available unsigned or simulator build separately; report unavailable signing checks.
3. Side-by-side or multiple-team identity: follow **Multiple Teams and Build Modes** and **Optional Development Build Name** in `references/xcconfig-guardrail.md`. Done when each requested identity/mode resolves to its intended ID, signing team, and distinct display name, with preserved target suffixes and a safe fresh-checkout fallback.
4. Audit: search every tracked file — `project.pbxproj`, `*.xcconfig`, `*.plist`, `*.entitlements`, export options, CI configs — for the org namespace and for `DEVELOPMENT_TEAM` literals. Classify hits as active settings or documentation/comments. Flag unregistered organization IDs and ID/team ownership mismatches, and personal team literals as hygiene issues; include file and line evidence and confirm local overrides are git-ignored.
5. Org-team handover checklist:
   - Enumerate every requested organization Release and Debug ID: each app, plus each extension and widget, is its own App ID.
   - Register each in the org team's portal (Certificates, Identifiers & Profiles → Identifiers).
   - Only then move those IDs into the matching organization's signing configs and release lanes; personal and additional-team identities keep their own IDs and team mappings.
6. Recovery from "An App ID with Identifier … is not available" / "Failed to register bundle identifier": the ID is already registered to some team. If a team you control owns it, delete it from that team's Identifiers list to release it. A free personal team cannot see Identifiers — treat that ID as burned and switch to a suffixed personal ID.

## Output

Report which branch ran, the identity × build-mode mapping (bundle ID, signing team, display name), the sacrificial fallback, every file changed or flagged, and any unresolved team ownership or registration. Use team selections and registration evidence already supplied; ask only for missing decisions or authorization for portal changes.
