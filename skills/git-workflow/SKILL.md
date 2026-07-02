---
name: git-workflow
description: "Use when choosing or executing Git-only workflows: branching, staging, commits, signed commits, DCO sign-off, local merge/rebase/squash, conflicts, tags, stashes, reflog recovery, branch cleanup, Git safety checks, or Git-history release prep."
---

# Git Workflow

Use for Git operations that affect history, branches, tags, commits, or conflict recovery. Use `github-workflow` for GitHub PRs, reviews, Actions, Releases, and `gh` CLI workflows.

## Core Rules

1. Inspect repository-specific Git guidance first: `AGENTS.md`, `docs/git-workflow.md`, `CONTRIBUTING.md`, release docs.
2. Never claim a check passed unless you ran it and can report the command.
3. Avoid direct pushes to protected or shared base branches unless repo guidance and the user explicitly allow it.
4. Keep commits atomic: one logical change per commit, no final `WIP`, `fixup`, or mixed-change commits.
5. Use signed commits with DCO sign-off by default: `git commit -S --signoff`.
6. Never bypass hooks, signing, or DCO checks unless the user explicitly asks.
7. Use `--force-with-lease`, never plain `--force`, and only after confirming the branch is safe to rewrite.
8. Ask before destructive Git operations: `git reset --hard`, branch deletion, tag deletion, public-history rewrite, or discarding local changes.

## Before Acting

- Run `git status --short` before staging, committing, rebasing, merging, or deleting anything.
- Keep shell examples portable. When executing commands, follow local repository guidance; if RTK is available or required, add the `rtk` prefix at execution time.
- When inspecting diffs, use raw unified diffs. Do not use aliases such as `git difft` or `rtk proxy git diff`; bypass pagers, colors, and external diff tools:

```bash
git --no-pager diff --no-color --no-ext-diff
git --no-pager diff --cached --no-color --no-ext-diff
git --no-pager show --no-color --no-ext-diff
```

- If RTK hides needed diff output, rerun the same safe command through proxy: `rtk proxy git --no-pager diff --no-color --no-ext-diff`.
- BeforeAction guards should first normalize wrapped and direct Git forms with a shared prefix, then apply command-specific checks:

```regex
\b(?:rtk\s+(?:proxy\s+)?)?git\s+
```

Diff-producing guards should match both `diff` and `show`:

```regex
\b(?:rtk\s+(?:proxy\s+)?)?git\s+(?:--no-pager\s+)?(?:diff|show)\b
```

- Identify the actual base branch from repo docs or remote metadata. Do not assume `main`.
- Check whether the branch is shared before rebasing or force-pushing.
- Stage only intentional changes. Prefer `git add -p` or explicit file paths.
- When creating or renaming local task branches, default to `feature/`, `fix/`, `hotfix/`, `docs/`, `test/`, `refactor/`, `release/`, or `chore/` based on the work type unless the user supplies an exact branch name.

## Hard Stop Before Commit

Before running `git commit` or `git commit --amend`, construct the exact command and verify it includes both `-S` and `--signoff`.

- Allowed patterns: `git commit -S --signoff ...`, `rtk git commit -S --signoff ...`
- Forbidden patterns: `git commit -m ...`, `git commit --amend -m ...`, `rtk git commit -m ...`, `rtk git commit --amend -m ...`
- If either `-S` or `--signoff` is missing, stop and correct the command before executing.

## Hard Stop Before Destructive Git Commands

Before running destructive or history-rewriting commands, construct the exact command and verify it keeps required safeguards.

- Applies to force pushes, hard resets, branch or tag deletion, public-history rewrites, and hook/signing bypass flags.
- Never use plain `--force`; use `--force-with-lease` only after confirming the branch is safe to rewrite.
- Do not use `--no-verify`, `--no-gpg-sign`, or other hook/signing bypasses unless the user explicitly asks.
- Stop and ask before any command may discard work, delete local or remote refs, or change public/shared history.

## Commit Safety Checklist

Before any user-requested commit or amend:

- Run `git status --short`.
- If the tree has multiple changed files or unclear scope, inspect `rtk git --no-pager diff --no-color --no-ext-diff --stat`, `rtk git --no-pager diff --no-color --no-ext-diff --name-status`, and targeted diffs as needed.
- Group changes by logical intent before staging; do not infer intent from paths alone when the diff suggests otherwise.
- Stage only the logical group directly covered by the user's current request unless the user explicitly asks to commit all remaining groups.
- Leave unrelated or unverified groups dirty and report them as follow-up commit candidates.
- Prefer explicit file paths or `git add -p` when scope is unclear.
- Use `git add -A` only when the intended commit scope is the whole tree and that scope has been verified.
- Check staged files or staged diff before committing.
- Use Conventional Commits unless the repository documents another convention.
- Verify the exact commit command includes both `-S` and `--signoff`.
- Never use plain `git commit -m ...` for user-requested commits unless the user explicitly overrides signing or DCO.

## Branch and History Safety Checklist

Before creating, switching, rebasing, merging, force-pushing, or deleting branches:

- Confirm current branch, intended target branch, and actual base branch.
- Check for uncommitted or staged changes that could be carried across branches.
- Confirm whether the branch is shared or protected before rewriting or deleting it.
- Use `--force-with-lease` for approved history rewrites; never use plain `--force`.
- Ask before deleting branches, discarding local changes, or rewriting public history.

## Reference Routing

| Reference | Use For |
| --- | --- |
| `references/branching.md` | Branch flow, trunk-based, GitFlow, release branches, branch naming |
| `references/linear-history.md` | Fast-forward vs rebase decisions, linear integration, conflict preflight |
| `references/commits.md` | Conventional Commits, atomic commits, signed commits, DCO sign-off, staging |
| `references/conflicts-recovery.md` | Pull/merge/rebase/cherry-pick/stash conflicts, abort/continue flows, revert/reset/reflog recovery |
| `references/releases.md` | Git tags, forge-neutral release notes, release branch safety |
| `references/anti-patterns.md` | Common Git mistakes before staging, committing, pushing, or merging |
| `references/branch-cleanup.md` | Explicit branch cleanup requests, merged/stale branch checks, safe branch deletion |

## Default Workflow

1. Read repo-specific Git guidance.
2. Run `git status --short`.
3. Load the relevant reference file.
4. Inspect branch, base, remote, and staged changes as needed.
5. Choose the least surprising safe Git operation.
6. If the user asked you to commit, use `git commit -S --signoff`.
7. If the user asked you to push, push with upstream tracking on first push.
8. If the user asked for GitHub PRs, checks, releases, or `gh` CLI workflows, use `github-workflow`.
