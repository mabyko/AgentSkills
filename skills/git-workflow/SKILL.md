---
name: git-workflow
description: "Use when choosing or executing Git-only workflows: branching, staging, commits, signed commits, DCO sign-off, local merge/rebase/squash, conflicts, tags, stashes, reflog recovery, branch cleanup, Git safety checks, or Git-history release prep."
---

# Git Workflow

Use for Git operations that affect history, branches, tags, commits, or conflict recovery. Use `github-workflow` for GitHub PRs, reviews, Actions, Releases, and `gh` CLI workflows.

## Core Rules

1. Inspect repository-specific Git guidance first: `AGENTS.md`, `docs/git-workflow.md`, `CONTRIBUTING.md`, `README.md`, release docs.
2. Never claim a check passed unless you ran it and can report the command.
3. Avoid direct pushes to protected or shared base branches unless repo guidance and the user explicitly allow it.
4. Keep commits atomic: one logical change per commit, no final `WIP`, `fixup`, or mixed-change commits.
5. Use signed commits with DCO sign-off by default: `git commit -S --signoff`. Plain `git commit -m ...` or `git commit --amend -m ...` is forbidden unless the user explicitly overrides signing or DCO. If signing is unavailable — a key probe finds no usable key, or a `-S` commit just failed with a signing error, regardless of `commit.gpgsign` — do not retry; follow the signing fallback table in `references/commits.md`.
6. Never bypass hooks, signing, or DCO checks (`--no-verify`, `--no-gpg-sign`) unless the user explicitly asks.
7. Use `--force-with-lease`, never plain `--force`, and only after confirming the branch is safe to rewrite.
8. Ask before any command that may discard work, delete local or remote refs, or rewrite public/shared history: `git reset --hard`, branch or tag deletion, force pushes, or discarding local changes.
9. Before running a commit, amend, or destructive command, construct the exact command and verify it keeps the safeguards above.

## Before Acting

- Run `git status --short` before staging, committing, rebasing, merging, or deleting anything.
- Document and reason about plain `git` commands only. Command wrappers (token-filtering proxies such as `rtk`) are an execution-time concern: apply a wrapper prefix only when the user's global or repository guidance says so. All rules in this skill apply to the underlying Git command whether or not a wrapper prefix is present.
- When inspecting diffs, use raw unified diffs. Do not use aliases or wrapped diff shortcuts such as `git difft`; bypass pagers, colors, and external diff tools:

```bash
git --no-pager diff --no-color --no-ext-diff
git --no-pager diff --cached --no-color --no-ext-diff
git --no-pager show --no-color --no-ext-diff
```

- If a wrapper filters or hides diff output you need, rerun the same safe command through the wrapper's raw passthrough mode (for example `rtk proxy git --no-pager diff --no-color --no-ext-diff`) or without the wrapper.
- Identify the actual base branch from repo docs or remote metadata. Do not assume `main`.
- Refresh remote-tracking refs before operations whose correctness depends on remote state: merging into a base branch, rebasing onto it, release range review, or branch cleanup.
- Check whether the branch is shared before rebasing or force-pushing.
- Stage only intentional changes. Prefer `git add -p` or explicit file paths.
- When creating or renaming local task branches, default to `feature/`, `fix/`, `hotfix/`, `docs/`, `test/`, `refactor/`, `release/`, or `chore/` based on the work type unless the user supplies an exact branch name.

## Commit Safety Checklist

Before any user-requested commit or amend:

- If the tree has multiple changed files or unclear scope, inspect `git --no-pager diff --no-color --no-ext-diff --stat`, `git --no-pager diff --no-color --no-ext-diff --name-status`, and targeted diffs as needed.
- Group changes by logical intent before staging; do not infer intent from paths alone when the diff suggests otherwise.
- Stage only the logical group directly covered by the user's current request unless the user explicitly asks to commit all remaining groups.
- Leave unrelated or unverified groups dirty and report them as follow-up commit candidates.
- Use `git add -A` only when the intended commit scope is the whole tree and that scope has been verified.
- Check staged files or staged diff before committing.
- Use Conventional Commits unless the repository documents another convention.
- Verify the exact commit command against Core Rule 5 (`-S --signoff`) before executing.

## Branch and History Safety Checklist

Before creating, switching, rebasing, merging, force-pushing, or deleting branches:

- Confirm current branch, intended target branch, and actual base branch.
- Fetch and compare the base branch with its upstream before integrating or judging merged state.
- Check for uncommitted or staged changes that could be carried across branches.
- Confirm whether the branch is shared or protected before rewriting or deleting it, then apply Core Rules 7-8.

## Reference Routing

| Reference | Use For |
| --- | --- |
| `references/branching.md` | Branch flow, trunk-based, GitFlow, release branches, branch naming |
| `references/linear-history.md` | Fast-forward vs rebase decisions, linear integration, conflict preflight |
| `references/commits.md` | Conventional Commits, atomic commits, signed commits, DCO sign-off, staging, interactive rebase/autosquash cleanup |
| `references/conflicts-recovery.md` | Pull/merge/rebase/cherry-pick/stash conflicts, abort/continue flows, revert/reset/reflog recovery, untracking accidentally committed files |
| `references/releases.md` | Git tags, forge-neutral release notes, release branch safety |
| `references/anti-patterns.md` | Common Git mistakes before staging, committing, pushing, or merging |
| `references/branch-cleanup.md` | Explicit branch cleanup requests, merged/stale branch checks, safe branch deletion |
| `references/bisect.md` | Finding the commit that introduced a regression via manual or automated `git bisect` |
| `references/submodules.md` | Cloning, adding, updating, or removing Git submodules |

## Default Workflow

1. Read repo-specific Git guidance.
2. Run `git status --short`.
3. Load the relevant reference file.
4. Inspect branch, base, remote, and staged changes as needed.
5. Choose the least surprising safe Git operation.
6. If the user asked you to commit, follow the Commit Safety Checklist.
7. If the user asked you to push, push with upstream tracking on first push.
8. If the user asked for GitHub PRs, checks, releases, or `gh` CLI workflows, use `github-workflow`.
