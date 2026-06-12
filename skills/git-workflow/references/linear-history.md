# Linear History

Use this reference for local Git integration: fast-forward merges, merge commits, local squash merges, rebases, conflict preflight, and history shape. If "merge this" refers to a pull request, GitHub merge button, GitHub auto-merge, PR squash merge, PR rebase merge, branch protection, or required checks, use `github-workflow` as the orchestrator and return here only for local Git sub-steps.

Use this reference when the user wants to keep Git history linear, asks whether to fast-forward or rebase, or needs to integrate one branch into another without a merge commit.

## Vocabulary

In this reference:

- `B` is the target branch that should receive work.
- `C1` is the current or topic branch being integrated.
- `C2` is another topic branch that may already have been integrated into `B`.

## Prefer Fast-Forward When Possible

If `B` is an ancestor of `C1`, update `B` with a fast-forward merge:

```bash
git merge-base --is-ancestor B C1
git switch B
git merge --ff-only C1
```

Result:

```text
B:   A
C1:  A - c1

after:
B:   A - c1
C1:  A - c1
```

Do not use a regular merge when the user asked for a linear history and fast-forward is possible.

## Rebase When The Target Moved First

If another branch `C2` was integrated first, `B` may no longer be able to fast-forward to `C1` directly:

```text
before:
B:   A
C1:  A - c1
C2:  A - c2

after C2 fast-forward:
B:   A - c2
C1:  A - c1
```

To keep history linear, rebase `C1` onto `B`, then fast-forward `B`:

```bash
git switch C1
git rebase B
git switch B
git merge --ff-only C1
```

Result:

```text
B:   A - c2 - c1'
C1:  A - c2 - c1'
```

## Conflict Policy During Rebase

When the goal is linear history, a rebase conflict does not automatically mean switching to a merge commit.

Default flow:

```bash
git status
# edit conflicted files
git add <resolved-files>
git rebase --continue
```

Abort first if the conflict is unclear or the branch strategy should be reconsidered:

```bash
git rebase --abort
```

Switch to a regular merge only when there is a concrete reason:

- `C1` is a shared/public branch and rewriting it would disrupt other work.
- The repository policy prefers merge commits for this branch.
- Preserving original commit SHAs is more important than linear history.
- The conflict is too large to resolve safely during rebase.

After resolving conflicts, run the relevant project checks before fast-forwarding the target branch.

## Conflict Preflight

Fast-forward possibility can be checked without changing branches:

```bash
git merge-base --is-ancestor B C1
```

- Exit code `0`: `B` is an ancestor of `C1`; `B` can fast-forward to `C1`.
- Non-zero exit code: fast-forward is not possible as-is.

To preview rebase conflicts without touching the real topic branch, use a temporary branch:

```bash
git switch C1
git branch tmp/rebase-check-c1
git switch tmp/rebase-check-c1
git rebase B
```

If the rebase succeeds, the real `C1` can probably be rebased onto `B`.

If conflicts occur:

```bash
git rebase --abort
git switch C1
git branch -D tmp/rebase-check-c1
```

Then inspect the conflict files and decide whether to continue with rebase, change integration order, or use a merge.

## Worktree Awareness

If `B` is checked out in another worktree, run the fast-forward from that worktree. Git will not allow switching to a branch that is already checked out elsewhere.

Use:

```bash
git worktree list --porcelain
```

Do not remove or prune worktrees just to perform a merge. Use the worktree where the target branch is already checked out.
