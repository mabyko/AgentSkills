# Branching

Prefer the repository's documented model. If none exists, choose the simplest workflow that matches the release style.

## GitHub Flow

Use for most small to medium projects with continuous integration:

- Keep the base branch deployable.
- Create short-lived feature or fix branches from the base branch.
- Open a pull request for review.
- Merge only after review and required checks pass.

Common branch names:

- `feature/short-description`
- `fix/short-description`
- `docs/short-description`
- `chore/short-description`

## Trunk-Based Development

Use when the team has strong CI, small changes, and feature flags:

- Branches live hours or a few days, not weeks.
- Incomplete behavior is hidden behind flags.
- Merge frequently after fast review.

## GitFlow

Use only when scheduled releases or multiple maintained versions justify the extra branches:

- `main` or `stable` for production-ready releases.
- `develop` for integration.
- `feature/*`, `release/*`, and `hotfix/*` branches as needed.

Avoid GitFlow for small teams without a release manager; it adds coordination cost.

## Base Branch Discovery

Do not assume `main`. Resolve the base branch from:

1. Repository docs.
2. Open PR target branch.
3. Remote default branch:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

If `gh` is unavailable, inspect local refs and project docs before deciding.
