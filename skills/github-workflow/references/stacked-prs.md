# Stacked PRs

Use this reference when creating dependent PR layers, editing a lower layer, submitting or syncing with gh-stack, or merging and cleaning up a PR chain. Use separate branches or stacks for independent changes.

Follow the entrypoint's single-PR default and requested scope first. The creation examples below assume dependent PR layers have already been chosen; they do not require splitting ordinary PR work.

Example shape:

```text
main
  #10 base: main, head: feature-a
    #11 base: feature-a, head: feature-b
      #12 base: feature-b, head: feature-c
```

Stay in `pull-requests.md` for ordinary PR creation, review responses, merge readiness, and conflicts that are not caused by a stacked PR chain. Use `git-workflow` for local rebase safety, conflict handling, and branch-history decisions.

## Choose the Stack Path

Distinguish a **native GitHub Stack**, registered on GitHub, from an **ordinary PR chain**, whose base branches are connected without Stack membership. Local gh-stack tracking alone does not prove a remote Stack exists.

A native Stack requires at least two PRs. gh-stack can track and submit a single branch, but that creates a standalone PR until a second dependent PR is added. Report this distinction rather than calling a one-PR submission a native Stack.

Inspect the PR's `stack` object in the full REST response or its Stack map in the GitHub UI. `gh pr view`'s selected fields below do not include Stack membership. If the tool cannot expose membership, obtain it through another authorized surface before choosing a merge path.

- For a native Stack, use the native lifecycle below. The final trunk's reviews, checks, and branch rules apply to every layer. Use Stack-aware merge operations; ordinary `gh pr merge` and manual base retargeting are not the native landing path.
- For new dependent work, recommend gh-stack when suitable and apply the entrypoint's optional installation policy. All native Stack branches must be in the same repository; cross-fork stacks are unsupported. Verify host support and repository access rather than assuming GitHub Enterprise Server has the same capabilities as github.com.
- Without gh-stack, a native Stack can still be created, reviewed, and merged through GitHub's web UI or an available tool supporting Stack APIs. Manage local branches with Git and follow repository signing rules. If a connected tool uses a legacy merge API, use the Stack UI or asynchronous merge API instead.
- Use the ordinary PR-chain workflow below for PRs confirmed to have no Stack membership, including unsupported host or fork workflows. Keep an existing native Stack intact when falling back; do not unstack it merely because a tool is missing.

Apply merge readiness from `pull-requests.md` regardless of the chosen tool. When only manual instructions are possible, prepare the exact branch chain and PR material and report the remaining remote actions.

## Preconditions

For new work, verify the planned layers, trunk, and writable head repository. For an existing chain, inspect the actual PRs with the selected tool before changing branches. For example:

```bash
gh pr view <number> --json number,title,headRefName,baseRefName,headRepository,isCrossRepository,maintainerCanModify,mergeStateStatus,reviewDecision,statusCheckRollup
```

Verify:

- The intended final trunk from repository guidance or metadata; do not assume `main`.
- The chain order from final base to topmost PR.
- Each PR's title, head branch, base branch, review state, and checks.
- Whether each head branch is writable. For fork PRs, confirm maintainer edits or equivalent push access.
- Repository policy for squash merge, rebase merge, auto-merge, and branch protection.

Do not merge stacked PRs, retarget bases, or force-push rebased branches unless the user explicitly requested that operation and the repository policy allows it.

## Native Stack with gh-stack

Before using the extension, run `gh stack --help` unless its availability has already been verified. Apply the entrypoint's optional installation policy if it is missing; API, authentication, and permission failures are not installation failures. Use `<command> --help` for the installed version's flags and current official documentation for server features.

### Create and Submit

1. Choose the trunk and the smallest meaningful dependent layers. Confirm a clean worktree and branch ownership under `git-workflow`.
2. Initialize the first layer and commit its work using the existing commit policy. `init` enables Git's `rerere` conflict-resolution reuse in the repository.

```bash
gh stack init --base <trunk> feature/models
```

3. From the top layer, add the next branch, then implement and commit that layer. Preserve exact names supplied by the user; otherwise follow repository naming conventions.

```bash
gh stack add feature/api
```

Create commits separately under `git-workflow`, including `-S --signoff` and its signing fallback policy. gh-stack's `add -m`, `-Am`, and `-um` shortcuts do not explicitly supply signing or DCO flags and are not substitutes for that policy.

4. Prepare each PR's title, filled template/body, base, and draft status under `pull-requests.md` before submission. A request to publish the stack's PRs includes pushing the verified layers, not unrelated branches or cleanup.

```bash
gh stack submit --auto --remote <remote>
gh stack view --json
```

