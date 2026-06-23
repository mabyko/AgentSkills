# Git Tags And Release Notes

When a user says "release this" without naming the release mechanism, keep this reference scoped to Git-owned work: version/tag policy, release branch safety, changelog or note drafting, and tag creation safety. If the work includes GitHub CI, merged PR discovery, release templates, publishing, latest flags, or `gh release`, `github-workflow` owns the overall release workflow and calls back to this reference only for Git sub-steps.

Use this reference for Git tag safety and forge-neutral release note drafting. Use `github-workflow` for GitHub Releases, release publishing, latest flags, and `gh release` commands.

Before release work, search the repository for release guidance rather than assuming a generic process. Look for obvious release docs, changelog conventions, package/version metadata, and release configuration. Follow repository-specific rules over this reference.

Example quick search:

```bash
rg --files | rtk rg -i 'release|releasing|changelog|version|contributing'
```

If no repository-specific release guidance is found after a quick search, say so and use this reference as a fallback.

## Semantic Versioning

Use SemVer only when it matches repository policy:

- `MAJOR`: breaking changes
- `MINOR`: backward-compatible features
- `PATCH`: backward-compatible fixes

Conventional Commit fallback:

- `fix`: patch
- `feat`: minor
- `!` or `BREAKING CHANGE:`: major

## Release Checklist

Before changing release files, tagging, or publishing:

- Confirm the release branch and base branch.
- Pull the latest remote state.
- Verify the worktree is clean.
- Run documented test/build/release checks.
- Update changelog or release notes if required.
- Confirm version numbers are consistent.

## Release Notes Drafting

When drafting release notes, prefer repository-specific changelog rules. If none exist:

1. Identify the previous release tag and target version.
2. Review the commit range, excluding merge-only noise when appropriate.
3. Group user-facing changes into `Added`, `Changed`, `Fixed`, and `Breaking` when the project has no other convention.
4. Call out migrations, configuration changes, compatibility notes, and follow-up work.
5. Treat generated notes as a draft until the user or maintainer confirms them.

Do not update changelog files or create tags unless the user explicitly asked for that action.

## Tags

Annotated tags are a common release default:

```bash
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

Deleting or rewriting pushed tags is disruptive. Ask before deleting local or remote tags:

```bash
git tag -d v1.2.0
git push origin --delete v1.2.0
```
