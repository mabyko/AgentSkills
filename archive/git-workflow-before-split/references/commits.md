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

## Signed Commits And DCO

Use signed commits with DCO sign-off by default:

```bash
git commit -S --signoff -m "docs: clarify git workflow"
```

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