`--auto` creates new PRs as drafts with generated titles/bodies; update each actual PR with the prepared content using `gh pr edit --title <title> --body-file <file>`. Use `--open` only when ready-for-review publication is requested: it changes existing PRs too. If submission partially fails, inspect remote branches and PRs before retrying so completed work is reused.

### Edit, Rebase, and Sync

Check `gh stack view --json`, then edit on the branch that owns the change. After committing a lower-layer fix:

```bash
gh stack rebase --upstack --remote <remote>
gh stack view --json
```

Before pushing, verify the resulting diff, relevant local checks, and commit signatures/trailers under `git-workflow`; after pushing, recheck remote readiness for the updated heads. Rebased commits are new commits; local signing configuration and GitHub-generated signatures are not interchangeable with a developer's signing policy.

`gh stack push`, `submit`, and `sync` may force-push with leases. Apply the existing history-rewrite authorization and branch-safety rules to those implicit operations. Multiple remotes require an explicit `--remote` where supported; navigation/checkout instead rely on the configured remote selection.

`gh stack sync` fetches, reconciles Stack membership, rebases, pushes, and updates PR/Stack state. Use it only when those mutations are authorized. `--prune` also deletes merged local branches and requires cleanup scope. Diverged local/remote membership can produce **exit 0 with `Sync aborted`**: verify JSON and remote state rather than treating the exit code as completed synchronization. `view` refreshes PR state best-effort, so cached state is insufficient evidence of merge readiness.

### Native Landing

Inspect the exact merge set and each PR's readiness under the trunk's rules. Merging a chosen PR also includes every unmerged PR below it; a stack-number target includes the whole stack. Confirm the resolved target and that the user's request covers that set. Select the requested merge method explicitly rather than inheriting a prior CLI preference.

```bash
gh stack merge <verified-target> --yes --squash
```

`--yes` skips the CLI prompt, not authorization or readiness checks. A merge-queue request is not proof the PRs landed. Verify the remote result; GitHub manages the remaining native Stack's retarget/rebase. Sync local branches only within the authorized mutation scope.

For the no-installation path, perform the same checks in the Stack UI or a tool supporting asynchronous Stack merges, then refresh local branches with Git. Preserve layer boundaries when reconciling server-rewritten history; follow `git-workflow` rather than blindly pulling or force-pushing.

### Conflict and Worktree Recovery

gh-stack shares its catalog across linked worktrees and updates affected branches in their owning worktrees. Inspect `git worktree list --porcelain`; keep affected owners clean and idle during a cascade. Its mutation lock coordinates gh-stack processes, not arbitrary Git commands or other agents.

If `rebase` pauses, resolve and stage in the worktree named by the diagnostic, then use `gh stack rebase --continue`; use `gh stack rebase --abort` to restore the stack. A `sync` conflict attempts to roll back the cascade; inspect any retained recovery state, then use `rebase` to resolve the conflict. Continue to follow the Conflict Policy below before publishing a resolution.

Use explicit checkout targets and `view --json` for non-interactive work. Bare `modify` is TUI-only; use another supported surface or prepare a concrete restructuring plan. Changing or deleting Stack membership needs its own task scope; a missing command or failed operation is not permission to unstack. For a branch checked out elsewhere, navigation's `--print-path` can report its owner; check success before using the path.

## Ordinary PR Chain: Sequential Squash Landing

Use this path only after confirming the PRs are not registered in a native GitHub Stack. When landing the chain as separate squash commits on the final base:

1. Merge the first PR that already targets the final base.

```bash
gh pr merge <first-pr> --squash --subject "<PR title> (#<first-pr>)"
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
gh pr merge <next-pr> --squash --subject "<PR title> (#<next-pr>)"
git fetch origin <final-base>
```

5. Repeat until the full chain is merged.

Pass the PR title explicitly as the squash commit subject via `gh pr merge --subject`; GitHub may otherwise choose a branch name or first commit message that does not match the reviewed PR.

## Conflict Policy

If a local rebase reports conflicts, stop and surface the conflicted files. Do not silently resolve non-trivial conflicts for the user, and do not force-push a conflict resolution until the user has reviewed the result.

For an ordinary PR chain, continue after user-reviewed resolution with plain Git. Native gh-stack operations use their recovery commands above.

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

## Authoritative References

- [gh-stack command behavior](https://github.com/github/gh-stack/blob/main/skills/gh-stack/references/commands.md) — CLI side effects and recovery; confirm flags with the installed command's `--help`.
- [GitHub Stack lifecycle](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests) and [Stack APIs](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests-apis-and-webhooks) — supported server operations.
- [2026-10-06 GA changes](https://github.blog/changelog/2026-10-06-stacked-pull-requests-generally-available/) — server signing, queue behavior, and auto-merge rollout changed after the CLI v0.2.0 documentation. Verify current server support before relying on older limitations.
