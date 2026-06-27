# AgentSkills

[한국어](README.ko.md)

Reusable agent skills for Codex, Claude Code, OpenCode, and other agents that support the open agent skills format.

The canonical skill source is the top-level `skills/` directory. Plugin manifests and marketplace files point at the same source so the repository can be installed through multiple agent ecosystems.

## Skills

- `docs-sync`: Sync documentation with user-facing code changes, or check whether docs define intended code behavior.
- `flutter-flavors`: Set up audit Flutter flavors, `flutter_flavorizr` / `flavorizr.yaml`, platform app identities, launch configs, and build-mode boundaries.
- `git-workflow`: Guide safe local Git workflows such as staging, commits, branches, merges, rebases, tags, and recovery.
- `github-workflow`: Guide GitHub collaboration workflows such as pull requests, review threads, Actions checks, releases, and `gh` CLI usage.
- `github-upstream-sync`: Create or review GitHub Actions workflows that sync fork repositories from upstream.

## Usage Examples

- `$docs-sync Check whether the docs need updates for this diff.`
- `$flutter-flavors Audit Android/iOS flavors and check whether flavorizr.yaml matches native files.`
- `$git-workflow Help me split these changes into safe commits.`
- `$github-workflow Review this PR's checks and merge readiness.`
- `$github-upstream-sync Create a workflow that syncs my repository's main branch from upstream main every day at 4:00.`

## Quick Install

Run this from the project folder where you want the skills installed:

```bash
npx skills@latest add mabyko/AgentSkills
```

By default, `npx skills add` installs per project. Use `--global` only when you want a user-level install.

## Updating Installed Skills

For projects that already installed these skills with the `skills` CLI, use the update command:

```bash
npx skills@latest update
```

`skills update` reads the installed skill lock files, fetches the latest source, removes the old installed skill, and reinstalls the updated version. This keeps installed skills aligned with upstream changes, including files removed from `references/` or other bundled resource folders.

Use `add` for first-time installation:

```bash
npx skills@latest add mabyko/AgentSkills
```

## Install Options

List available skills without installing:

```bash
npx skills@latest add mabyko/AgentSkills --list
```

Install a specific skill:

```bash
npx skills@latest add mabyko/AgentSkills --skill docs-sync
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

## Codex Plugin

Use this path when you want Codex to install the repository as a plugin from a marketplace.

```bash
codex plugin marketplace add mabyko/AgentSkills
```

Then open Codex, go to `/plugins`, search for `agent-skills`, and install it.

Codex resolves this repository through:

```text
.agents/plugins/marketplace.json
  └── source.path: "./"
      └── .codex-plugin/plugin.json
          └── skills: "./skills/"
```

The marketplace file is the catalog entry. `.codex-plugin/plugin.json` is the plugin manifest. Skills remain in `skills/`.

## Claude Code Plugin

Use this path when you want Claude Code to install the repository as a plugin.

```bash
/plugin marketplace add mabyko/AgentSkills
/plugin install agent-skills@agent-skills
```

Claude Code reads `.claude-plugin/plugin.json` as the plugin manifest and uses the repository's top-level `skills/` directory as the skill source.

Note: Plugin installs may be cached by the host tool. If you need the latest skills, refresh, update, or reinstall the plugin through that tool's plugin manager.

`CLAUDE.md` contains:

```md
@AGENTS.md
```

This keeps Claude Code's repository guidance aligned with canonical instructions in `AGENTS.md`.

## Repository Layout

```text
skills/
└── <skill-name>/
    ├── SKILL.md
    ├── agents/openai.yaml
    ├── references/
    ├── scripts/
    └── assets/
.codex-plugin/
└── plugin.json
.claude-plugin/
└── plugin.json
.agents/
└── plugins/marketplace.json
templates/
└── skill/
scripts/
├── new-skill.sh
└── validate-skills.sh
AGENTS.md
CLAUDE.md
```

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

Skill names must use kebab-case, such as `release-notes`, `frontend-review`, or `python-debugging`.

## Skill Format

Each skill is a folder containing:

- `SKILL.md`: required
- `agents/openai.yaml`: optional OpenAI/Codex UI metadata and dependencies
- `scripts/`: optional deterministic helpers
- `references/`: optional docs loaded only when needed
- `assets/`: optional templates, images, or other files used by the skill

## License

MIT
