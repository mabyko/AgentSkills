# Doc Coverage Checklist

Use this checklist after loading the main `docs-sync` skill.

## Scope

- Identify the current branch and the likely base branch.
- If the branch is not the base branch, prefer analyzing the diff against base.
- Avoid switching branches when local changes exist; use non-disruptive git inspection instead.
- Record docs roots, generated reference docs, source roots, examples, and excluded paths.
- Treat translated docs as excluded unless project guidance or the user explicitly asks to update them.

## Source-of-Truth Classification

- Do not use edit order alone to pick the source of truth.
- Declared intent can come from the user request, issue, PR description, design/spec doc, implementation plan, tests, or explicit docs-as-spec instruction.
- Code-led: implementation is the declared intended behavior; docs should describe it.
- Docs-led: documentation is the declared intended behavior; code may need follow-up work.
- Mixed change: code and docs changed together; verify both reflect the same declared intent.
- Constraint conflict: declared intent conflicts with tests, build behavior, runtime behavior, or security constraints; report instead of choosing a winner silently.
- Ambiguous: report the mismatch and ask before changing code or docs.
- Generated reference docs: update the source docstring or comment when that is the project convention.

## Feature Inventory Targets

- Public exports: classes, functions, methods, modules, types, and entry points.
- Configuration: settings objects, builder options, feature flags, defaults, validation, allowed ranges.
- Environment variables: names, precedence, defaults, opt-in or opt-out behavior.
- CLI and scripts: commands, flags, exit behavior, examples, and supported workflows.
- User-facing runtime behavior: errors, retries, timeouts, streaming, logging, telemetry, data handling, persistence, and security behavior.
- Lifecycle changes: deprecations, removals, renamed symbols, migration paths, and breaking changes.
- Examples: snippets, tutorials, sample apps, quickstarts, and copied command lines.

## Doc-First Pass

- Read the relevant page before proposing edits.
- Extract concrete claims: names, defaults, signatures, paths, commands, option values, and promised behavior.
- Verify every code block that appears to be executable or copyable.
- Check whether the page implies a feature area but omits important supported options.
- Preserve useful context; do not rewrite style-only issues during sync work.

## Code-First Pass

- Search implementation and examples for user-facing additions, removals, and behavior changes.
- Compare changed code against docs navigation to find the best existing page.
- Prefer updating an existing page over adding a new one unless the topic clearly lacks a home.
- Put advanced details in deeper pages; keep quickstarts focused.
- Record evidence as file path plus symbol, setting, command, or behavior. Avoid large code dumps.

## Red Flags

- Documented option names, parameter names, types, or command flags no longer exist.
- Defaults, allowed values, environment variable names, or precedence rules differ from implementation.
- Removed features are still documented without deprecation or migration context.
- New public behavior has no documentation or example coverage.
- Examples use a pattern that differs from working examples in the repository.
- Generated docs were hand-edited instead of updating the generating source.
- Docs describe future or intended behavior, but code has not implemented it.
- Code and docs changed together but imply different intended behavior.
- Declared intent conflicts with tests, build behavior, runtime behavior, or security constraints.

## Patch Guidance

- Keep edits narrow and evidence-backed.
- Match existing terminology, heading style, and cross-link style.
- Update navigation files when adding, moving, or renaming pages.
- Leave excluded docs untouched.
- Verify with the repository's docs build, link checker, formatter, or tests when available.
