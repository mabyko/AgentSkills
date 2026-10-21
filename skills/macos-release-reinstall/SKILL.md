---
name: macos-release-reinstall
description: "Reinstall or replace a project's installed macOS app with a Release build, preserving the working installation and user data through verification, then deleting temporary rollback backups unless the user requests retention."
---

# macOS Release Reinstall

Build or obtain the requested Release, replace the identified installation safely, and verify it at its installed path. A request to author, review, or test this skill does not authorize changing installed apps. Development/QA app cleanup is a separate task; perform it only when requested, using `macos-dev-app-cleanup` if available.

## 1. Identify the installation and Release source

Reuse the user's project/worktree, requested revision or artifact, installation path, and existing authorization. Inspect project build instructions and effective configuration rather than guessing from an app name or a `Release` directory. When no revision is specified, use the current worktree and disclose uncommitted changes included in the build; do not silently substitute another checkout or downloaded release.

Record the exact installed bundle path, canonical path, bundle ID, executable, version/build, signing identity/entitlements, and running instances/helpers. Resolve ancestor symlinks and stop on an unexpected redirected destination. If multiple installations make the target ambiguous, inspect further or ask before replacing any of them. Preserve other installed copies and unrelated apps.

Identify relevant preferences domains, custom suites, Containers/Group Containers, Application Support, user-selected storage, and any app-managed data inside the bundle. Preserve documents, Keychain items, permission records, downloaded engines, presets, history, and shared settings. Reinstallation does not authorize defaults resets, data-directory deletion, or clearing TCC permissions.

Explain the selected source, destination, protected data, and temporary rollback policy before mutation. A clear reinstall request authorizes these steps without another approval question. A preview-only request stays read-only.

**Done:** the source and single replacement destination are evidenced; data locations and other installations to preserve are identified.

## 2. Prepare and validate before replacing

Use the project's Release build/package workflow, including required helpers and resources. For a provided artifact, verify its origin and Release provenance. Build and stage outside the installed bundle; leave the existing installation usable if preparation fails.

Check the staged bundle's ID, executable, version/build, host architecture/OS compatibility, resources/helpers, and code signature against the intended configuration. Release configuration alone does not imply Developer ID signing or notarization: a project may use local ad-hoc signing. Preserve the intended identity, entitlements, and data access; resolve unexpected changes before installation. Do not change signing teams/bundle IDs, re-sign a supplied artifact, strip quarantine, or disable security controls to make verification pass.

Ad-hoc signing ties code identity to a specific build, so privacy permissions and Keychain trust may require user authorization again after replacement; see [Apple TN3127](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements). Explain this before mutation, leave authorization prompts to the user, and report any required reauthorization instead of claiming permissions remained effective.

Inspect build/install scripts before running them when they can overwrite the destination or alter user data. Check space and destination write access before stopping the app. Report permission limitations instead of automatically escalating to `sudo` or choosing another install path.

If the candidate, newer or older, can migrate or reset data the other build cannot read, establish a scoped recovery plan before launching. Check data compatibility even when local builds share version numbers. Use a consistent temporary data snapshot when needed; do not treat a copy of a live database as a valid backup. An app-bundle backup alone cannot undo a data migration.

**Done:** a complete, validated Release candidate exists independently of the installed app, and rollback can protect the identified data.

## 3. Replace with a temporary rollback copy

