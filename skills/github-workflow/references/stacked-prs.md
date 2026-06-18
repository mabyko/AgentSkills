# Stacked PRs

Use this reference when the user asks to merge, land, or clean up a chain of GitHub pull requests where each PR targets the previous PR's branch rather than the final base branch.

Example shape:

```text
main
  #10 base: main, head: feature-a
    #11 base: feature-a, head: feature-b
      #12 base: feature-b, head: feature-c
```

Stay in `pull-requests.md` for ordinary PR creation, review responses, merge readiness, and conflicts that are not caused by a stacked PR chain. Use `git-workflow` for local rebase safety, conflict handling, and branch-history decisions.

## Preconditions

Before changing any branch, inspect the exact PR chain:

```bash
gh pr view <number> --json number,title,headRefName,baseRefName,headRepository,isCrossRepository,maintainerCanModify,mergeStateStatus,reviewDecision,statusCheckRollup
```

Verify:

- The intended final base branch, usually `main`.
- The chain order from final base to topmost PR.
- Each PR's title, head branch, base branch, review state, and checks.
- Whether each head branch is writable. For fork PRs, confirm maintainer edits or equivalent push access.
- Repository policy for squash merge, rebase merge, auto-merge, and branch protection.

Do not merge stacked PRs, retarget bases, or force-push rebased branches unless the user explicitly requested that operation and the repository policy allows it.

## Sequential Squash Landing

When landing a stacked chain as separate squash commits on the final base:

1. Merge the first PR that already targets the final base.

```bash
gh pr merge <first-pr> --squash --title "<PR title> (#<first-pr>)"
git fetch origin <final-base>
```

2. For each later PR, replay only that PR's unique commits onto the updated final base.

```bash
git switch <next-head-branch>
git rebase --onto origin/<final-base> <old-base-branch> <next-head-branch>
git push --force-with-lease origin <next-head-branch>
gh pr edit <next-pr> --base <final-base>
```

3. Re-check merge readiness after the rebase and base retargeting. Do not reuse readiness results from before the base branch changed.

```bash
gh pr view <next-pr> --json mergeStateStatus,reviewDecision,statusCheckRollup
```

4. Merge the PR only if it is still ready under `pull-requests.md`.

```bash
gh pr merge <next-pr> --squash --title "<PR title> (#<next-pr>)"
git fetch origin <final-base>
```

5. Repeat until the full chain is merged.

Use the PR title explicitly in `gh pr merge --title`; GitHub may otherwise choose a branch name or first commit message that does not match the reviewed PR.

## Conflict Policy

If `git rebase --onto` reports conflicts, stop and surface the conflicted files. Do not silently resolve non-trivial conflicts for the user, and do not force-push a conflict resolution until the user has reviewed the result.

Safe continuation after user-reviewed resolution:

```bash
git add <resolved-files>
git rebase --continue
```

Abort when the rebase target, branch ownership, or conflict resolution is unclear:

```bash
git rebase --abort
```

## Why Rebase Instead Of Cherry-Pick

Prefer retargeting and merging the original PR over cherry-picking when possible because the PR shows as merged into the final base in GitHub, review context remains attached to the PR, and each PR can still become one squash commit on the target branch.
