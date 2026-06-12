# Branch Cleanup

Use this reference only when the user explicitly asks to clean up branches or asks whether a branch can be deleted. Never delete branches as part of a normal commit, push, pull request, or release workflow unless the user explicitly requested cleanup.

## Safety Checks

Before suggesting or deleting branch cleanup candidates:

1. Check the current branch and worktree state.
2. Confirm the base branch from repository guidance or remote metadata.
3. Check whether each candidate is currently checked out in this or another worktree.
4. Check whether each candidate is merged into the correct base branch.
5. Check whether a matching remote branch exists.
6. Treat protected, shared, release, hotfix, and long-lived integration branches as unsafe unless repository guidance says otherwise.
7. Show the candidate list and the reason each branch appears safe or unsafe.
8. Delete only after explicit user approval.

## Useful Checks

```bash
git status --short
git branch --show-current
git branch --merged <base-branch>
git branch --no-merged <base-branch>
git branch -vv
git worktree list --porcelain
```

For remote cleanup decisions, inspect remote branch state before deleting:

```bash
git branch -r
git ls-remote --heads origin
```

## Deletion Rules

- Prefer `git branch -d <branch>` for local branches; it refuses unmerged branches.
- Use `git branch -D <branch>` only after the user explicitly accepts losing the local branch pointer.
- Use `git push origin --delete <branch>` only after confirming the remote branch is no longer needed and the user explicitly approved remote deletion.
- Do not delete the current branch.
- Do not delete a branch checked out by another worktree.
- Do not delete base, release, hotfix, protected, or shared branches unless the user confirms the exact branch and risk.
