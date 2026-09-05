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
- Docs-led sync: documentation declares intended behavior; implement code changes when requested, or report gaps for an audit.
- Mixed change: code and docs changed together; verify consistency both ways.
- Audit mode: the user asks for a check/report; report discrepancies without editing. If an update request leaves the source of truth ambiguous, ask before making dependent edits.

When declared intent conflicts with tests, build behavior, or security constraints, report the conflict before editing.

Choose the action from the request: checks and reports are read-only; update requests authorize targeted edits and verification. Ask only when missing scope or conflicting intent prevents a reliable choice. Honor decisions already supplied in the conversation.

## Shortcuts

- `$docs-sync current branch`: audit changed code/docs against the base branch.
- `$docs-sync 문서 체크`: audit docs intent against implementation.
- `$docs-sync 코드 갱신`: treat docs as intended behavior, update code to match, and run relevant checks.
- `$docs-sync 문서 갱신` or `$docs-sync 문서 동기화`: update docs to match the declared intended behavior and verify the changes.
- `$docs-sync 문서 기준`: treat docs as intended behavior; audit unless the request also asks for changes.
- `$docs-sync 리포트만` or `$docs-sync 리포트`: audit only; do not edit docs or code.

## Workflow

1. Infer scope from the request and repository: branch or selected files, docs roots, generated docs, and exclusions. Ask only about material ambiguity.
2. Classify source of truth from declared intent, not edit order.
3. Run doc-first and code-first passes, verifying examples against implementation.
4. For an audit, report discrepancies and proposed edits with evidence. For an update, apply targeted changes within the authorized scope.
5. Verify changes with relevant code tests or the available docs build/formatting check, then report what changed and any unresolved gaps.

## Reference Routing

Read `references/doc-coverage-checklist.md` for audit targets, source-of-truth classification, report format, and patch guidance.
