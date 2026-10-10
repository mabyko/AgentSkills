---
name: prepare-release-github
description: "Release preparation for GitHub repositories: version changes, release PRs, candidate commit and CI verification, and deployment handoff. Use for release preparation or 릴리스 준비; preparation ends before publishing or deploying."
---

# Prepare Release (GitHub)

Prepare a reviewable release candidate and the information an operator needs to approve delivery. Follow the target repository's release policy; GitHub Release publication, Git tags, and production deployment can be separate events.

## Scope

Use the current repository unless the user names another. Resolve the requested version, source branch or commit, and preparation stage from the request and repository conventions.

Preparation covers local version and release-note changes, checks, and a release brief. Create release PRs or push refs when requested or already authorized. Inspect push, tag, release, and dispatch triggers before remote writes: a ref push that starts deployment is a deployment action.

End preparation before dispatching deployment, approving production, or publishing a GitHub Release. If the user also authorizes delivery, complete preparation first and continue through the appropriate delivery workflow without requesting the same authorization again.

Use `git-workflow` and `github-workflow` for Git and GitHub operations when available. Neither is an installation dependency; otherwise follow repository instructions and the same authorization boundaries directly.

## Preparation

1. **Discover the release contract.** Read repository instructions, release/deployment docs, version metadata, release PR templates, and `.github/workflows/`. Establish what prepares a version, what starts deployment, what requires approval, and when tags or GitHub Releases are recorded. Distinguish CI-only workflows from deployment workflows. When no release contract exists, provide a proposed sequence and the missing setup; implement automation only when requested.

2. **Establish the change range.** Inspect the worktree, source ref, and prior release or deployment record relevant to the request. Refresh remote refs when candidate selection depends on them. Identify the exact commits being released and preserve unrelated work. Treat an earlier tag or documented deployment as historical evidence, not proof of the current production state.

3. **Prepare the version changes.** Follow the repository's version policy and update the required manifests, lockfiles, and release notes. Prepare the release PR body using its template. Preserve independently versioned packages. Summarize user-visible changes, compatibility, configuration changes, and database migrations. Reuse the repository's checks and migration procedures; a failed release gate is a preparation blocker to resolve, not a condition to bypass.

4. **Verify the candidate.** Run the relevant local checks. If version changes are still uncommitted or awaiting a required merge, identify the source changes and leave the final candidate SHA and its CI pending; use PR checks as evidence for the preparation stage only. For a final candidate, inspect version metadata at that SHA, check its agreement with the requested version and repository ref policy, and inspect required GitHub checks for that exact SHA. For a release policy requiring a successful main push, a PR's synthetic merge SHA or another commit's green CI is insufficient. Inspect workflow identity, check publisher, run event, source branch, latest attempt, and required job/step conclusions. Record the run URL and SHA; distinguish passed, pending, failed, and unverified checks.

5. **Prepare the release ref and handoff.** Follow the repository's ref policy. While the final candidate is pending or a required check is unresolved, record a proposed ref without creating a snapshot. For immutable `release/vX.Y.Z` snapshots, use the verified source SHA, match the branch version to its release metadata, and check that an existing ref points to it; resolve a mismatch through the repository's next-version or recovery process rather than moving the snapshot. Create or push the ref only within the authorized scope. Preserve the repository's tag timing: a post-deployment success tag belongs to delivery, not preparation. Identify the actual deployment workflow/tool, ref or SHA, required inputs and approval, rollback target, and post-deployment checks. Missing deployment automation or unavailable remote access stays explicit in the handoff.

## Completion

Return a release brief or release PR body using the repository's template when available. Include:

- Version and release changes or PR; baseline and comparison range.
- Candidate SHA and ref, with their current status: proposed, verified, or pending merge.
- Local check results and exact-SHA GitHub CI evidence or unresolved checks.
- Compatibility, environment/configuration and database changes, and the rollback plan.
- The next delivery action, required approval, and checks that establish successful deployment.
- Remaining blockers and the specific action needed to resolve each.

Call the requested preparation stage complete when its edits and checks are done and the handoff is reviewable. Call a candidate ready for delivery only when the repository's candidate requirements are verified. Keep pending merge, CI, configuration, and approval visible; preparation does not establish that production was deployed successfully.
