# AgentSkills

[한국어](README.ko.md)

Reusable agent skills for Codex, Claude Code, OpenCode, and other agents that support the open agent skills format.

Skills are maintained in the top-level `skills/` directory and selected individually through the skills CLI. Plugins provide optional hooks or the complete bundle of all skills and hooks. Codex and Claude Code expose the same two plugin choices.

## Skills

- `apple-app-icon-generator`: Generate and install Apple app icons, creating a related Debug variant only when Debug and Release use different bundle IDs.
- `apple-bundle-id-guardrails`: Protect organization App IDs and configure separate personal, additional-team, and organization Release/Debug identities with safe xcconfig defaults.
- `docs-sync`: Audit docs/code consistency, or apply requested documentation and docs-led code updates with verification.
- `flutter-flavors`: Set up or audit Flutter flavors, `flutter_flavorizr` / `flavorizr.yaml`, platform app identities, launch configs, and build-mode boundaries.
- `git-workflow`: Guide safe local Git workflows such as staging, commits, branches, merges, rebases, tags, and recovery. Defaults to signed commits with DCO sign-off (`git commit -S --signoff`) and falls back explicitly when signing is unavailable.
- `github-workflow`: Guide GitHub pull requests, stacked PRs with optional gh-stack, reviews, checks, releases, and fork upstream-sync workflows. Offers installation guidance and available tool or browser alternatives when CLI tools are missing.
- `macos-dev-app-cleanup`: Remove or verify removal of a project's macOS Debug, Dev, and QA apps by exact path, preserving Release apps, user data, and shared settings.
- `css-typography-ko`: Improve Korean web UI readability with CSS typography, covering text hierarchy, fonts, spacing, word boundaries, balanced wrapping, and overflow handling.
- `break-it-down`: Build explanations around the reader's question and the underlying mechanism. Use worked examples, diagrams, interactive models, or narrated animation to make relationships, changes, and limits understandable.

## Usage Examples

- `$apple-app-icon-generator Create app icons for this Xcode project and add a Debug variant only if the builds install side by side.`
- `$apple-bundle-id-guardrails Set up the bundle ID guardrail for this new Xcode project.`
- `$docs-sync Check whether the docs need updates for this diff.`
- `$flutter-flavors Audit Android/iOS flavors and check whether flavorizr.yaml matches native files.`
- `$git-workflow Help me split these changes into safe commits.`
- `$github-workflow Review this PR's checks and merge readiness.`
- `$github-workflow Split this feature into dependent PR layers; continue without installing gh-stack if it is unavailable.`
- `$github-workflow Create a workflow that syncs my repository's main branch from upstream main every day at 4:00.`
- `$macos-dev-app-cleanup Remove this project's macOS test apps, keeping the installed Release and shared settings.`
- `$css-typography-ko Improve this Korean web UI's readability, hierarchy, spacing, and wrapping while preserving its visual identity.`
- `$break-it-down Help me understand the current topic; choose an effective format and make the result.`
- `$break-it-down prose: Explain this notice while preserving its conditions and exceptions.`
- `$break-it-down diagram: Show the relationships and branches in this process.`
- `$break-it-down web: Let me change the rate and duration to explore compound interest.`
- `$break-it-down video: Make a 60-second explanation of this process with English narration and captions.`

`break-it-down` replaces the former `explain` skill; invoke it as `$break-it-down`. It uses the current conversation when no topic is supplied. You can choose the format in ordinary language. It uses the environment's available production tools; it does not bundle a rendering or speech engine. English technical prose uses STE-informed drafting targets; Korean follows separate language guidance. Formal English STE review requires the official rules and dictionary.

It models the question before composing the output, then checks the reasoning separately from rendering and interaction. Interactive explanations expose the affected relationships or process as well as the result. It completes the requested stage: a script-only request ends with a checked script; a finished-video request includes rendering and playback checks. [Behavioral evaluation cases and recorded checks](docs/break-it-down/cases.md) live outside the installed skill.

## Quick Install

Run this from the project folder where you want the skills installed:

```bash
npx skills@latest add mabyko/AgentSkills
```

By default, `npx skills add` installs per project. Use `--global` only when you want a user-level install.

## Install Coding Principles

Requires Bash 3.2 or later and standard Unix commands; remote installation also needs curl. Python and Node are not required. With Node.js 22.20 or later, the installer automatically uses Clack, the prompt library used by skills CLI. Otherwise, it uses the Bash UI. Teammates can install with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

