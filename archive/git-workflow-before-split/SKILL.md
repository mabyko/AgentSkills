---
name: git-workflow
description: "Use when choosing or executing Git workflows: branching strategy, commit messages, signed commits with DCO sign-off, staging, pull requests, code review responses, merge/rebase decisions, conflict resolution, releases, tags, stashes, reflog recovery, branch cleanup, or Git safety checks."
---

# Git Workflow

Use this skill for Git workflow decisions and Git operations that affect repository history, collaboration, pull requests, or releases.

## Core Rules

1. Inspect repository-specific guidance first. If the repo has `AGENTS.md`, `docs/git-workflow.md`, `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, or release docs, those override this skill.
2. Never claim a check passed unless you ran it and can report the command.
3. Prefer pull requests over direct pushes to protected or shared base branches.
4. Keep commits atomic: one logical change per commit, no final `WIP`, `fixup`, or mixed unrelated changes.
5. Use signed commits with DCO sign-off by default: `git commit -S --signoff`.
6. Never bypass hooks, signing, or DCO checks with `--no-verify`, `--no-gpg-sign`, or missing `--signoff` unless the user explicitly asks.
7. Use `--force-with-lease`, never plain `--force`, and only after confirming the branch is safe to rewrite.
8. Ask before destructive Git operations: `git reset --hard`, branch deletion, tag deletion, public-history rewrite, or discarding local changes.

## Before Acting

- Run `git status --short` before staging, committing, rebasing, merging, or deleting anything.
- Identify the actual base branch from repo docs or remote metadata. Do not assume `main`.
- Check whether the branch is shared before rebasing or force-pushing.
- For project work, stage only intentional changes. Prefer `git add -p` or explicit file paths.

## Reference Routing

Load only the relevant reference:

| Reference | Use For |
| --- | --- |
| `references/branching.md` | Choosing GitHub Flow, trunk-based, GitFlow, release branches, branch naming |
| `references/linear-history.md` | Fast-forward vs rebase decisions, linear integration, conflict preflight |
| `references/commits.md` | Conventional Commits, atomic commits, signed commits, DCO sign-off, staging |
| `references/pull-requests.md` | Creating PRs, PR descriptions, review responses, merge readiness |
| `references/conflicts-recovery.md` | Merge conflicts, rebase conflicts, stash, revert, reset, reflog recovery |
| `references/releases.md` | Version tags, changelog notes, release branches, release safety |
| `references/anti-patterns.md` | Common Git mistakes to avoid before staging, committing, pushing, or merging |
| `references/branch-cleanup.md` | Explicit branch cleanup requests, merged/stale branch checks, safe local or remote branch deletion |

## Default Workflow

1. Read repo-specific Git guidance.
2. Check worktree state.
3. Choose a narrow branch and commit plan.
4. Make or inspect changes.
5. Run project-specific verification.
6. If the user asked you to commit, commit with `git commit -S --signoff`.
7. If the user asked you to push, push with upstream tracking on first push.
8. If the user asked you to create or update a PR, include a concise summary and verification results.
