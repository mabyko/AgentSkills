# Commits

## Conventional Commits

Use this format unless the repo documents another convention:

```text
<type>(optional-scope): <description>

[optional body]

[optional footer]
```

Common types:

- `feat`: user-visible feature
- `fix`: bug fix
- `docs`: documentation only
- `test`: tests
- `refactor`: behavior-preserving code change
- `perf`: performance improvement
- `build`: build system or dependency changes
- `ci`: CI configuration
- `chore`: maintenance
- `revert`: revert a prior commit

## Atomic Commits

One commit should contain one logical change. Split unrelated changes even if they were made together.

Prefer:

```bash
git add -p
git commit -S --signoff -m "fix(activity): preserve route samples on save retry"
```

Avoid:

```bash
git add .
git commit -m "updates"
```

## Cleaning Up Local Commits Before Sharing

The atomic-commit and no-`WIP`/`fixup` rules apply to the history you share, not to
every intermediate commit. Use interactive rebase to reshape messy local commits
into clean atomic ones before pushing.

Only rewrite commits that have not been pushed or shared. If the commits were already
pushed to your own branch, rewriting requires `git push --force-with-lease` (never
plain `--force`); do this only after confirming the branch is not shared. Never
rewrite public or shared history without explicit user approval.

Reword, reorder, squash, or drop commits:

```bash
git rebase -i <base>
```

Fold fix-up work into an earlier commit automatically:

```bash
git commit --fixup=<sha>
git rebase -i --autosquash <base>
```

`--fixup` records a commit that `--autosquash` moves next to its target and marks for
squashing, so the final history keeps one clean commit instead of a `fixup` trail.

If a rebase hits conflicts, resolve them and continue, or abort to reconsider; see
`conflicts-recovery.md` and `linear-history.md`.

## Dirty Working Tree Classification

Before staging a commit, classify the working tree:

1. Run `git status --short`.
2. If more context is needed, inspect `rtk git --no-pager diff --no-color --no-ext-diff --stat` and `rtk git --no-pager diff --no-color --no-ext-diff --name-status`.
3. For any ambiguous file, inspect the actual diff before deciding its group.
4. Group changes by logical intent, not by path alone.

Common logical groups include:

- Docs or source-of-truth cleanup.
- Native or platform setup.
- App theme or UI changes.
- Tests.
- Agent, tooling, or skill sync.

Do not assume files belong together only because they live near each other. A docs file can be part of a feature change, a test file can be unrelated cleanup, and generated files can be stale or unrelated. Verify intent from the diff when the grouping is not obvious.

## Default Commit Scope

When the user says only "commit this" or "commit it" and the current request has a specific scope, stage and commit only the logical group directly related to that request.

Leave unrelated, unverified, or separately motivated changes dirty. After committing, summarize those remaining groups and suggest them as follow-up commit candidates.

Do not automatically turn every dirty logical group into a separate commit. Multiple commits are appropriate only when:

- The user explicitly asks to commit the remaining changes and split them logically.
- The current user request clearly includes all changed groups as commit targets.

When creating multiple commits, repeat the classification and staged-diff check for each group. Each commit must still be atomic.

## Staging Safety

Stage intentionally:

- Prefer explicit file paths or `git add -p` when scope is unclear.
- Use `git add -A` only after verifying that the whole dirty tree is the intended commit scope.
- Never stage the entire dirty tree by default.
- Check for `.DS_Store`, temporary files, unrelated generated files, and unrelated local config before committing.
- Before committing, inspect `rtk git --no-pager diff --cached --no-color --no-ext-diff --name-status` or the staged diff.

## Signed Commits And DCO

Use signed commits with DCO sign-off by default:

```bash
git commit -S --signoff -m "docs: clarify git workflow"
```

Before running any commit or amend command, write the exact command and verify it includes both `-S` and `--signoff`.

Allowed:

```text
git commit -S --signoff -m "feat: add menu bar shell"
rtk git commit -S --signoff -m "feat: add menu bar shell"
git commit -S --signoff --amend -m "feat: add menu bar shell"
rtk git commit -S --signoff --amend -m "feat: add menu bar shell"
```

Forbidden:

```text
git commit -m "feat: add menu bar shell"
rtk git commit -m "feat: add menu bar shell"
git commit --amend -m "feat: add menu bar shell"
rtk git commit --amend -m "feat: add menu bar shell"
```

If the exact command is missing either `-S` or `--signoff`, stop and correct it before executing.

Before the first commit in a worktree, verify identity:

```bash
git config user.name
git config user.email
```

`--signoff` adds the `Signed-off-by:` trailer. The sign-off identity should match the configured Git user name and email.

Do not use `--no-gpg-sign`, `-c commit.gpgsign=false`, or omit `--signoff` unless the user explicitly asks.

## Multi-Line Messages

For bodies with quotes, shell metacharacters, or detailed explanations, use a file or stdin rather than a fragile quoted `-m` body:

```bash
git commit -S --signoff -F - <<'EOF'
fix(activity): prevent stale draft resume

Starting a new activity should not silently reuse stale samples.
EOF
```

## Hook Failures

If a hook fails, the commit usually did not happen. Fix the hook failure, restage if needed, and commit again. Do not run `git commit --amend` unless you have confirmed a commit was actually created.

## After Commit Report

After creating a commit, report:

- The commit hash and message.
- Which files or logical group were included.
- Any dirty changes intentionally left out, grouped by likely follow-up commit.
- The recommended order for remaining follow-up commits when more than one group remains.