In an existing checkout, run `./scripts/install-coding-principles.sh` now. In a terminal, it opens a selection UI: choose personal or project scope, select agents with Space, then review the instruction paths and apply. Use Up/Down to move and Enter to continue; q, Esc, or Ctrl-C cancels.

The Clack UI ships as a self-contained file; no npm installation is needed to run it. Remote execution downloads that optional UI before selection and removes it afterward. If it cannot be downloaded or loaded, the installer uses Bash. Both UIs use the same Bash installation and removal logic.

Select any combination of Codex, Claude Code, Grok Build, Antigravity, OpenCode, and Pi. Personal scope and Codex + Claude Code are preselected. Shared project instruction files receive the block once.

For automation, `--yes` uses the defaults without the UI. Explicit `--scope`, `--agent`, or `--project-dir` options also bypass it; use `--interactive` to open it with those options preselected. Multiple agents can be comma-separated, for example `--agent codex,opencode,pi`; `--agent all` selects all six. Without a terminal, the command uses personal scope and Codex + Claude Code unless options override them.

Show all options and examples, install for Codex globally, or review that selection in the UI:

```bash
./scripts/install-coding-principles.sh --help
./scripts/install-coding-principles.sh --scope global --agent codex
./scripts/install-coding-principles.sh --interactive --scope global --agent codex
```

Install into a project to share with teammates:

```bash
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
```

`--project-dir` requires `--scope project`. Omit it to use the current folder; add `--agent codex` to install only for Codex.

Review and commit the project instruction changes so teammates receive the principles through their normal checkout.

Choose which installation to remove through the same UI:

```bash
./scripts/install-coding-principles.sh uninstall
```

Install updates only the managed block; uninstall removes it while preserving existing instructions. See the [principles](docs/coding-principles.md) and [installation, update, and removal guide](docs/coding-principles-install.md). Start a new session after changes.

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

Note: the `skills` CLI installs skills only. The repository's [hooks](#hooks) live outside `skills/` and ship through a plugin install instead. Use one of the plugin paths below if you want them.

## Plugins

Choose the complete bundle or selected plugins from the same `mabyko` marketplace:

| Plugin | Includes |
| --- | --- |
| `agent-skills` | Complete bundle: all 9 skills and Git safety hooks |
| `git-hooks` | Git safety hook (`PreToolUse`) only; no skills |

Select individual skills by name through the skills CLI. For example, to install just the Git and GitHub skills:

```bash
npx skills@latest add mabyko/AgentSkills --skill git-workflow github-workflow
```

For every skill and hook in one install, choose `agent-skills` alone. Combining it with individual skills or hook plugins can register duplicates.

For automatic reminders, install `git-hooks` separately. It works without skills and can be removed independently. Replace `agent-skills` in the commands below with `git-hooks`.

### Skill and hook roles

Every skill works independently. This classification describes complementary behavior, not installation dependencies.

| Skill | Classification | Reason |
| --- | --- | --- |
| `git-workflow` | Skill + optional hook | The skill guides workflows and recovery; the Git hook reminds key safety rules immediately before Bash commands. |
| `github-workflow` | Skill alone | PRs, reviews, CI, and releases require task context. The Git hook does not cover direct gh/API operations. |
| `apple-app-icon-generator` | Skill alone | App identity, design choices, generation, installation, and verification are task-specific steps. |
| `apple-bundle-id-guardrails` | Skill alone | Bundle identity ownership and signing configuration require project context. |
| `macos-dev-app-cleanup` | Skill alone | First establish the authorized deletion scope and exact app paths. |
| `flutter-flavors` | Skill alone | Reconcile flavor intent with platform configuration. |
| `docs-sync` | Skill alone | Compare changes with the behavior promised by documentation. |
| `css-typography-ko` | Skill alone | Check text hierarchy and readability in the actual UI. |
| `break-it-down` | Skill alone | Choose a procedure and medium for the reader's question and the relationships being explained. |

Installing a skill does not load its entire content into every session. The agent reads it when invoked or when its description matches the task. Hooks execute on their configured events. The Git hook detects selected Bash commands; it is a reminder, not comprehensive protection against unsafe operations.

## Codex Plugin

Install for your user account:

```bash
codex plugin marketplace add mabyko/AgentSkills
codex plugin add agent-skills@mabyko
```

