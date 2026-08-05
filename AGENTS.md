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
- List every skill in the `## Skills` section of both `README.md` and `README.ko.md`.
- When skill content changes, bump `version` in `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` so plugin hosts detect the update. Keep both versions identical; use patch bumps for doc-level skill changes.

## Hooks

Hooks are repository-level, not per-skill. They ship only through a plugin install, so they are absent from `npx skills add` installs.

```text
hooks/hooks.json          Claude Code (auto-discovered at the plugin root)
codex-hooks/hooks.json    Codex (referenced by .codex-plugin/plugin.json)
scripts/hooks/*.sh        Shared hook implementations
```

Rules:

- Anchor every hook command to the plugin root. Both hosts run hook processes with the *session's* working directory, so a relative path like `./scripts/hooks/foo.sh` resolves inside the user's project and fails. Use `"${CLAUDE_PLUGIN_ROOT}"/...` for Claude and `"${CODEX_PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT}"/...` for Codex.
- Keep hook scripts executable (`chmod +x`); the validator enforces this.
- Write one shared script per behavior and branch on a `--client=` flag rather than duplicating logic per host. Claude honors `additionalContext`; Codex honors only `permissionDecision`/`permissionDecisionReason`.
- Hooks must exit `0` on paths that should not interrupt the agent.

## Validation

Run this before committing skill changes:

```bash
scripts/validate-skills.sh
```

`.github/workflows/validate.yml` runs the same script on every push and pull request, so a skipped local run fails in CI instead. Beyond skill structure it also checks that both `plugin.json` versions match, that hook commands anchor to a plugin-root variable, and that hook scripts stay executable.
