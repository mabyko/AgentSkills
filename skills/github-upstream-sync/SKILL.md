---
name: github-upstream-sync
description: "Use only when the user explicitly asks to create or review an upstream-sync GitHub Actions workflow for a fork repository, especially with phrases like upstream sync, fork sync, gh repo sync, or syncing fork branches from upstream."
---

# GitHub Upstream Sync

Use this skill when the user wants a GitHub Actions workflow that keeps a fork branch synced with an upstream repository.

## Inputs

- Target branch, default `main`.
- Upstream branch, default target branch.
- Schedule, default daily if the user gives only a time.
- Timezone from explicit user text first; otherwise use session/environment timezone if available.
- Upstream source repo, optional. Use it only when the user provides one or the fork parent is ambiguous.
- Token secret name, default `GH_TOKEN`.

## Workflow

1. Convert the requested schedule to GitHub Actions cron in UTC. If the user writes `4:00` or `4시 25분` without a timezone, use the session/environment timezone. If no timezone is available, ask for it.
2. If target branch and upstream branch are the same, prefer `gh repo sync "${{ github.repository }}" --branch <branch>`.
3. Add `--source OWNER/REPO` to `gh repo sync` only when the user specifies the upstream repo or the fork parent should not be trusted.
4. If target branch and upstream branch differ, use `aormsby/Fork-Sync-With-Upstream-action` with separate `target_sync_branch` and `upstream_sync_branch`.
5. Use `GH_TOKEN: ${{ secrets.GH_TOKEN }}` by default. The secret must be a PAT that can write contents and workflow files in the target fork. This avoids failures when upstream adds or modifies `.github/workflows/*`.
6. Use `permissions: contents: read` because the write authority comes from the PAT secret, not from `github.token`.
7. Do not use `permissions.actions: write` to solve workflow-file sync failures; that permission controls Actions API operations, not writing workflow YAML files.
8. Keep generated workflow YAML short. Do not add comments unless the user asks for annotated output.

## Templates

Same branch:

```yaml
name: Upstream Sync

on:
  schedule:
    - cron: "<utc-cron>"
  workflow_dispatch:

permissions:
  contents: read

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync fork with upstream
        run: gh repo sync "${{ github.repository }}" --branch <branch>
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

If source is needed, append `--source OWNER/REPO` to the `gh repo sync` command.

Different branches:

```yaml
name: Upstream Sync

on:
  schedule:
    - cron: "<utc-cron>"
  workflow_dispatch:
    inputs:
      sync_test_mode:
        description: "Dry run mode"
        type: boolean
        default: false

permissions:
  contents: read

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout target branch
        uses: actions/checkout@v4
        with:
          ref: <target-branch>
          fetch-depth: 0
          token: ${{ secrets.GH_TOKEN }}
          persist-credentials: false

      - name: Sync upstream changes
        id: sync
        uses: aormsby/Fork-Sync-With-Upstream-action@v3.4.3
        with:
          target_sync_branch: <target-branch>
          target_repo_token: ${{ secrets.GH_TOKEN }}
          upstream_sync_branch: <upstream-branch>
          upstream_sync_repo: <owner/repo>
          test_mode: ${{ github.event.inputs.sync_test_mode }}

      - name: Sync Success Check
        if: steps.sync.outputs.has_new_commits == 'true'
        run: echo "New commits were synced."

      - name: Already Up to Date Check
        if: steps.sync.outputs.has_new_commits == 'false'
        run: echo "Already up to date."
```

## Output

Return the workflow YAML and a brief note that `GH_TOKEN` must be a PAT with contents write and workflow-file permission for the target fork.

## Example Prompts

- `$github-upstream-sync 내 저장소의 main 브랜치를 upstream main과 매일 4시에 동기화하는 workflow 만들어줘.`
- `$github-upstream-sync 내 저장소의 main 브랜치에 upstream develop을 매일 KST 04:25에 동기화하고 dry run 체크박스도 넣어줘.`