You can also install through `/plugins`. For plugins containing hooks, review and trust them in `/hooks` before using them; installing a plugin does not automatically trust its hooks. New or changed hook definitions can require another review. See the [Codex hooks documentation](https://learn.chatgpt.com/docs/hooks).

For use only in selected projects, keep the package installed but set this in your user configuration (`$CODEX_HOME/config.toml`, default `~/.codex/config.toml`):

```toml
[plugins."agent-skills@mabyko"]
enabled = false
```

Then enable it in each selected project's `.codex/config.toml` with the same table and `enabled = true`. Project settings apply only in trusted projects. To stop using it in that project, set its value back to `false`. This controls the whole plugin, including its skills and other hooks. See [Codex configuration precedence](https://developers.openai.com/codex/config-basic/).

Remove the installed plugin from your user account:

```bash
codex plugin remove agent-skills@mabyko
```

Codex reads `.agents/plugins/marketplace.json` and the selected plugin's `.codex-plugin/plugin.json`. `agent-skills` uses the repository root; selected plugins use `plugins/<name>/`. Each plugin loads its own registered skills and hooks.

## Claude Code Plugin

Register the marketplace, then install for your user account:

```bash
claude plugin marketplace add mabyko/AgentSkills
claude plugin install agent-skills@mabyko --scope user
```

For project installation, run from the project directory instead:

```bash
claude plugin install agent-skills@mabyko --scope project
```

Remove using the same scope as installation:

```bash
claude plugin uninstall agent-skills@mabyko --scope user
# Or, from the project directory:
claude plugin uninstall agent-skills@mabyko --scope project
```

If installed in both scopes, remove each separately. Project installation records shared project settings; use `--scope local` for settings limited to your copy of that project. See the [Claude Code plugin CLI reference](https://code.claude.com/docs/en/plugins/cli-reference).

Claude Code reads `.claude-plugin/marketplace.json` (marketplace `mabyko`) and the selected plugin's `.claude-plugin/plugin.json`. Skills and `hooks/hooks.json` are discovered inside that plugin's root.

Plugin installs may be cached by the host. Refresh, update, or reinstall through its plugin manager to get a newer version. This repository's `CLAUDE.md` imports `@AGENTS.md` to share authoring guidance.

## Hooks

Both `agent-skills` and `git-hooks` provide the existing `PreToolUse` hook, which surfaces the `git-workflow` skill's safety rules before risky Bash-invoked Git commands. It reminds once per session per category, so a `git checkout` early in a session does not consume the reminder a later `git commit` needs:

| Category | Triggers on | Reminds about |
| --- | --- | --- |
| History | `commit`, `rebase`, `merge`, `cherry-pick`, `revert`, `tag`, `push`, `reflog`, `am` | Signed commits with DCO sign-off, atomic commits, writing a commit body, no `--no-verify` / `--no-gpg-sign`, `--force-with-lease` only |
| Discard | `reset`, `clean`, `restore`, `checkout`, `switch`, `stash`, `worktree remove`, `branch -d/-D` | Checking `git status` first, asking before discarding uncommitted work or deleting refs, preferring `stash` and `revert` |

For this `PreToolUse` hook, client behavior differs because the hosts read different fields:

- Claude Code receives a non-blocking `additionalContext` hint.
- Codex denies the first matching command so the reason is displayed, then allows the retry.

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
├── marketplace.json
└── plugin.json
.agents/
└── plugins/marketplace.json
.github/
└── workflows/validate.yml
hooks/
└── hooks.json
codex-hooks/
└── hooks.json
templates/
└── skill/
scripts/
├── new-skill.sh
├── install-coding-principles.sh
├── coding-principles-ui.mjs
├── coding-principles-ui.cjs      # Bundled Clack UI; no runtime npm install
├── build-coding-principles-ui.mjs
├── build-plugin-bundles.py
├── validate-skills.sh
└── hooks/
plugins/
└── git-hooks/            # PreToolUse only
tests/
├── test_coding_principles_installer.py
├── test_git_hooks.py
└── test_plugin_bundles.py
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

The hook plugins contain generated copies so cached installs are self-contained. Edit canonical skills in `skills/` and shared hooks in `scripts/hooks/`, then refresh their bundles:

```bash
python3 scripts/build-plugin-bundles.py
```

Authoring requires Python 3.9 or later. Validation fails if the generated copies differ, including deleted files or executable permissions. Bump both host versions of the complete bundle and each affected hook plugin when its content changes.

To change the optional Node UI, edit `scripts/coding-principles-ui.mjs`, then rebuild its committed bundle with dependency licenses included. This authoring step requires Node.js 22.20 or later and npm:

```bash
npm ci --ignore-scripts
npm run build:coding-principles-ui
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
