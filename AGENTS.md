# AgentSkills Authoring Guide

This repository stores OpenAI/Codex-compatible agent skills.

## Skill Structure

Put distributable skills under:

```text
skills/<skill-name>/
```

Start each new skill with:

```bash
scripts/new-skill.sh <skill-name>
```

Then edit the generated files.

Every skill must include `SKILL.md` with YAML frontmatter containing only:

```yaml
---
name: skill-name
description: Clear trigger guidance for when to use the skill.
---
```

Optional per-skill resources:

- `agents/openai.yaml` for UI metadata, invocation policy, and MCP dependencies.
- `scripts/` for deterministic helper commands.
- `references/` for detailed docs, schemas, examples, and long-form guidance.
- `assets/` for templates, images, fonts, and other reusable files.

## Writing Rules

- Keep each skill focused on one job.
- Put trigger words and the main use case early in `description`.
- Prefer imperative steps with explicit inputs and outputs.
- Keep `SKILL.md` concise; move detailed material to `references/`.
- Do not add README, changelog, or installation docs inside individual skill folders.
- Quote all string values in `agents/openai.yaml`.
- Use kebab-case for skill folder names and plugin names.

## Validation

Run this before committing skill changes:

```bash
scripts/validate-skills.sh
```
