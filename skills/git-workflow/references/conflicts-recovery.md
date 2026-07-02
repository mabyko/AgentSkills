# Conflicts And Recovery

Conflicts can happen while pulling remote changes, merging another branch, rebasing, cherry-picking, or applying a stash. Diagnose the active Git operation first, then resolve, continue, or abort with that operation's command. A `git pull` conflict follows either the merge path or the rebase path depending on the repository or command configuration.

## Active Operation Conflicts

Start by inspecting state:

```bash
git status --short
git --no-pager diff --no-color --no-ext-diff --name-only --diff-filter=U
```

Resolve conflict markers manually unless the user asks to prefer one side. After editing:

```bash
git add <resolved-files>
```

Then continue the operation:

```bash
git rebase --continue
```

or:

```bash
git commit -S --signoff
```

depending on whether the conflict happened during rebase or merge.

## Abort Paths

Use the operation-specific abort command when the user wants to stop:

```bash
git merge --abort
git rebase --abort
git cherry-pick --abort
```

These are safer than manually resetting because they respect Git's operation state.

## Revert Vs Reset

Use `git revert` for commits that are already shared:

```bash
git revert <commit>
```

Use `git reset` only for local/private history, and ask before destructive forms:

```bash
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1
```

`--hard` discards worktree changes. Do not use it without explicit user approval.

## Stash

Use stash for temporary local work when switching context:

```bash
git stash push -m "WIP: short description"
git stash list
git stash pop
```

Inspect before popping if the stash is old or unclear:

```bash
git stash show -p stash@{0}
```

## Reflog

Use reflog to recover lost local commits or branch positions:

```bash
git reflog
git --no-pager show --no-color --no-ext-diff <reflog-sha>
git branch recovered-work <reflog-sha>
```

Create a recovery branch before experimenting with reset or rebase repair.

## Removing Accidentally Committed Files

When a file that should never have been tracked (secret, `.env`, credential, build
output, dependency directory, local config) was committed, stop tracking it while
keeping the local copy:

```bash
git rm --cached <file>
echo "<file>" >> .gitignore
git commit -S --signoff -m "chore: stop tracking <file>"
```

This removes the file from future commits but leaves it on disk. Add the path to
`.gitignore` in the same commit so it is not re-added.

If the file was only committed locally and not yet pushed, the commit above is enough.
If it was already pushed, the file remains in history and cloneable from earlier
commits.

For a leaked secret that was already pushed:

- Stop and tell the user; do not silently rewrite shared history.
- Treat the secret as compromised and advise rotating/revoking the credential
  immediately, regardless of any history cleanup.
- History rewriting to purge the file (e.g. `git filter-repo`) is a destructive,
  public-history rewrite; get explicit user approval and follow the "Hard Stop Before
  Destructive Git Commands" rules before attempting it.
