#!/usr/bin/env bash
# PreToolUse hook (dual-client: Claude Code + Codex).
# When a Bash call runs a history-affecting Git command, surface the
# git-workflow skill rules. Fires once per session.
#
# Claude reads `additionalContext` (soft, non-blocking hint).
# Codex ignores additionalContext (serena hooks.py:93) and only honors
# permissionDecision/permissionDecisionReason, so it gets a one-shot `deny`
# whose reason carries the rules; the retry hits the marker and is allowed.
set -eu

client=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --client=*) client="${1#*=}" ;;
    --client)
      shift
      client="${1:-}"
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
  shift
done

case "$client" in
  claude|codex) ;;
  *)
    echo "Usage: git-workflow-trigger.sh --client=claude|codex" >&2
    exit 2
    ;;
esac

input=$(cat)

# ponytail: grep raw JSON instead of jq - false positives only cost a harmless reminder
printf '%s' "$input" | grep -qE 'git[[:space:]]+(commit|rebase|merge|reset|cherry-pick|revert|tag|stash|push|reflog|branch[[:space:]]+-[dDMm])' || exit 0

sid=$(printf '%s' "$input" | grep -oE '"session_?[iI]d"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -oE '[A-Za-z0-9-]+"$' | tr -d '"') || sid=""
# ponytail: no session_id (unknown client) falls back to PPID, so the reminder repeats
# instead of going silent - a safety hook should fail loud. Both supported clients send one.
marker="${TMPDIR:-/tmp}/git-workflow-hook-${sid:-pid-$PPID}"
# Marker present = already handled this session (Claude: reminded / Codex: this is the allowed retry).
[ -f "$marker" ] && exit 0
touch "$marker"

context="Git history-affecting command detected. Follow the git-workflow skill before proceeding: read its SKILL.md if you have not this session. Key rules: signed commits with DCO (git commit -S --signoff; fall back per references/commits.md if signing unavailable), atomic commits, never --no-verify/--no-gpg-sign, --force-with-lease only, ask before destructive ops (reset --hard, ref deletion, history rewrites)."

if [ "$client" = "claude" ]; then
  # Claude Code: non-blocking context injection.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$context"
else
  # Codex: deny once so the reason is shown; the agent re-issues the command and the retry is allowed.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s Re-run the command to proceed."}}\n' "$context"
fi