1. Match running instances by actual bundle/executable path and fresh process identity, including helpers. Use an available native mechanism to request normal quit of that exact instance. Verify exit with a bounded wait. A name or shared bundle ID alone is insufficient. If quitting is canceled, a save prompt appears, or a helper remains active, preserve the installation and pause replacement; do not force-quit or discard work.
2. Recheck destination identity and capture the quiescent data baseline using metadata or fingerprints without printing private values or file contents. Create a unique, private transaction directory and record every staging/backup path created by this run. Keep the old bundle recoverable before replacing it. Prefer a private directory on the destination's filesystem outside visible Applications folders, verifying the filesystem before relying on a rename. Preserve bundle metadata, permissions, symlinks, and extended attributes with a suitable macOS copy method. Verify any copied rollback bundle before proceeding. Carry forward any mutable data inside the old bundle only through the project's supported layout without invalidating the candidate signature; if that is unresolved, stop before replacement.
3. Install the complete staged bundle at the reviewed destination. Before each install or restore rename, confirm the destination path is absent; move an existing bundle to its reviewed transaction path first. Renaming onto an existing directory can nest the bundle instead of replacing it. Never merge new files into the old bundle: obsolete files can survive and signatures can break. Use individually checked operations with quoted exact paths and explicit error handling. Do not put rollback deletion in an unconditional exit trap or chained success-looking cleanup.
4. If copying, replacement, or subsequent verification fails, normally quit any newly started app/helpers and verify their exit before restoring the previous bundle at its original path. If they cannot exit safely, pause recovery with both bundles protected. Keep recovery paths available until restoration is verified. If startup has already changed data, follow the recovery plan; do not blindly overwrite newer user data with a snapshot. After restoration, apply the **Recovery cleanup** rule in step 5 and report the reinstall as unsuccessful; do not continue as though the new Release passed.

**Done:** either the new bundle occupies the original installation path with rollback available, or the previous installation has been restored and verified. Report incomplete recovery with exact remaining paths.

## 4. Verify the installed app and user state

Verify the installed bundle matches the staged Release, including executable/resources/helpers and valid signatures. Compare protected data with the quiescent baseline before launch. Launch the exact installed path, not a build/staging/backup copy or an app selected only by bundle ID.

Confirm the running executable's actual path, expected version/build, and that the app remains responsive through startup. Perform a small app-appropriate smoke check with disposable inputs outside user data; include an essential embedded helper/engine when applicable. A successful copy, `open` exit code, or process appearing briefly is insufficient. For menu-bar/background apps, check their expected status item or service behavior rather than requiring a main window.

Confirm existing settings and relevant data remain available. Distinguish expected runtime writes or documented migrations from unexpected changes; investigate unexplained loss/reset before declaring success. Keep test outputs and settings separate from the user's normal state. On failed verification, return to recovery in step 3. A permission prompt alone is not evidence of data loss; if it blocks a check, report that check as pending. For unavailable or pending verification, apply the **Recovery cleanup** rule in step 5.

**Done:** the intended Release runs from the installation path, its essential smoke check passes, and user state is preserved or an explicitly intended migration is verified.

## 5. Delete temporary backups and report

After installation **and launch verification succeed**, delete this run's temporary rollback bundle, data snapshots, and staging/test artifacts by their recorded exact paths. This cleanup is part of the reinstall request: do not ask again or leave a backup “just in case.” Recheck canonical paths and ensure no cleanup target contains or aliases the installed app, user data, repository, or retained build output. Immediately before removal, verify no app/helper process runs from the target paths; if one does, preserve that target and report the blocker. Remove only transaction-owned contents; preserve any unexpected files and report the blocker.

If a generic macOS cleanup hook fires, distinguish this run's recorded rollback artifacts from protected Release installations and development apps. Their cleanup belongs to this reinstall workflow; do not classify them as disposable development builds. Follow the hook's required review and permitted retry behavior; an actual tool denial is not permission to bypass the hook.

Check whether temporary app copies acquired LaunchServices records; remove only records for those exact temporary paths using the installed tool's supported operations. Preserve the installed app's registration and other copies. Never reset the entire LaunchServices database. Verify temporary paths, dangling links, and their registration records are absent; report failed cleanup explicitly rather than calling the reinstall fully complete.

Keep a backup after successful verification **only when the user explicitly requests it**, at the agreed path. Existing backups from other runs and ordinary Release build artifacts are outside automatic cleanup; inspect/remove them only within separately established scope.

**Recovery cleanup:** During failed, incomplete, or pending verification, retain only temporary material needed for recovery and report why it remains with its exact path. After verified restoration of the old installation, delete redundant transaction material using the same path/process checks above; retain recovery material beyond that only at the user's request.

Report the installed path and source/version, build/signature/launch/smoke results, preserved settings/data, and whether temporary backups were deleted or explicitly retained. Identify any remaining recovery or cleanup blocker. Do not claim that all backups everywhere were removed.
