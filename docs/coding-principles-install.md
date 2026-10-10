# Install coding principles

Use the installer to add the [coding principles](coding-principles.md) to native agent instruction files. It manages one marked block, keeping existing instructions outside it intact. Skill and plugin installation do not activate these principles.

Requires Bash 3.2 or later and standard Unix commands (`dirname`, `basename`, `readlink`, `mktemp`, `mkdir`, `rm`, `mv`, `stat`, and `chmod`; the TUI also uses `stty`). Remote installation also needs curl. Python and Node are optional. Use Bash on macOS or Linux; on Windows, use a Unix environment such as WSL rather than PowerShell or CMD directly.

Install from the repository's `main` branch without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

The command opens the terminal selection UI, then downloads the principles from `main` after you review and apply your choices. It reads selection input from `/dev/tty`, so piping the program into Bash also supports interaction. Downloaded files are removed after execution. Use a local checkout to try changes that have not reached `main`.

If you already have a checkout, run `./scripts/install-coding-principles.sh` from its root. Otherwise, clone it first:

```bash
git clone https://github.com/mabyko/AgentSkills.git
cd AgentSkills
```

## Interactive installation

Run without options in a terminal:

```bash
./scripts/install-coding-principles.sh
```

1. Choose project or personal/global scope with Up/Down and Enter.
2. Move through agents with Up/Down, toggle them with Space, then press Enter. Select at least one agent. Each agent shows its default instruction path for the chosen scope. Project agents are grouped into `Shared instructions (AGENTS.md)` and `Separate instruction files`; global agents remain individually selectable. In the Node UI, type to filter the list; selections persist while searching. Space on a group heading toggles its visible agents, and Left/Right collapses or expands the group. The Bash list shows the same group headings and paths, with individual selection in pages of eight.
3. For project scope, enter the project folder; Enter accepts the displayed folder.
4. Review the instruction paths and apply, or cancel. Esc and Ctrl-C cancel before any files change. Bash also accepts q to cancel; in the Node agent list, q is search input.

Personal scope and Codex + Claude Code are preselected. Preselecting Cursor, Junie, Kimi Code CLI, or Warp starts the scope chooser on Project because this installer only has a verified project instruction target for them. Choosing Global omits those tools from the agent list. `uninstall` opens the same UI for removal. The UI requires a controlling terminal; `--interactive` reports an error when none is available.

Project grouping follows default instruction filenames, not the skills CLI's `.agents/skills` compatibility group. Neither group is locked or automatically included: selecting only Claude Code does not create `AGENTS.md`. Selecting a shared group preserves each tool's existing-file and override rules, so it can resolve to more than one file; the final summary lists the actual paths before confirmation. With no overrides, selected tools sharing `AGENTS.md` add or remove the block only once.

