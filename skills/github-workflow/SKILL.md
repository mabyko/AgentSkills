---
name: github-workflow
description: "Use when working with GitHub collaboration and release workflows: pull requests, PR reviews, review threads, PR merges, GitHub auto-merge, GitHub PR squash/rebase merges, GitHub Actions checks, CI annotations, branch protection, GitHub Releases, gh CLI commands, or ambiguous release requests that may involve GitHub publishing. Use git-workflow for Git-only staging, commits, rebases, tags, local merges/squashes, and history safety."
---

# GitHub Workflow

Use this skill for GitHub-specific collaboration, checks, and release workflows. Use `git-workflow` for staging, commits, rebases, conflicts, branch cleanup, and Git tag safety.

For ambiguous requests like "release this" or "cut a release", orchestrate here when the likely target is a GitHub Release or a GitHub-mediated release flow: checking CI, reviewing merged PRs, using release templates, publishing, marking latest, or running `gh release`. Delegate only the Git history and tag-safety sub-steps to `git-workflow`.

If the tag already exists and the task is only to create, edit, or publish the GitHub Release object or notes, `github-workflow` can proceed without loading `git-workflow`.

For ambiguous requests like "merge this", orchestrate here when the likely target is a pull request or GitHub-mediated merge flow: merge button, PR squash merge, PR rebase merge, GitHub auto-merge, branch protection, required checks, or review-thread readiness. Use `git-workflow` only for local history cleanup, local squash/rebase decisions, conflict resolution, or deciding whether the branch history is safe.

## Core Rules

1. Inspect repository-specific GitHub guidance first: `.github/`, pull request templates, release workflows, branch protection notes, and contribution docs override this skill.
2. Never claim GitHub checks passed unless you inspected the relevant status and can report how.
3. Do not merge, close, publish, mark latest, delete releases, or delete remote branches unless the user explicitly requested that action.
4. Treat green status as necessary but not sufficient: review annotations, warnings, bot comments, and unresolved review threads.
5. For any Git history operation, follow `git-workflow`.

## Reference Routing

Load relevant reference:

| Reference | Use For |
| --- | --- |
| `references/pull-requests.md` | Creating PRs, PR descriptions, review responses, merge readiness |
| `references/github-releases.md` | GitHub Releases, release publishing, latest flag, published release recovery |

## Default Workflow

1. Read repository-specific GitHub guidance.
2. Check worktree and branch state using `git-workflow` when needed.
3. Inspect GitHub status, reviews, and templates relevant to the request.
4. Make or recommend GitHub changes only within the user's requested scope.
5. Report verification source, remaining blockers, and follow-up actions.
