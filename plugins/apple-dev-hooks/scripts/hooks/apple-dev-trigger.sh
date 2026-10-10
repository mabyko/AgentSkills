#!/usr/bin/env bash
# PreToolUse reminders; the intercepted command is never executed here.
set -eu

case "${1:-}" in
  --client=claude) client=claude ;;
  --client=codex) client=codex ;;
  *) echo "Usage: apple-dev-trigger.sh --client=claude|codex" >&2; exit 2 ;;
esac

input=$(cat)
sid=$(printf '%s' "$input" | grep -oE '"session_?[iI]d"[[:space:]]*:[[:space:]]*"[A-Za-z0-9_-]+"' | head -1 | grep -oE '[A-Za-z0-9_-]+"$' | tr -d '"') || sid=""
context=""

remind() {
  local marker="${TMPDIR:-/tmp}/apple-dev-hook-$1-${sid:-pid-$PPID}"
  # Recover separately without following or replacing the colliding symlink.
  if [ -L "$marker" ]; then
    marker="${TMPDIR:-/tmp}/apple-dev-recovered-hook-$1-${sid:-pid-$PPID}"
  fi
  [ ! -L "$marker" ] && [ -d "$marker" ] && return 0
  # mkdir avoids writing through an existing marker symlink or file.
  if ! (umask 077; mkdir "$marker") 2>/dev/null; then
    echo "Apple development reminder could not save session state; skipping to keep retries available." >&2
    return 0
  fi
  context="${context:+$context }$2"
}

# shortcut: match raw hook JSON, so quoted examples can trigger a reminder;
# use a command parser if precise detection becomes necessary.
if printf '%s' "$input" | grep -qE '(^|[[:space:]";&|/])(rm[[:space:]][^;]*(\.app|DerivedData|build/macos)|find[[:space:]][^;]*\.app[^;]*(-delete|-exec[[:space:]]+rm)|lsregister[[:space:]][^;]*-u([[:space:]]|\\|"|$)|defaults[[:space:]]+delete)'; then
  remind cleanup "macOS app cleanup detected. If the macos-dev-app-cleanup skill is available, read it. Confirm existing cleanup authorization, project provenance, development/test purpose, and exact canonical paths before removing anything; names or bundle IDs alone are insufficient. Preserve Release apps, repositories, shared build directories, preferences, TCC permissions, Keychain, and user data. Inventory clear targets and proceed within existing authorization; defer ambiguous targets. Quit only the exact app instance normally, defer if it cannot quit safely, unregister its exact LaunchServices path before removal, and verify preserved artifacts. App removal does not authorize data removal, force-quitting, or a global LaunchServices reset."
fi

if printf '%s' "$input" | grep -qE '(^|[[:space:]";&|/])(xcodebuild([[:space:]]|\\|"|$)|codesign[[:space:]][^;]*(-s[[:space:]]|--sign[=[:space:]])|xcrun[[:space:]]+(simctl[[:space:]]+(install|launch)|devicectl[[:space:]]+device[[:space:]]+(install|process[[:space:]]+launch))|flutter[[:space:]]+build[[:space:]]+(ios|ipa|macos)([[:space:]]|\\|"|$)|flutter[[:space:]]+run[[:space:]][^;]*(-d[[:space:]]+|--device-id[=[:space:]]+)(macos|ios)([[:space:]]|\\|"|$))'; then
  remind identity "Apple build, signing, or launch command detected. If the apple-bundle-id-guardrails skill is available, read it. Resolve the actual scheme/configuration and every app, extension, and widget bundle ID together with its signing team; preserve existing IDs unless migration was requested. Enable organization IDs only after registration under their intended team; personal or additional teams need distinct identities. Separate identity from Debug/Release mode and keep personal team overrides untracked. For Flutter iOS/macOS, check the selected flavor's native Xcode configuration and effective IDs/team; coordinate flavor setup with flutter-flavors if available. Read-only build-setting queries and unsigned/simulator builds may proceed as requested; reuse session evidence and ask only for unresolved decisions needed before signing or installation."
fi

[ -n "$context" ] || exit 0
if [ "$client" = "claude" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$context"
else
  # Match the existing Git hook: show the reason once, then allow the retry.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$context"
fi
