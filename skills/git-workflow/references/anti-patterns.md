# Anti-Patterns

Use this reference as a final safety check before staging, committing, pushing, rebasing, merging, or telling the user a Git workflow is ready.

## Avoid

- Staging broad changes with `git add .` when unrelated or generated files may be present.
- Committing secrets, `.env` files, credentials, local machine config, dependency directories, or build output.
- Using vague commit messages such as `WIP`, `updates`, `fix`, or `misc`.
- Mixing unrelated changes in one commit or review request.
- Assuming the base branch is `main` without checking repository docs or remote metadata.
- Saying checks passed without running them and reporting the command.
- Bypassing hooks, signing, or DCO checks with `--no-verify`, `--no-gpg-sign`, or missing `--signoff`.
- Rewriting shared history with plain `--force` or without confirming the branch is safe to rewrite.
- Discarding work with `git reset --hard`, branch deletion, tag deletion, or checkout overwrite without explicit user approval.
- Applying review feedback blindly without verifying the requested change against code, docs, or tests.

## Prefer

- Stage intentional paths or use `git add -p`.
- Use `git revert` for already-shared commits.
- Use `--force-with-lease` only after confirming no one else depends on the branch state.
- Keep commits and review requests focused on one logical change.
- Pause and ask when the requested Git operation could discard work, rewrite public history, or affect a protected/shared branch.
