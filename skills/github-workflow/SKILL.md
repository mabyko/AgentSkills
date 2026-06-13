---
name: github-workflow
description: "Use when working with GitHub workflows: pull requests, PR reviews, review threads, PR merges, auto-merge, GitHub Actions checks, CI annotations, branch protection, GitHub Releases, gh CLI commands, or release publishing."
---

# GitHub Workflow

Use for GitHub-hosted collaboration and publishing. Use `git-workflow` for local staging, commits, rebases, conflicts, branch cleanup, Git tag safety, or history rewrites.

## Rules

1. Read repository-specific GitHub guidance first: `.github/`, PR templates, release workflows, branch protection notes, and contribution docs.
2. Never claim GitHub status, checks, reviews, or release state unless you inspected them.
3. Do not merge, close, publish, mark latest, delete releases, or delete remote branches unless explicitly requested.
4. Treat green status as necessary but not sufficient: also check annotations, warnings, bot comments, and review state.
5. For local Git history decisions, follow `git-workflow`.

## Reference Routing

| Reference | Use For |
| --- | --- |
| `references/pull-requests.md` | Creating PRs, PR descriptions, review responses, merge readiness |
| `references/github-releases.md` | GitHub Releases, release publishing, latest flag, published release recovery |

## GitHub Action Safety Checklist

Before merging, enabling auto-merge, publishing a release, changing release `latest`, or dismissing review/check state:

- Check worktree and branch state using `git-workflow` when local changes or branch history matter.
- Inspect the exact PR, release, check run, or review thread targeted by the request.
- Confirm required checks, review state, branch protection, and requested merge/release mode.
- Act only on the target named by the user or verified from repository metadata.
- Report the command, URL, or API result used as evidence.

## Default Workflow

1. Read repository-specific GitHub guidance.
2. Check worktree and branch state using `git-workflow` when needed.
3. Inspect GitHub status, reviews, and templates relevant to the request.
4. Make or recommend GitHub changes only within the user's requested scope.
5. Report verification source, remaining blockers, and follow-up actions.
