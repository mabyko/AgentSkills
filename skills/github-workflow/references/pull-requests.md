# Pull Requests

For ambiguous "merge this" requests, stay in this reference when the target is a pull request or GitHub-mediated merge: merge button, PR squash merge, PR rebase merge, GitHub auto-merge, branch protection, required checks, and review threads. Use `git-workflow` only for local conflict resolution, local squash/rebase decisions, history cleanup, or branch-safety decisions.

## PR Shape

Keep pull requests focused. A useful default target is under 400 changed lines when practical.

Good PRs include:

- What changed.
- Why it changed.
- How it was verified.
- Any migration, release, or follow-up notes.

## Creating PRs

Check branch and worktree state first using `git-workflow`.

Push a new branch with upstream tracking only when the user asked to push:

```bash
git push -u origin HEAD
```

Create the PR using the repository's template when present:

```bash
gh pr create --fill
```

## Review Responses

Verify review comments before applying them, especially AI-generated reviews. Use source code, official docs, local probes, or tests as evidence.

When a requested change is made, reply with what changed and cite the commit SHA when possible:

```bash
git rev-parse --short HEAD
```

Avoid vague replies such as `Done`, `Fixed`, or `Addressed` without context.

## Agent PR Reviews

When the user asks to review a PR, report findings in chat by default. Do not post PR comments, submit a GitHub review, approve, request changes, resolve review threads, or dismiss reviews unless the user explicitly asks for GitHub-side action.

If the user explicitly asks to post review comments, post only high-confidence, actionable findings with precise file and line references. Prefer a pending review batch over scattered individual comments, avoid duplicates and speculative notes, and summarize what was posted.

## PR Conflict Resolution

When GitHub reports PR merge conflicts, treat GitHub as the status surface and resolve non-trivial conflicts locally with `git-workflow`.

Before committing conflict-resolution changes, inspect PR metadata: head repository, head branch, base branch, whether the PR is from a fork, `maintainerCanModify`, merge state, review decision, and checks. A useful starting point:

```bash
gh pr view <number> --json headRepository,headRefName,baseRefName,isCrossRepository,maintainerCanModify,mergeStateStatus,reviewDecision,statusCheckRollup
```

Only push conflict-resolution commits to the PR head branch when the user has push permission and the action is requested. For fork PRs, maintainers may resolve conflicts on the contributor's branch only when maintainer edits are enabled or equivalent push access exists.

If the branch is not writable, do not force-push, change the base branch, merge around the PR, or rewrite the PR as a workaround. Ask the author to enable maintainer edits, push a fix, accept a patch, or approve a maintainer-owned replacement branch/PR.

Use GitHub's web conflict editor only for simple line conflicts, only when committing to the head branch is permitted, and only when the resulting merge of the base branch into the head branch is acceptable.

## Merge Readiness

Before merging or telling the user a PR is ready, verify:

- Worktree is clean or only expected files are dirty.
- Required checks are green.
- CI annotations, warnings, or review bot comments do not reveal unresolved issues hidden behind green status.
- Review threads are resolved.
- Branch is up to date with the target branch if the repository requires it.
- The merge strategy matches repository policy and user intent.

Do not use PR squash merge, PR rebase merge, regular PR merge, GitHub auto-merge, or close a PR unless the user or repository policy asks for it. Do not preserve messy `WIP` history; clean it before review when safe using `git-workflow`.
