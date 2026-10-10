#!/usr/bin/env bash
# PreToolUse reminders; the intercepted command is never executed here.
set -eu

case "${1:-}" in
  --client=claude) client=claude ;;
  --client=codex) client=codex ;;
  *) echo "Usage: github-workflow-trigger.sh --client=claude|codex" >&2; exit 2 ;;
esac

input=$(cat)
sid=$(printf '%s' "$input" | grep -oE '"session_?[iI]d"[[:space:]]*:[[:space:]]*"[A-Za-z0-9_-]+"' | head -1 | grep -oE '[A-Za-z0-9_-]+"$' | tr -d '"') || sid=""
context=""

remind() {
  local marker="${TMPDIR:-/tmp}/github-workflow-hook-$1-${sid:-pid-$PPID}"
  # Recover separately without following or replacing the colliding symlink.
  if [ -L "$marker" ]; then
    marker="${TMPDIR:-/tmp}/github-workflow-recovered-hook-$1-${sid:-pid-$PPID}"
  fi
  [ ! -L "$marker" ] && [ -d "$marker" ] && return 0
  if ! (umask 077; mkdir "$marker") 2>/dev/null; then
    echo "GitHub reminder could not save session state; skipping to keep retries available." >&2
    return 0
  fi
  context="${context:+$context }$2"
}

# shortcut: match raw hook JSON, so quoted examples can trigger reminders;
# use a command parser if wrappers, global flags, or API operations need coverage.
matches() {
  printf '%s' "$input" | grep -qE "(^|[[:space:]\";&|/])gh[[:space:]]+$1[[:space:]]+($2)([[:space:]]|\\\\|\"|$)"
}

if matches pr 'create|edit|ready|reopen|review|comment'; then
  remind pr-write "GitHub PR publication or edit detected. Inspect repository guidance and templates, the exact repository, head/base branches, draft state, and requested change. Preserve an established stack parent; use one PR for a cohesive change unless dependent layers were requested or required. Fill the PR template and report validation. Post comments or reviews only when requested; reuse existing authorization and ask only for unresolved decisions."
fi

if matches pr 'merge|close'; then
  remind pr-landing "GitHub PR merge or close detected. Act only within existing explicit authorization for the exact target and merge mode. Before merging or enabling auto-merge, inspect the current head SHA, required checks, CI annotations, review state, bot feedback, unresolved threads, and branch protection; green checks alone are insufficient. Check native Stack membership before choosing a merge path: ordinary PR merge is not the native Stack landing path. Enabling auto-merge is a mutation, and queue acceptance is not proof of completion; verify the remote result."
fi

if matches stack 'init|add|rebase'; then
  remind stack-history "GitHub stack branch/history change detected. Verify the trunk, ordered branch chain, affected layers, and ownership; inspect worktrees for clean and idle state before rewriting history. Preserve the requested layer count and native Stack membership. Apply existing shared-history authorization and repository signing/DCO rules; implicit commits from gh stack add options must not bypass them. If git-workflow is available, use it for local history safety and conflict recovery."
fi

if matches stack 'submit|push|sync'; then
  remind stack-publication "GitHub stack submission or synchronization detected. Verify the exact repository, remote, trunk, layer chain, PR bases, and native Stack membership. Submission, push, and sync can force-push with leases; sync can also rebase and update PR state. Ensure existing authorization covers all affected layers and history changes; pruning additionally needs branch-cleanup authorization. Verify each resulting diff and signing/DCO policy, and prepare PR templates before submission. Check actual JSON and remote state afterward: cached views or exit zero with Sync aborted do not prove completion."
fi

if matches stack 'merge'; then
  remind stack-landing "GitHub native Stack merge detected. Resolve the exact target and merge set: merging a layer includes every unmerged layer below it, and a stack target can include the entire stack. Verify authorization covers that set, inspect current heads, required checks, annotations, reviews, unresolved feedback, and trunk branch rules, and select the requested merge method. Use Stack-aware landing; a CLI yes flag only skips its prompt. Verify the remote result; queue acceptance alone does not mean the stack landed."
fi

if matches release 'create|edit|upload|delete|delete-asset'; then
  remind release "GitHub release mutation detected. Inspect repository release rules and the exact repository, tag, candidate SHA, CI evidence, assets, draft/published state, and latest designation. Preparation does not authorize publishing or deployment. Publish, change latest, or delete releases/assets only within explicit authorization; draft preparation is not publishing permission. Preserve tags and published artifacts unless their changes were requested; prefer the repository recovery process for mistakes. Verify the remote result. If prepare-release-github is available, use it for version/candidate preparation and deployment handoff."
fi

[ -n "$context" ] || exit 0
context="If the github-workflow skill is available, read it for the detailed procedure. $context"
if [ "$client" = "claude" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$context"
else
  # Show the reason once, then allow the retry, as in the existing hook plugins.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$context"
fi
