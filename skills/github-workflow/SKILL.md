---
name: github-workflow
description: "Use when working with GitHub workflows: pull requests, stacked PRs and gh-stack, PR reviews, review threads, PR merges, auto-merge, GitHub Actions checks, CI annotations, branch protection, GitHub Releases, gh CLI commands, release publishing, or fork upstream-sync automation."
---

# GitHub Workflow

Use for GitHub-hosted collaboration and publishing. Use `git-workflow` for local staging, commits, rebases, conflicts, branch cleanup, Git tag safety, or history rewrites.

## Rules

1. Read repository-specific GitHub guidance first: `.github/`, PR templates, release workflows, branch protection notes, `CONTRIBUTING.md`, and `README.md`.
2. Never claim GitHub status, checks, reviews, or release state unless you inspected them.
3. Do not merge, close, publish, mark latest, delete releases, or delete remote branches unless explicitly requested.
4. Treat green status as necessary but not sufficient: also check annotations, warnings, bot comments, and review state.
5. For local Git history decisions, follow `git-workflow`.

## Tool Availability and Installation

Follow the user's tool choice. Otherwise use an available GitHub CLI, connected GitHub tool, or browser that can access the target repository. CLI examples in the references describe operations, not mandatory dependencies; alternative tools must preserve the same targets, authorization, and verification.

- Before using `gh`, check `command -v gh` unless availability is already known this session. For a CLI operation needing authentication, verify the target host with `gh auth status` unless already verified. Recheck when a failure or configuration change invalidates that evidence; distinguish missing commands from authentication, permission, or network failures.
- If `gh` is missing, recommend installation once using the [official GitHub CLI instructions](https://cli.github.com/). If only gh-stack is missing during stacked PR work, offer `gh extension install github/gh-stack`. Skip the offer when the user has chosen no installation. Ordinary PR work needs no gh-stack extension.
- Installation is optional. Install only within an existing setup authorization or when requested, then verify the required command works. Do not install a separate upstream skill as a prerequisite for this skill.
- If the user prefers no installation, continue with an available connected tool or browser and use Git for local branch work. Remember that choice for the session; offer installation again only if the user reopens it.
- If no authorized GitHub access is available, finish local preparation and produce the PR title/body or other reviewable material. Explain which GitHub steps remain and give concrete manual instructions. Pause only steps needing unavailable access; do not claim remote state or completion that you could not verify.

For native stacks, preserve Stack membership when changing tools. The no-installation paths and ordinary PR-chain fallback are in `references/stacked-prs.md`.

## Reference Routing

Read only the references needed for the requested task.

| Reference | Use For |
| --- | --- |
| `references/pull-requests.md` | Creating PRs, PR descriptions, review responses, merge readiness |
| `references/stacked-prs.md` | Stack creation, lower-layer edits, gh-stack submit/sync, native Stack merges, no-installation paths, ordinary PR-chain landing |
| `references/github-releases.md` | GitHub Releases, release publishing, latest flag, published release recovery |
| `references/upstream-sync.md` | Explicit requests to create or review fork upstream-sync GitHub Actions workflows |

## GitHub Action Safety Checklist

Before merging, enabling auto-merge, publishing a release, changing release `latest`, or dismissing review/check state:

- Check worktree and branch state using `git-workflow` when local changes or branch history matter.
- Inspect the exact PR, release, check run, or review thread targeted by the request.
- Confirm required checks, review state, branch protection, and requested merge/release mode.
- Act only on the target named by the user or verified from repository metadata.
- Report the command, URL, or API result used as evidence.

## Default Workflow

1. Read repository-specific GitHub guidance.
2. Choose an available tool under Tool Availability and Installation; check worktree and branch state using `git-workflow` when needed.
3. Inspect GitHub status, reviews, and templates relevant to the request.
4. Make or recommend GitHub changes only within the user's requested scope.
5. Report verification source, remaining blockers, and follow-up actions.
