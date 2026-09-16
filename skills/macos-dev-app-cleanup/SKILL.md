---
name: macos-dev-app-cleanup
description: "Clean up or verify removal of a project's macOS development and test apps (Debug, Dev, QA), including exact-path processes and LaunchServices entries, while preserving Release apps and shared settings."
---

# macOS Development App Cleanup

Remove only development/test artifacts attributable to the requested project and session. Treat a verification request as read-only; a request to build or test this skill does not authorize cleanup of the host. This skill covers macOS `.app` bundles, not iOS simulators or general disk cleanup.

## 1. Establish scope and identity

Identify the project/worktree, the user's cleanup authorization, and every Release installation to preserve. Reuse session evidence; ask only if missing scope prevents safe identification. While scope is unresolved, inspect without deleting.

Inventory these locations, recording paths actually checked and access failures:

- `/Applications` and `~/Applications`, including relevant nested app folders.
- The project's configured build/product directories. Associate Xcode DerivedData with the project using its metadata/build records before searching its products.
- Exact temporary QA directories from the session, including applicable `/tmp` and user temporary locations. If history is missing, inspect plausible project-related entries without treating names as proof.
- Running applications, helpers, and LaunchServices records for the identified paths, including recorded paths whose bundles have already disappeared.

Search for candidates; never pipe search results into deletion. Read each candidate's `Contents/Info.plist` (bundle ID, executable, version), canonical path, and provenance: effective build settings, product paths, build logs, or session copy/create commands. Confirm project ownership **and** development/test purpose. Names, timestamps, signing identity, bundle IDs, or a `Debug` directory alone are insufficient. Preserve Release copies even in temporary directories or DerivedData.

Resolve symlinks in both scope roots and candidate paths. Record normal system aliases such as `/tmp` → `/private/tmp`; use canonical containment with path-component boundaries, not string prefixes. Defer candidate symlinks, unexpected ancestor symlinks, broken links, and paths escaping the reviewed scope. Keep repositories/source trees protected; allow only individually identified generated artifacts inside them. Check that a proposed directory removal contains no protected files or symlinks escaping scope.

Before mutation, show a reviewable table:

| Exact path or settings domain | ID / provenance | Decision | Reason / shared data |
| --- | --- | --- | --- |
| … | … | remove / preserve / defer | … |

Include protected Release paths and planned process, registration, and settings actions. Record baseline metadata or fingerprints for the protected bundles and relevant shared settings without exposing values. An existing cleanup request authorizes clear targets: publish this inventory, then proceed without a repeated approval question. Leave ambiguous items untouched and explain what evidence is missing. A request to preview or approve a plan first remains read-only until that approval arrives.

**Done:** every proposed removal has a specific path, evidence, and a preservation check; each unresolved candidate is deferred.

## 2. Separate artifacts from settings and data

App removal does not imply data removal. Preserve user documents, repositories, Keychain items, TCC permissions, Containers, Group Containers, Application Support, caches, saved state, and shared preferences. This workflow does not recursively delete user Library directories.

For each defaults domain proposed for cleanup, establish from build/source configuration and session history that it holds disposable test settings exclusively. Compare it with all preserved variants and any custom suite/app-group use. A different bundle ID or `.qa` suffix alone does not prove exclusivity; absence of an installed Release does not prove its data is disposable. With a shared or uncertain domain, remove only the proven app artifact and preserve the entire domain. Delete specific test keys only when their exclusive ownership is independently proven.

**Done:** any settings action has its own evidence; every shared/unknown domain is marked preserved.

## 3. Remove one identified target at a time

Read [macOS operations](references/macos-operations.md) before interacting with processes, LaunchServices, or defaults. Use the installed tools' help/man pages when syntax differs.

1. Recheck the exact path, canonical location, metadata, and protected-path list immediately before acting. If identity changed, defer it. Use quoted literal paths, without globs, generated shell code, or name-based mass operations.
2. Match running apps by actual bundle/executable path and current process identity; inspect associated helpers. A process merely mentioning the path in its arguments is not a match. Request a normal quit for only that running instance. Recheck that it and its helpers exited, allowing a bounded wait (for example, 15 seconds).
3. If quitting is refused, prompts to save, times out, cannot be targeted reliably, leaves a helper/respawner alive, or exit cannot be verified, defer this app and its settings. Preserve unsaved work. Do not force-quit, send kill signals, discard save dialogs, or terminate by app name/bundle ID. Continue independent safe targets. If the app returns, stop retrying and report its launcher.
4. Unregister only this exact bundle path from LaunchServices, then verify that path's records are absent. For an already missing bundle, unregister only a previously evidenced development path. If registration inspection or unregistering fails, defer removal and report the limitation.
5. Recheck that no target process has returned; remove only the reviewed bundle and separately proven disposable temporary artifacts. Never remove an entire DerivedData tree, shared build directory, temp root, or repository. Stop on permission/removal errors; do not escalate to `sudo` or broaden scope automatically.
6. Clean up only the separately evidenced disposable test preferences from step 2, after all their writers have exited. Preserve the domain if a retained app still uses it.

Never reset/rebuild the whole LaunchServices database. An app uninstall is not permission to change login items, launch agents, or other projects.

**Done:** each target is removed and verified, or explicitly deferred with its remaining state; a command's exit status alone is not completion.

## 4. Verify and report

- Check exact bundle/artifact paths are absent, including dangling symlinks; repeat the scoped candidate scan for missed copies.
- Reinspect running applications/helpers and exact-path LaunchServices records. Distinguish no matches from inaccessible tools, failed commands, or uninspected locations.
- Verify any targeted defaults domain/key is absent using the same host/container scope used for deletion. Confirm protected Release bundles and shared settings remain unchanged without launching the Release or printing private settings values.
- Report removed paths and test domains, preserved Release/data, deferred items, and the locations/checks completed. Say “no development apps found in the checked locations,” not “all traces gone” or “none anywhere.” Report partial success honestly, including an app still present after unregistering or a file removal failure.

## Shared-ID example: Gallae

`/Applications/Gallae for Git.app`, ID `forked.gallae.local`, is the preserved Release in this example. A Debug build can share that ID: removing its distinct proven build path does **not** authorize deleting `forked.gallae.local` defaults or its data. Session-created `Gallae Design Flat.app` and `Gallae Design Glassbefore.app` with `forked.gallae.designqa.*` IDs are eligible only when exact paths and QA-exclusive settings are evidenced. Release build copies in `/tmp` or DerivedData remain protected. This historical example is not a live target list or authorization to delete anything.
