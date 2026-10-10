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
- When plugin content changes, bump `version` in that plugin's `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` so plugin hosts detect the update. Keep the two host versions identical within each plugin; use patch bumps for doc-level changes.

## Plugins

Register each plugin in both `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`.

- The repository root is the complete `agent-skills` plugin: all canonical skills and Git hooks. Hook scripts live in `scripts/hooks/`.
- Put independently installable plugins under `plugins/<plugin-name>/`, with both host manifests and all runtime resources inside that folder. Hosts cache the selected plugin directory; references to parent-directory resources will break.
- Install individual skills through the skills CLI. The selected plugin is `plugins/git-hooks/`; it contains its hooks without bundled skills or required skill dependencies.
- Edit skills only in canonical `skills/`, and edit shared hooks in `scripts/hooks/`. Run `python3 scripts/build-plugin-bundles.py` after changing these sources; generated script and hook copies in the selected plugins must match. Requires Python 3.9 or later for authoring. Bump both host versions for the complete plugin and each affected selection plugin.

## Coding principles installer

Maintain the native instruction block in `docs/coding-principles.md` and its local/remote Bash installer in `scripts/install-coding-principles.sh`. Keep it separate from skills and plugin hooks. Support Bash 3.2 with standard Unix commands and no Python or Node runtime. Installation and removal must preserve all content outside the block, existing permissions, and symlinks. Test with temporary instruction directories and a PATH without other language runtimes.

## Hooks

Hooks belong to their plugin, not to individual skills. They ship only through a plugin install, so they are absent from `npx skills add` installs. Paths below are relative to each plugin root.

```text
hooks/hooks.json          Claude Code (auto-discovered at the plugin root)
codex-hooks/hooks.json    Codex (referenced by .codex-plugin/plugin.json)
scripts/hooks/*.sh        Shared hook implementations
```

Rules:

- Anchor every hook command to the plugin root. Both hosts run hook processes with the *session's* working directory, so a relative path like `./scripts/hooks/foo.sh` resolves inside the user's project and fails. Use `"${CLAUDE_PLUGIN_ROOT}"/...` for Claude and `"${CODEX_PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT}"/...` for Codex.
- Keep hook scripts executable (`chmod +x`); the validator enforces this.
- Write one shared script per behavior; use a `--client=` flag when host-specific output differs. Keep output handling specific to the hook event.
- Hooks must exit `0` on paths that should not interrupt the agent.

## Validation

Run this before committing skill changes:

```bash
scripts/validate-skills.sh
```

`.github/workflows/validate.yml` runs the same script and `python3 -B -m unittest discover -s tests` on every push and pull request. Validation also checks bundle copies against canonical sources, each plugin's matching host versions, plugin-root hook commands, and executable hook scripts. Tests check marketplace selection, bundle refresh, and independently cached hook execution.
