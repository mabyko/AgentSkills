# AgentSkills

Reusable agent skills for Codex, Claude Code, OpenCode, and other agents that support the open agent skills format.

The canonical skill source is the top-level `skills/` directory. Plugin manifests and marketplace files point at that same source so the repository can be installed through multiple agent ecosystems.

## Repository Layout

```text
.
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/
│       ├── scripts/
│       └── assets/
├── .codex-plugin/
│   └── plugin.json
├── .claude-plugin/
│   └── plugin.json
├── .agents/
│   └── plugins/marketplace.json
├── templates/
│   └── skill/
├── scripts/
│   ├── new-skill.sh
│   └── validate-skills.sh
├── AGENTS.md
└── CLAUDE.md
```

## Install with `npx skills`

Use this path when you want broad agent support, including Claude Code, Codex, OpenCode, Cursor, and other agents supported by the `skills` CLI.

```bash
npx skills@latest add mabyko/AgentSkills
```

List available skills without installing:

```bash
npx skills@latest add mabyko/AgentSkills --list
```

Install a specific skill:

```bash
npx skills@latest add mabyko/AgentSkills --skill my-skill
```

Install for specific agents:

```bash
npx skills@latest add mabyko/AgentSkills -a claude-code -a codex -a opencode
```

Install globally:

```bash
npx skills@latest add mabyko/AgentSkills --global
```

The `skills` CLI discovers this repository's top-level `skills/` directory and installs each selected skill into the target agent's expected location.

## Install as a Codex Plugin

Use this path when you want Codex to install the repository as a plugin from a marketplace.

```bash
codex plugin marketplace add mabyko/AgentSkills
```

Then open Codex, go to `/plugins`, search for `agent-skills`, and install it.

How Codex resolves this repository:

```text
.agents/plugins/marketplace.json
  └── source.path: "./"
      └── .codex-plugin/plugin.json
          └── skills: "./skills/"
```

The marketplace file is the catalog entry. The `.codex-plugin/plugin.json` file is the plugin manifest. The actual skills remain in `skills/`.

## Install as a Claude Code Plugin

Use this path when you want Claude Code to install the repository as a plugin.

```bash
/plugin marketplace add mabyko/AgentSkills
/plugin install agent-skills@agent-skills
```

Claude Code reads `.claude-plugin/plugin.json` as the plugin manifest and uses the repository's top-level `skills/` directory as the skill source.

`CLAUDE.md` contains:

```md
@AGENTS.md
```

This keeps Claude Code's repository guidance aligned with the canonical instructions in `AGENTS.md`.

## Contributing

Create every new skill under the top-level `skills/` directory. Do not add new skills under `.agents/skills/`, `.claude/skills/`, or `plugins/`.

Start a new skill with:

```bash
scripts/new-skill.sh my-skill
```

This creates:

```text
skills/my-skill/
├── SKILL.md
└── agents/openai.yaml
```

Before opening a pull request:

1. Fill in `SKILL.md` with a clear `name`, trigger-focused `description`, and concise workflow steps.
2. Update `agents/openai.yaml` with a display name, short description, brand color, and `default_prompt` that mentions `$my-skill`.
3. Move long examples, schemas, and detailed reference material into `references/`.
4. Put deterministic helper commands in the skill's `scripts/` directory.
5. Put reusable templates, images, or other static files in the skill's `assets/` directory.
6. Run validation.

```bash
scripts/validate-skills.sh
```

Skill names must use kebab-case, for example `release-notes`, `frontend-review`, or `python-debugging`.

## Skill Format

Each skill is a folder containing:

- `SKILL.md`, required
- `agents/openai.yaml`, optional OpenAI/Codex UI metadata and dependencies
- `scripts/`, optional deterministic helpers
- `references/`, optional docs loaded only when needed
- `assets/`, optional templates, images, or other files used by the skill
