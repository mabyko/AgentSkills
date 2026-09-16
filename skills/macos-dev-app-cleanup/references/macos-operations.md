# macOS operations

Use these operations only after completing the skill's identity and data checks. Examples use variables assigned to reviewed absolute paths; they are not a bulk-cleanup script.

## Inspect bundles and paths

```sh
/usr/bin/plutil -p "$app/Contents/Info.plist"
/bin/ls -ld "$app"
/usr/bin/stat -f '%d:%i %N' "$app"
```

Record canonical paths and device/inode identity as well as the original path. Inspect ancestors for symlinks; `ls -ld` on the bundle alone does not check them. Use a path-aware resolver available in the environment. Resolve `/tmp` and user temp roots consistently; a path prefix such as `/tmp/qa-other` is not inside `/tmp/qa`. Defer unreadable/malformed plists or unresolved build provenance instead of inferring a configuration from the app name.

For discovery, `find -P "$root" -name '*.app' -prune -print` lists bundles and app symlinks without descending into bundles or following directory symlinks. Review nested install folders and explicit custom build paths. Use NUL-delimited output if passing paths programmatically, and retain traversal errors as coverage limits. This scan can miss apps beneath a symlinked directory; report that rather than claiming completeness.

## Inspect and quit the exact running instance

Use `NSWorkspace.runningApplications` / `NSRunningApplication` through an available native bridge to inspect `bundleURL`, `executableURL`, process identity, and launch time. Corroborate non-app helpers with:

```sh
/bin/ps -ww -p "$pid" -o pid=,ppid=,lstart=,comm=
/usr/sbin/lsof -nP -a -p "$pid" -d txt
```

Compare the actual executable with the target bundle using path-component containment. Inspect nested helpers and processes executing target code; a shared parent or similar process name is insufficient. Freshly validate the process identity immediately before requesting quit to avoid acting on a reused PID.

For a matched native running-app object, `terminate()` requests normal quit; a successful return only means the request was sent. Poll with fresh state/run-loop progress and verify exit independently. Use the application's normal Quit UI only when the exact instance is established. If no reliable normal-quit mechanism exists, defer it. Do not use `forceTerminate()`, `kill`, `killall`, `pkill`, or AppleScript targeting only a bundle ID/name. Keep save prompts for the user; a canceled quit is a deferred target.

Apple's [NSRunningApplication terminate documentation](https://developer.apple.com/documentation/appkit/nsrunningapplication/terminate()) and the installed SDK's `AppKit.framework/Headers/NSRunningApplication.h` describe normal termination and its asynchronous completion. The header also warns that time-varying properties require main-run-loop progress.

## LaunchServices

```sh
lsregister='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister'
"$lsregister" -h
"$lsregister" -dump
```

Inspect complete records for the exact original/canonical path, including URL-encoded representations where present. Shared bundle IDs can have multiple path records: preserve all records for retained copies. A grep by product name/ID is candidate discovery, not proof of presence or absence. Avoid printing unrelated database records in the user-facing report.

After verified process exit, unregister the single reviewed path:

```sh
"$lsregister" -u "$app"
```

Dump again and check that exact path. If it remains, report/defer rather than resetting the database. Never use database deletion, rebuild, recursive registration, or global garbage collection as cleanup. This is an internal macOS utility: use the installed `-h` output as the syntax authority and report unsupported behavior.

Only after that check, remove the reviewed bundle with an exact-path file operation, such as `rm -r -- "$app"`. Revalidate the path first; do not append a trailing slash, follow an app symlink, use wildcards, or combine discovery and deletion. Keep errors visible and verify absence with an existence **and** symlink check. The operation is irreversible; its authorization must come from the user's cleanup request.

## Test-only preferences

Use the installed `/usr/bin/defaults help` and `man defaults` for the current scope options. Inspect only the candidate domain/key and avoid disclosing values. Read errors can mean missing preferences, denied access, or an invalid scope; interpret the error instead of treating any failure as absence.

For an independently proven disposable domain in the current user's ordinary scope:

```sh
/usr/bin/defaults read "$test_domain"
/usr/bin/defaults delete "$test_domain"
/usr/bin/defaults read "$test_domain"
```

For proven exclusive keys in a retained domain, add the exact key to each command. Use host/container options only when the session's actual write location is known, and verify in the same scope. Do not use `delete-all`, delete plist files directly, or kill `cfprefsd`. Preserve uncertain host/container settings. A missing app does not make its domain test-only.
