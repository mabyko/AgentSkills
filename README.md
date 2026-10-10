# AgentSkills

[한국어](README.ko.md)

Reusable skills for Codex, Claude Code, OpenCode, and other agents that support the open agent skills format. Choose the parts you need:

| Component | Purpose | Installation |
| --- | --- | --- |
| [Skills](#skills) | Task workflows, read when invoked or selected by the agent for a matching task | [Skills CLI](#install-skills) |
| [Hook plugins](#hook-plugins) | Safety reminders before selected Bash commands in Codex and Claude Code | Each host's plugin manager |
| [Coding principles](#coding-principles) | Coding rules in native instruction files, loaded within the selected scope | Bash installer |

These are independent installations. Installing a skill or hook plugin does not install the other components.

## Install skills

Run from the project folder, then select skills and agents:

```bash
npx skills@latest add mabyko/AgentSkills
```

Installation is per project by default. List skills, select particular skills or agents, or install globally:

```bash
# List without installing
npx skills@latest add mabyko/AgentSkills --list

# Install only the Git and GitHub skills
npx skills@latest add mabyko/AgentSkills --skill git-workflow github-workflow

# Choose target agents
npx skills@latest add mabyko/AgentSkills -a claude-code -a codex -a opencode

# Install for your user account
npx skills@latest add mabyko/AgentSkills --global
```

The CLI discovers the canonical skills in `skills/` and installs your selections into each agent's skill location. To update installed skills:

```bash
npx skills@latest update
```

## Skills

### Git and GitHub

- `git-workflow`: Guide local Git workflows: staging, commits, branches, merges, rebases, tags, and recovery. Defaults to signed commits with DCO sign-off (`git commit -S --signoff`), with an explicit fallback when signing is unavailable.
- `github-workflow`: Guide pull requests, stacked PRs with optional gh-stack, reviews, checks, releases, and fork upstream sync. Provides installation guidance or tool/browser alternatives when CLI tools are missing.
- `prepare-release-github`: Prepare versions, release PRs, exact-commit CI evidence, and deployment handoffs using repository release rules. Preparation ends before publishing or deploying.

### Apple and Flutter

- `apple-app-icon-generator`: Generate and install Apple app icons, adding a related Debug variant when Debug and Release use different bundle IDs.
- `apple-bundle-id-guardrails`: Protect organization App IDs and configure separate personal, additional-team, and organization Release/Debug identities with safe xcconfig defaults.
- `macos-dev-app-cleanup`: Remove or verify removal of a project's macOS Debug, Dev, and QA apps by exact path, preserving Release apps, user data, and shared settings.
- `flutter-flavors`: Set up or audit Flutter flavors, `flutter_flavorizr` / `flavorizr.yaml`, platform app identities, launch configs, and build-mode boundaries.

### Documentation, UI, and explanations

- `docs-sync`: Audit docs/code consistency, or apply requested documentation and docs-led code updates with verification.
- `css-typography-ko`: Improve Korean web UI readability through text hierarchy, fonts, spacing, word boundaries, wrapping, and overflow handling.
- `break-it-down`: Explain a question through its underlying mechanism, using worked examples, diagrams, interactive models, or narrated animation to show relationships, changes, and limits.

### Usage examples

Invoke a skill explicitly, or describe a task that matches it:

```text
$git-workflow Help me split these changes into safe commits.
$github-workflow Split this feature into dependent PR layers.
$prepare-release-github Prepare the next release and deployment handoff; leave deployment to the operator.
$apple-bundle-id-guardrails Set up bundle ID guardrails for this Xcode project.
$docs-sync Check whether the docs need updates for this diff.
$break-it-down diagram: Show the relationships and branches in this process.
```

`break-it-down` replaces the former `explain` skill. It uses the current conversation when no topic is supplied; choose prose, a diagram, an interactive web model, or video in ordinary language. It uses available production tools rather than bundling a rendering or speech engine. It completes the requested stage: a script request ends with a checked script; a finished-video request includes rendering and playback checks. See the [skill instructions](skills/break-it-down/SKILL.md) and [behavioral evaluation cases](docs/break-it-down/cases.md) for format guidance, language rules, and verification details.

## Hook plugins

Choose optional plugins from the `mabyko` marketplace:

| Plugin | Reminders |
| --- | --- |
| `git-hooks` | Git history changes and work/ref deletion |
| `github-hooks` | GitHub PR publication/landing, stack changes, and release mutations |
| `apple-dev-hooks` | Apple identity/signing and macOS development app cleanup, including Flutter Apple builds |

All three plugins contain hooks only and work without skills. Each reminder includes core rules and suggests reading the matching skill if available. Plugins do not install skills, require them, or automatically execute their procedures. Hook rules and skill instructions are maintained separately; they do not synchronize at runtime.

Skills provide the detailed workflow: `git-workflow` for Git, `github-workflow` for PRs/stacks/releases, `apple-bundle-id-guardrails` for Apple identities, `macos-dev-app-cleanup` for cleanup, and `flutter-flavors` for flavor configuration. Automatic skill selection is allowed for `github-workflow`, but its full instructions and references are read only when selected and needed. A hook supplies reminders before matching commands; it does not guarantee every check was performed. The Apple plugin does not generate icons or change flavor settings.

The commands below use `git-hooks`. Substitute `github-hooks` or `apple-dev-hooks`, or install the plugins you need separately.

### Codex

Register the marketplace and install for your user account:

```bash
codex plugin marketplace add mabyko/AgentSkills
codex plugin add git-hooks@mabyko
```

You can also install through `/plugins`. After installation, review and trust the hooks in `/hooks`; installation alone does not trust them. New or changed hook definitions can require another review. See the [Codex hooks documentation](https://learn.chatgpt.com/docs/hooks).

<details>
<summary>Enable only in selected projects</summary>

Keep the package installed and disable it in your user configuration (`$CODEX_HOME/config.toml`, default `~/.codex/config.toml`):

```toml
[plugins."git-hooks@mabyko"]
enabled = false
```

Enable it in each selected project's `.codex/config.toml` using the same table with `enabled = true`. Project settings apply only in trusted projects. Set it back to `false` to stop using it in that project. See [Codex configuration precedence](https://developers.openai.com/codex/config-basic/).

</details>

Remove the installed plugin:

```bash
codex plugin remove git-hooks@mabyko
```

### Claude Code

Register the marketplace and install for your user account:

```bash
claude plugin marketplace add mabyko/AgentSkills
claude plugin install git-hooks@mabyko --scope user
```

For a shared project installation, run from the project directory:

```bash
claude plugin install git-hooks@mabyko --scope project
```

Use `--scope local` for settings limited to your copy of the project. Remove using the original installation scope; if installed in multiple scopes, remove each separately:

```bash
claude plugin uninstall git-hooks@mabyko --scope user
# Or, from the project directory:
claude plugin uninstall git-hooks@mabyko --scope project
```

See the [Claude Code plugin CLI reference](https://code.claude.com/docs/en/plugins/cli-reference).

For either host, plugin installs may be cached. Refresh, update, or reinstall through the host's plugin manager to get a newer version.

### Hook behavior and limits

All three plugins use `PreToolUse` and remind once per session per category. Claude Code receives a non-blocking `additionalContext` hint. Codex denies the first matching command to display the reason, then allows the retry. GitHub PR publication and landing, stack history/publication/landing, and releases have separate categories, so creating a PR does not consume its merge reminder.

<details>
<summary>Triggers and safety reminders</summary>

| Plugin / category | Triggers | Reminders |
| --- | --- | --- |
| Git / history | `commit`, `rebase`, `merge`, `cherry-pick`, `revert`, `tag`, `push`, `reflog`, `am` | Signed commits with DCO sign-off, atomic commits and commit bodies, no `--no-verify` / `--no-gpg-sign`, `--force-with-lease` only |
| Git / discard | `reset`, `clean`, `restore`, `checkout`, `switch`, `stash`, `worktree remove`, `branch -d/-D` | Check `git status`, confirm before discarding uncommitted work or deleting refs, prefer `stash` and `revert` |
| GitHub / PR write | `gh pr create/edit/ready/reopen/review/comment` | Exact repository and head/base, PR template, draft state, established stack parent, authorization for comments/reviews |
| GitHub / PR landing | `gh pr merge/close` | Exact head and authorization, checks/annotations/reviews, branch protection, Stack membership, requested merge mode, remote result |
| GitHub / stack history | `gh stack init/add/rebase` | Trunk and layer chain, clean/idle worktrees, shared-history authorization, signing/DCO including implicit commits |
| GitHub / stack publication | `gh stack submit/push/sync` | Remote and layer scope, implicit rebase/force-push, separate pruning scope, PR templates, actual state after synchronization |
| GitHub / stack landing | `gh stack merge` | All layers included in the merge, checks/reviews/trunk rules, Stack-aware landing, remote result |
| GitHub / release | `gh release create/edit/upload/delete/delete-asset` | Release policy, tag/candidate SHA/CI/assets, draft/latest state, explicit publication/deletion scope, recovery and remote verification |
| Apple / identity | `xcodebuild`, `codesign` signing, selected `xcrun simctl`/`devicectl` install/launch commands, `flutter build ios/ipa/macos`, `flutter run` explicitly targeting `ios`/`macos` | Effective bundle ID and signing team for every target, registered organization IDs, personal identity isolation, Flutter flavor-to-Xcode mappings |
| Apple / cleanup | `rm` mentioning `.app`, `DerivedData`, or `build/macos`; selected `find` app deletions; `lsregister -u`; `defaults delete` | Existing authorization, exact app provenance/paths, preserve Release apps and shared data, normal quit, scoped unregistering, verify removal |

</details>

Matching uses raw hook text, so quoted examples can trigger reminders and wrappers, variables, or scripts can escape detection. `git-hooks` matches Git commands; `github-hooks` matches the listed `gh pr`, `gh stack`, and `gh release` commands, including reminders about implicit Git changes in stacks. It does not cover `gh api`, MCP/browser actions, or global flags inserted before those subcommands. Read-only commands such as `gh pr view/checks`, `gh stack view`, and `gh release view` are quiet. The Apple hook can miss Flutter device IDs that do not identify the platform. `xcodebuild` queries can trigger an identity reminder, but requested read-only checks need no additional approval.

The hooks never execute the intercepted command themselves. If GitHub or Apple session state cannot be saved, the hook reports it on stderr and lets the command proceed so Codex retries remain possible.

### Migrating from the former bundle

The `agent-skills` complete bundle has been removed from the marketplace. Existing cached installs remain until you uninstall them:

```bash
codex plugin remove agent-skills@mabyko
claude plugin uninstall agent-skills@mabyko --scope user
```

For Claude Code, use the original installation scope. Then install the skills and hook plugins you need separately.

## Coding principles

Install the [coding principles](docs/coding-principles.md) into native instruction files such as `AGENTS.md` and `CLAUDE.md`. These rules apply within the selected scope without invoking a skill. No repository clone is needed:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

The installer requires Bash 3.2 or later and standard Unix commands; remote installation also needs curl. Python and Node are optional. With Node.js 22.20 or later, it uses the bundled skills CLI search chooser and Clack prompts, with no runtime npm installation. Otherwise, or if the optional UI cannot be downloaded or loaded, it uses the Bash UI.

### Choose scope and agents

Choose personal or project scope, select agents with Space, then review the instruction paths and confirm. Personal scope and Codex + Claude Code are preselected. Use Up/Down to move, Enter to continue, and Esc or Ctrl-C to cancel. The Node chooser supports search and group selection/collapse; q cancels only in the Bash UI.

The chooser shows verified instruction targets: 22 tools for project scope and 18 for global scope, regardless of whether the tool is installed on your PC. Cursor, Junie, Kimi Code CLI, and Warp are project-only. Project tools are grouped by shared `AGENTS.md` defaults and separate files; neither group is mandatory. Shared files receive the block once, and the final summary shows resolved paths. See [agent paths and compatibility](docs/coding-principles-install.md#agent-instruction-files).

### Options, updates, and removal

In an existing checkout:

```bash
./scripts/install-coding-principles.sh --help
./scripts/install-coding-principles.sh --scope global --agent codex
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
./scripts/install-coding-principles.sh --interactive --scope global --agent codex
./scripts/install-coding-principles.sh uninstall
```

For remote execution with options, use `bash -s --` after the pipe, for example:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- --scope project --agent codex
```

Explicit scope, agent, or project-directory options skip the UI; add `--interactive` to review those selections. `--project-dir` requires `--scope project`; omitting it uses the current folder. Use comma-separated or repeated `--agent` options for multiple agents, or `--agent all` for all supported targets in that scope. `--yes` applies defaults without the UI. Without a terminal, defaults are global scope and Codex + Claude Code unless overridden.

Run the installer again to update the managed block. Removal uses the same scope, agents, and project directory as installation; the interactive `uninstall` command lets you choose them. Existing instructions outside the block, permissions, and symlinks are preserved. To remove without a clone:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- uninstall
```

Review and commit project instruction changes to share them with teammates. Start a new agent session after changes. See the [installation, update, and removal guide](docs/coding-principles-install.md) for details.

## Contributing

Use [AGENTS.md](AGENTS.md) for the full authoring rules. The repository root is a skill source and plugin marketplace; it is not an installable plugin.

### Skills

Start a new skill in the canonical `skills/` directory:

```bash
scripts/new-skill.sh my-skill
```

Use kebab-case names. Each skill requires `SKILL.md` with YAML frontmatter containing only `name` and a trigger-focused `description`. Keep the workflow concise and add the skill to the Skills section of both READMEs.

Optional resources are `agents/openai.yaml` for UI metadata and dependencies, `references/` for detailed guidance, `scripts/` for deterministic helpers, and `assets/` for reusable files. Quote string values in `openai.yaml` and include `$my-skill` in its default prompt. Do not add README or installation docs inside skill folders.

### Hooks and installer UI

Edit shared hooks in `scripts/hooks/` and their registration mapping in `scripts/build-plugin-bundles.py`, then refresh the self-contained plugin copies:

```bash
python3 scripts/build-plugin-bundles.py
```

Authoring requires Python 3.9 or later. Keep hook scripts executable. When plugin content changes, bump matching versions in both host manifests of each affected plugin; skill-only changes need no plugin version bump.

To change the optional Node UI, edit `scripts/coding-principles-ui.mjs` and rebuild with Node.js 22.20 or later and npm:

```bash
npm ci --ignore-scripts
npm run build:coding-principles-ui
```

Preserve the pinned skills CLI source and MIT license in `scripts/vendor/skills-search-multiselect.ts`. Local changes there are limited to terminal streams and cancellation.

### Validation and layout

Before opening a pull request:

```bash
scripts/validate-skills.sh
python3 -B -m unittest discover -s tests
```

CI also rebuilds the Node UI and rejects stale bundles. Validation checks skill metadata, README skill lists, plugin copies, matching host versions, hook paths, and executable permissions.

```text
skills/<skill-name>/              # Canonical skills and optional resources
scripts/hooks/                   # Canonical hook implementations
plugins/git-hooks/               # Self-contained hook plugin, both hosts
plugins/github-hooks/            # Self-contained hook plugin, both hosts
plugins/apple-dev-hooks/         # Self-contained hook plugin, both hosts
.claude-plugin/marketplace.json   # Claude Code marketplace
.agents/plugins/marketplace.json # Codex marketplace
docs/                            # Coding principles and detailed guides
scripts/                         # Installers, generators, UI, and validation
templates/skill/                 # New-skill template
tests/                           # Installer, hook, and packaging checks
.github/workflows/validate.yml   # CI checks
AGENTS.md                        # Authoring rules; CLAUDE.md imports these
```

## License

MIT
