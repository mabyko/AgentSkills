# Pull Requests

## PR Shape

Keep pull requests focused. A useful default target is under 400 changed lines when practical.

Good PRs include:

- What changed.
- Why it changed.
- How it was verified.
- Any migration, release, or follow-up notes.

## Creating PRs

Check branch and worktree state first:

```bash
git status --short
git branch --show-current
```

Push a new branch with upstream tracking:

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

## Merge Readiness

Before merging or telling the user a PR is ready, verify:

- Worktree is clean or only expected files are dirty.
- Required checks are green.
- CI annotations, warnings, or review bot comments do not reveal unresolved issues hidden behind green status.
- Review threads are resolved.
- Branch is up to date with the target branch if the repository requires it.
- The merge strategy matches repository policy and user intent.

Do not squash by default unless the repository or user asks for it. Do not preserve messy `WIP` history; clean it before review when safe.
