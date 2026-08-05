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

## Message Language

Resolve the subject description and, when a body is needed, the body independently. For
each required part, follow the first source that explicitly specifies that part:

1. The user's explicit instruction.
2. An explicit rule in `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, or `README.md`. If
   two of them disagree, ask rather than picking one.
3. Usable human-authored history.

The language a guidance document is written in is not evidence about commit-message
language. A rule that specifies only the subject does not decide the body; continue
through the list for the body.

When history is needed, pin `HEAD` once so the subject and body inspect the same history
reachable from it, including ancestor commits.

```bash
git rev-parse --verify --quiet HEAD
```

Use the commit ID it prints for both `git log` commands below. If `HEAD` does not resolve,
leave the parts that still need history unresolved and let the combined question below
cover them; parts already decided by an earlier source stay decided. A `git log` failure
on that commit ID is an error worth reporting.

The `git log` examples below are written for a POSIX shell; adapt the quoting to the
shell in use.

```bash
git --no-pager log -30 --no-merges --format='%an <%ae>%x09%s' <commit-id>
```

Exclude bot and automation commits. For Conventional Commit subjects, remove the
optional prefix (`type:`, `type(scope):`, and their `!` variants) and judge only the
description.

For the body, inspect the first five usable prose bodies within the same 30 commits:

```bash
git --no-pager log -30 --no-merges \
  --format='commit %H%nAuthor: %an <%ae>%nBody:%n%b%n' <commit-id>
```

Ignore trailers when deciding whether a prose body is present and when judging its
language. Do not infer the body language from the subject. Treat mixed-language or
identifier-only text that cannot be assigned one language as unusable. For each part,
a language is dominant only when it appears in more than half of the usable sample, and
fewer than two usable samples never decides a part. Ask one combined question for every
part left unresolved.

Cache the resolved subject and body languages separately for the session, per
repository. Re-resolve after changing branches or applicable guidance. A later user
instruction replaces the applicable cached value.

Conventional Commit types and scopes, and trailer keys, stay in their standard ASCII
English form: `feat(auth): 토큰 만료 처리 추가`. Preserve trailer values such as names,
email addresses, and references unchanged.

## Commit Body

The title says what changed; the body says why and what to know. Write a body when the
change is non-trivial:

- The reason is not obvious from the title (a fix, a workaround, a non-obvious tradeoff).
- Behavior, an interface, or a default changed in a way a reader must know.
- The approach needs justification, or an obvious alternative was rejected.
- There is context a future reader (or `git blame`) will need: a bug being fixed, a
  constraint, a follow-up left undone.

A useful body covers the parts that apply - skip the rest, do not pad:

- Why the change was needed (the problem or trigger).
- What the change does at a high level, when the diff alone does not make it clear.
- Consequences: behavior changes, migration steps, breaking changes, known limits.
- References: issue/ticket IDs, related commits.

Keep it to what the diff cannot show. Do not restate the title or narrate the diff
line by line.

Skip the body when the title is fully self-explanatory: typo fixes, formatting,
dependency bumps, renames, and other small mechanical changes. A thin body is worse
than none - omit it rather than restating the title.

## Atomic Commits

One commit should contain one logical change. Split unrelated changes even if they were made together.

Prefer:

```bash
git add -p
git commit -S --signoff -F - <<'EOF'
fix(activity): preserve route samples on save retry

A failed save cleared the in-memory sample buffer before the retry ran, so a
retry after a network error uploaded an activity with a truncated route.