With Node.js 22.20 or later, agent selection uses the [original skills CLI search renderer](https://github.com/vercel-labs/skills/blob/13e4063a1cf913f5606d57d42ab83a86f5001e04/src/prompts/search-multiselect.ts), with its search input, selection markers, selected-item summary, colors, and redraw behavior. Scope and project-folder prompts, the summary box, and Yes/No confirmation use [Clack](https://github.com/bombshell-dev/clack). The vendored renderer retains its MIT license and only adds configurable terminal streams and an abort signal for the Bash bridge.

The bundled `scripts/coding-principles-ui.cjs` includes dependencies and licenses, so running it requires neither npm nor `node_modules`. A local checkout uses that bundle; remote execution downloads it from `main` before opening the UI. If Node is absent, older, or the bundle cannot be downloaded or loaded, menus use the Bash UI. Explicit options, `--yes`, and `--help` do not load or download the optional UI. Both interfaces return selections to the same Bash code; instruction paths and managed-block handling are identical. Agent availability, default selections, and instruction-file installation remain specific to coding principles.

## Agent instruction files

The installer supports these native defaults:

- Codex: `~/.codex/AGENTS.md` globally; `AGENTS.md` in a project. Honor `CODEX_HOME` and an existing non-empty `AGENTS.override.md`.
- Claude Code: `~/.claude/CLAUDE.md` globally; `CLAUDE.md` in a project. Honor `CLAUDE_CONFIG_DIR`.
- Grok Build: `~/.grok/AGENTS.md` globally; `AGENTS.md` in a project. See [Grok project rules](https://docs.x.ai/build/features/project-rules).
- Antigravity: `~/.gemini/GEMINI.md` globally; `AGENTS.md` in a project. See [Antigravity rules](https://www.antigravity.google/docs/rules/).
- OpenCode: `~/.config/opencode/AGENTS.md` globally; `AGENTS.md` in a project, or existing `CLAUDE.md` when there is no `AGENTS.md`. Honor `OPENCODE_CONFIG_DIR` and `XDG_CONFIG_HOME`. See [OpenCode rules](https://opencode.ai/docs/rules/) and [config path resolution](https://github.com/anomalyco/opencode/blob/dev/packages/core/src/global.ts).
- Pi: `~/.pi/agent/AGENTS.md` globally; `AGENTS.md` in a project. Honor `PI_CODING_AGENT_DIR` and use the first existing context file in Pi's order: `AGENTS.override.md`, `AGENTS.md`, `AGENTS.MD`, `CLAUDE.md`, `CLAUDE.MD`. This includes empty overrides. See [Pi configuration](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/configuration.md).

The list now contains 22 agents drawn from the [skills CLI catalog](https://github.com/vercel-labs/skills/blob/13e4063a1cf913f5606d57d42ab83a86f5001e04/src/agents.ts). A skills directory is not an always-on instruction file: only agents with documented native instruction targets are listed here. This is independent of whether an agent is installed on the current PC. Agents without verified instruction targets are omitted, rather than shown as unsupported or installed as on-demand skills.

Additional instruction targets (paths shown in the chooser are defaults; the final summary shows actual destinations):

| Agent / `--agent` | Project target | Global target | Source |
| --- | --- | --- | --- |
| Amp / `amp` | `AGENTS.md` | `~/.config/amp/AGENTS.md` | [Amp guidance](https://ampcode.com/docs/customize/agents-md) |
| Cline / `cline` | `AGENTS.md` | `~/.agents/AGENTS.md` | [Cline rules](https://docs.cline.bot/customization/cline-rules) |
| Cursor / `cursor` | `AGENTS.md` | Not automated here | [Cursor rules](https://cursor.com/docs/rules) |
| Droid / `droid` | `AGENTS.md` | `~/.factory/AGENTS.md` | [Droid instructions](https://docs.factory.com/harness/agents-md) |
| Gemini CLI / `gemini-cli` | `GEMINI.md` | `~/.gemini/GEMINI.md` | [Gemini context](https://geminicli.com/docs/cli/gemini-md/) |
| GitHub Copilot / `github-copilot` | `.github/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` | [Copilot CLI instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions) |
| Goose / `goose` | `.goosehints` | `~/.config/goose/.goosehints` | [Goose hints](https://goose.vcorp.ai/docs/guides/context-engineering/using-goosehints/) |
| Junie / `junie` | `.junie/guidelines.md`, plus existing active CLI context | Not automated here | [IDE guidelines](https://www.jetbrains.com/help/junie/customize-guidelines.html), [CLI guidelines](https://junie.jetbrains.com/docs/guidelines-and-memory.html) |
| Kimi Code CLI / `kimi-code-cli` | `AGENTS.md` | Not automated here | [Kimi agent context](https://github.com/MoonshotAI/kimi-cli/blob/main/docs/en/customization/agents.md) |
| Kiro CLI / `kiro-cli` | `AGENTS.md` | `~/.kiro/steering/AGENTS.md` | [Kiro steering](https://kiro.dev/docs/steering/) |
| Mistral Vibe / `mistral-vibe` | `AGENTS.md` | `~/.vibe/AGENTS.md` | [Vibe context](https://docs.mistral.ai/vibe/code/cli/agents) |
| Qwen Code / `qwen-code` | `QWEN.md` | `~/.qwen/QWEN.md` | [Qwen memory](https://qwenlm.github.io/qwen-code-docs/en/users/features/memory/) |
| Roo Code / `roo` | `.roo/rules/coding-principles.md` | `~/.roo/rules/coding-principles.md` | [Roo instructions](https://roocodeinc.github.io/Roo-Code/features/custom-instructions/) |
| Warp / `warp` | `AGENTS.md` | Not automated here | [Warp project context](https://docs.warp.dev/getting-started/quickstart/coding-in-warp/) |
| Windsurf / `windsurf` | `AGENTS.md` | `~/.codeium/windsurf/memories/global_rules.md` | [Cascade rules](https://docs.devin.ai/desktop/cascade/memories) |
| Zed / `zed` | First existing project instruction file, otherwise `AGENTS.md` | `~/.config/zed/AGENTS.md` | [Zed instructions](https://zed.dev/docs/ai/instructions) |

Copilot's global file is for Copilot CLI; other Copilot integrations have their own personal instruction mechanisms. Honor `COPILOT_HOME` for that CLI and `VIBE_HOME` for Mistral Vibe. Goose requires its Developer extension. Rules explicitly disabled in a tool's settings remain disabled. Kiro custom agents may require steering resources in their configuration; this installer does not edit agent definitions.

Junie updates its IDE-compatible guidelines file and, when present, `.junie/AGENTS.md` or the root `AGENTS.md` used by its CLI. Removal checks all three. If a project has legacy `.roorules`, the new Roo rule includes a managed pointer telling the agent to read that file, which remains untouched. The pointer persists on updates and is removed with the block. Zed uses the first existing file in its documented order: `.rules`, `.cursorrules`, `.windsurfrules`, `.clinerules`, `.github/copilot-instructions.md`, `AGENT.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`. Removal checks these files without deleting rule directories.

Windsurf's global rule file has a 6,000-character cap. The installer conservatively rejects updates over 6,000 bytes before any selected instruction file changes; Unicode-heavy files can reach that guard earlier. Use project scope for longer rules. Existing instruction files and their permissions are preserved on removal; empty directories created during installation remain.

Agent selection controls the files edited. Compatible tools may also read them: project `AGENTS.md` is shared by several agents, and global `GEMINI.md` is shared with Gemini CLI. Shared paths and case-insensitive filename aliases are processed once.

## Options and automation

Explicit scope, agent, or project-folder options bypass the UI. Add `--interactive` to review those values in the UI. Use `--yes` (or `-y`) to skip interaction with the defaults; without a terminal, the same defaults apply: personal scope, Codex + Claude Code.

```bash
./scripts/install-coding-principles.sh --yes
./scripts/install-coding-principles.sh --scope global --agent codex,opencode,pi
```

Use comma-separated names or repeat `--agent`. `--agent all` selects all verified agents available for the chosen scope (22 in project scope, 18 in global scope); `--agent both` keeps the original Codex + Claude Code selection. `claude-code` is accepted as an alias for `claude`. Explicit global selection of a project-only agent fails before any instruction files change. `--help` lists the options.

## Project installation

From the AgentSkills checkout, specify the project folder:

```bash
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
```

This example uses the default Codex + Claude Code selection. Add `--agent` for other agents. `--project-dir` requires `--scope project`; without it, project scope uses the current folder. Existing symlinks are followed and kept intact.

If the project already has `AGENTS.md` and the installer creates a new `CLAUDE.md`, the new file imports `AGENTS.md` to retain existing project instructions. Review and commit the project instruction changes so teammates receive them through the normal repository checkout.

If creating a new project `AGENTS.md` would hide an existing fallback instruction file, the new block tells the agent to read that file. The pointer remains on updates and is removed with the block.

The same applies when creating OpenCode's global `AGENTS.md` while it was using `~/.claude/CLAUDE.md` as a fallback. The pointer is omitted when Claude compatibility or its global prompt is disabled. These pointers instruct the agent to read the previous file; they are not native file imports.

After publication, run this from the target project folder to install without cloning AgentSkills:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- --scope project
```

## Update and remove

Rerun the same install command to update. Local execution uses the principles in that checkout, so update the checkout first; remote execution downloads the current `main` version. It replaces the marked block without adding duplicates. Keep personal additions outside the block; its contents are managed by the installer.

Choose an installation to remove interactively:

```bash
./scripts/install-coding-principles.sh uninstall
```

Remove project installation:

```bash
./scripts/install-coding-principles.sh uninstall --scope project --project-dir /path/to/project
```

For remote removal after publication:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- uninstall
```

Use the same agent selection and directory settings as installation. To remove the default personal installation without the UI, use `uninstall --yes`. Options also work remotely: pass them after `bash -s --`. Uninstall removes only the block. A file created by the installer is removed only if no other content remains; existing files, including previously empty ones, remain. Malformed or duplicated markers stop the command before any agent's file changes.

The single Bash installer handles local and remote execution. `--help` prints its options. Local removal needs neither network access nor the original principles file. Blocks created by the former Python installer can be updated and removed with the same commands.

Start a new agent session after installing, updating, or removing instructions. Confirm that the expected instruction file appears in the agent's loaded context. Instructions guide behavior; they do not enforce compliance.

These principles adapt [Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) and [the third-party guidelines](https://github.com/multica-ai/andrej-karpathy-skills), preserving necessary protections and proportional verification.
