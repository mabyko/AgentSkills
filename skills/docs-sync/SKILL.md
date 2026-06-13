---
name: docs-sync
description: "Use when documentation and implementation may be out of sync, docs may define intended behavior, user-facing code changes may need docs updates, or the user asks for 문서 체크, 문서 갱신, 문서 동기화, or 문서 기준."
---

# Docs Sync

## Overview

Keep documentation and implementation aligned after user-facing code changes. Also use this when changed docs may define intended behavior that code needs to match.

## Core Rule

Do not classify source of truth by edit order alone. Honor the current task's declared intent first: user request, issue, PR description, spec, implementation plan, or explicit docs-as-spec instruction.

- Code-led sync: implementation is the declared intended behavior; update docs to describe it.
- Docs-led sync: documentation is the declared intended behavior; report or implement code changes needed to match it.
- Mixed change: code and docs changed together; verify they describe and implement the same intended behavior.
- Audit mode: no source is declared; report discrepancies and ask before editing.

When declared intent conflicts with tests, build behavior, or security constraints, report the conflict instead of silently choosing a winner.

Default to a Docs Sync Report before edits. Edit immediately only when the user explicitly asks for changes.

## Invocation Shortcuts

- `$docs-sync 문서 갱신`: use current code or changed code as the likely baseline, update affected docs, then report.
- `$docs-sync 문서 체크`: audit docs against declared intent and implementation; report by default.
- `$docs-sync 코드 체크`: check whether docs imply code changes; report by default unless the user asks to edit code.
- `$docs-sync 코드 갱신`: update code when docs are the declared intent; report first if the source of truth is unclear.
- `$docs-sync 코드 기준으로 문서 갱신` or `$docs-sync 코드 기준, 문서 갱신`: treat implementation as the declared intent.
- `$docs-sync 문서 기준으로 코드 갱신` or `$docs-sync 문서 기준, 코드 갱신`: treat documentation as the declared intent.
- `$docs-sync 리포트만` or `$docs-sync 리포트`: audit only; do not edit docs or code.

## Workflow

1. Confirm scope: current branch, base branch, changed files, docs roots, generated docs, and excluded paths.
2. Inventory user-facing surface area: public APIs, exported types, configuration, environment variables, CLI commands, examples, default values, errors, runtime behavior, deprecations, removals, and renamed items.
3. Run a doc-first pass: read relevant docs and extract claims, examples, command snippets, signatures, option names, default values, and promised behavior.
4. Run a code-first pass: map implemented user-facing features to existing docs pages or missing locations.
5. Verify code examples against real implementation patterns, not only API names.
6. Produce a Docs Sync Report with evidence and proposed edits before making changes.
7. If editing, keep changes targeted, preserve existing style, update navigation when adding pages, and verify docs build or formatting when the project provides a command.

## Report Format

```text
Docs Sync Report

Scope
- Base/current branch or selected files:
- Docs roots checked:
- Exclusions:

Findings
- Stale docs:
- Code missing for docs-led spec:
- Mixed-change mismatch:
- Missing coverage:
- Incorrect examples or signatures:
- Structural suggestions:

Proposed Edits
- File -> change summary:

Questions
- Items needing user/product decision:
```

## References

- For detailed audit targets, evidence capture, and edit guidance, read `references/doc-coverage-checklist.md`.