Keep the buffer until the server acknowledges the write.
EOF
```

Avoid:

```bash
git add .
git commit -m "updates"
```

Reserve the `-m` form for commits whose title genuinely says everything.

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

`git rebase -i` opens an editor, which fails in non-interactive or agent
environments. Drive the todo list programmatically instead: set
`GIT_SEQUENCE_EDITOR` to a command that rewrites it, or to `:` to accept the
generated todo list unchanged.

Fold fix-up work into an earlier commit automatically:

```bash
git commit --fixup=<sha>
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>
```

Git 2.44+ also accepts non-interactive `git rebase --autosquash <base>`.

Accepting the todo unchanged skips the review an interactive editor would provide.
Before running, list `git log --oneline <base>..HEAD` and confirm each `fixup!` or
`squash!` subject resolves to exactly one intended target: autosquash matches by
subject text, so duplicate subjects squash into the wrong commit silently.

`--fixup` records a commit that `--autosquash` moves next to its target and marks for
squashing, so the final history keeps one clean commit instead of a `fixup` trail.

If a rebase hits conflicts, resolve them and continue, or abort to reconsider; see
`conflicts-recovery.md` and `linear-history.md`.

## Dirty Working Tree Classification

Before staging a commit, classify the working tree:

1. Run `git status --short`.
2. If more context is needed, inspect `git --no-pager diff --no-color --no-ext-diff --stat` and `git --no-pager diff --no-color --no-ext-diff --name-status`.
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
- Before committing, inspect `git --no-pager diff --cached --no-color --no-ext-diff --name-status` or the staged diff.

## Signed Commits And DCO

Use signed commits with DCO sign-off by default:

```bash
git commit -S --signoff -m "docs: clarify git workflow"
```

Before running any commit or amend command, write the exact command and verify it includes both `-S` and `--signoff`.

Allowed:

```text
git commit -S --signoff -m "feat: add menu bar shell"
git commit -S --signoff --amend -m "feat: add menu bar shell"
```

Forbidden:

```text
git commit -m "feat: add menu bar shell"
git commit --amend -m "feat: add menu bar shell"
```

If the exact command is missing either `-S` or `--signoff`, stop and correct it before executing.

Before the first commit in a worktree, verify identity and signing setup:

```bash
git config user.name
git config user.email
git config user.signingkey
git config gpg.format
git config commit.gpgsign
```

An unset `user.signingkey` does not mean signing is broken: with the default gpg
format, git falls back to a secret key matching the committer identity. Treat signing
as unavailable only when a key probe fails — gpg format:
`gpg --list-secret-keys "$(git config user.signingkey || git config user.email)"`
finds no secret key; ssh format: the `user.signingkey` file is missing — or when a
`-S` commit has just failed with a signing error, even if `commit.gpgsign` is set.
When signing is unavailable, do not retry the failing command and do not silently
bypass signing. Check repository policy first (`CONTRIBUTING.md`, `README.md`, a
`DCO` file, `AGENTS.md`), then act by this table:

| Repo policy | Signing available | Action |
| --- | --- | --- |
| Requires, allows, or is silent about signing | Yes | Commit `-S --signoff` and proceed. |
| Requires signed commits | No | Stop. Warn that unsigned commits will be rejected at push/PR time, give the setup guidance below, and wait. Do not offer an unsigned commit as a fallback; it would have to be rewritten later. |
| Requires DCO only | No | Commit `--signoff` without `-S`; note once that signing is unavailable. |
| No stated policy | No | Ask once whether to configure signing or commit unsigned; keep `--signoff` either way. |

If the repo explicitly rejects sign-off trailers or signatures, follow the repo.

Signing setup is a human step: never generate, import, or select signing keys on the
user's behalf. When guiding setup, suggest SSH signing as the lowest-friction path:

```bash
git config gpg.format ssh
git config user.signingkey ~/.ssh/<key>.pub
```

`--signoff` adds the `Signed-off-by:` trailer. The sign-off identity should match the configured Git user name and email.

Do not use `--no-gpg-sign`, `-c commit.gpgsign=false`, or omit `--signoff` unless the user explicitly asks.

## Passing The Message

Any commit that carries a body uses stdin or a file. This is the default form, not
a special case; a repeated `-m` per paragraph is fragile with quotes and shell
metacharacters, and encourages dropping the body to avoid the quoting.

```bash
git commit -S --signoff -F - <<'EOF'
fix(activity): prevent stale draft resume

Starting a new activity should not silently reuse stale samples.
EOF
```

Use `-m` only for a title-only commit, and only when the "Commit Body" rules above
say no body is needed.

## Hook Failures

If a hook fails, the commit usually did not happen. Fix the hook failure, restage if needed, and commit again. Do not run `git commit --amend` unless you have confirmed a commit was actually created.

## After Commit Report

After creating a commit, report:

- The commit hash and message.
- Which files or logical group were included.
- Any dirty changes intentionally left out, grouped by likely follow-up commit.
- The recommended order for remaining follow-up commits when more than one group remains.
