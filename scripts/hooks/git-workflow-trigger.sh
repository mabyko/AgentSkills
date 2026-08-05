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

# Two classes, reminded independently. A single marker would let a harmless early
# `git checkout` swallow the reminder that the later `git commit` needed.
# ponytail: grep raw JSON instead of jq - false positives only cost a harmless reminder
if printf '%s' "$input" | grep -qE 'git[[:space:]]+(commit|rebase|merge|cherry-pick|revert|tag|push|reflog|am)'; then
  class=history
  context="Git history-affecting command detected. Follow the git-workflow skill before proceeding: read its SKILL.md if you have not this session. Key rules: signed commits with DCO (git commit -S --signoff; fall back per references/commits.md if signing unavailable), atomic commits, a commit body whenever the reason is not obvious from the title (use git commit -S --signoff -F -), never --no-verify/--no-gpg-sign, --force-with-lease only, ask before rewriting shared history."
elif printf '%s' "$input" | grep -qE 'git[[:space:]]+(reset|clean|restore|checkout|switch|stash|worktree[[:space:]]+remove|branch[[:space:]]+-[dDMm])'; then
  class=discard
  context="Git command that can discard work detected. Follow the git-workflow skill before proceeding: read its SKILL.md if you have not this session. Key rules: run git status --short first, ask before anything that discards uncommitted work or deletes refs (reset --hard, clean, restore, checkout -- <path>, branch/tag deletion), prefer git stash over discarding, and prefer git revert over reset for shared commits."
else
  exit 0
fi

sid=$(printf '%s' "$input" | grep -oE '"session_?[iI]d"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -oE '[A-Za-z0-9-]+"$' | tr -d '"') || sid=""
# ponytail: no session_id (unknown client) falls back to PPID, so the reminder repeats
# instead of going silent - a safety hook should fail loud. Both supported clients send one.
marker="${TMPDIR:-/tmp}/git-workflow-hook-${class}-${sid:-pid-$PPID}"
# Marker present = already handled this session (Claude: reminded / Codex: this is the allowed retry).
[ -f "$marker" ] && exit 0
touch "$marker"

if [ "$client" = "claude" ]; then
  # Claude Code: non-blocking context injection.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$context"
else
  # Codex: deny once so the reason is shown; the agent re-issues the command and the retry is allowed.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s Re-run the command to proceed."}}\n' "$context"
fi
