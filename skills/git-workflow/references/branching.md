# Branching

Prefer the repository's documented model. If none exists, choose the simplest workflow that matches the release style.

## Feature Branch Flow

Use when the base branch should stay deployable and changes should be reviewed before integration.

- Create short-lived feature or fix branches from the base branch.
- Open a review request on the repository hosting platform when ready.
- Merge only after review and required checks pass.

Branch names:

- `feature/short-description`
- `fix/short-description`
- `docs/short-description`
- `chore/short-description`

## Trunk-Based Development

Use when the team has strong CI and feature flag discipline.

- Branches live hours or a few days, not weeks.
- Incomplete behavior is hidden behind flags.
- Integrate frequently after fast review.

## GitFlow

Use GitFlow only when scheduled releases or long-lived release trains justify the extra branches:

- `main` or `stable` for production-ready releases.
- `develop` for integration.
- `feature/*`, `release/*`, and `hotfix/*` branches as needed.

Avoid GitFlow for small teams or continuously deployed products unless the repository already uses it.

## Base Branch Discovery

Do not assume `main`. Resolve the base branch from:

1. Repository docs.
2. Review or merge request target branch when the hosting platform is relevant.
3. Remote default branch:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD
```

If the remote default branch is unavailable locally, inspect local refs and project docs before deciding.
