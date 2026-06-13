---
name: docs-sync
description: "Use when documentation and implementation may be out of sync, docs may define intended behavior, code changes need docs updates, or the user asks for 문서 체크, 문서 갱신, 문서 동기화, or 문서 기준."
---

# Docs Sync

## Overview

Keep documentation and implementation aligned after user-facing code changes. Changed docs may define intended behavior that code needs to match.

## Core Rule

Do not classify source of truth by edit order alone. Honor the current task's declared intent first: user request, issue, PR description, spec, implementation plan, tests, and repository guidance.

- Code-led sync: implementation declares intended behavior; update docs to match it.
- Docs-led sync: documentation declares intended behavior; report code changes needed to match it.
- Mixed change: code and docs changed together; verify consistency both ways.
- Audit mode: no source is declared; report discrepancies and ask before editing.

When declared intent conflicts with tests, build behavior, or security constraints, report the conflict before editing.

Default to a Docs Sync Report before edits unless the user explicitly asks for direct changes.

## Shortcuts

- `$docs-sync current branch`: audit changed code/docs against the base branch.
- `$docs-sync 문서 체크`: audit docs intent against implementation.
- `$docs-sync 코드 갱신` or `$docs-sync 문서 기준`: treat docs as intended behavior and report code gaps.
- `$docs-sync 리포트만` or `$docs-sync 리포트`: audit only; do not edit docs or code.

## Workflow

1. Confirm scope: branch or selected files, docs roots, generated docs, and exclusions.
2. Classify source of truth from declared intent, not edit order.
3. Run doc-first and code-first passes, verifying examples against implementation.
4. Produce a Docs Sync Report with evidence and proposed edits before making changes.
5. If editing, keep changes targeted and verify docs build or formatting when available.

## Reference Routing

Read `references/doc-coverage-checklist.md` for audit targets, source-of-truth classification, report format, and patch guidance.
