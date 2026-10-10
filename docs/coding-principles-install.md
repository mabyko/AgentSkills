# Install coding principles

Use the installer to add the [coding principles](coding-principles.md) to native agent instruction files. It manages one marked block, keeping existing instructions outside it intact. Skill and plugin installation do not activate these principles.

Requires Bash 3.2 or later and standard Unix commands (`dirname`, `basename`, `readlink`, `mktemp`, `mkdir`, `rm`, `mv`, `stat`, and `chmod`; the TUI also uses `stty`). Remote installation also needs curl. No Python or Node runtime is needed. Use Bash on macOS or Linux; on Windows, use a Unix environment such as WSL rather than PowerShell or CMD directly.

Once this installer is published on the repository's `main` branch, install without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

The command opens the terminal selection UI, then downloads the principles from `main` after you review and apply your choices. It reads selection input from `/dev/tty`, so piping the program into Bash also supports interaction. The downloaded principles file is removed after execution. Until published, use the local checkout commands below.

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

1. Choose personal/global or project scope with Up/Down and Enter.
2. For project scope, enter the project folder; Enter accepts the displayed folder.
3. Move through agents with Up/Down, toggle them with Space, then press Enter. Select at least one agent.
4. Review the instruction paths and apply, or cancel. q, Esc, and Ctrl-C cancel before any files change.

Personal scope and Codex + Claude Code are preselected. `uninstall` opens the same UI for removal. The UI requires a controlling terminal; `--interactive` reports an error when none is available.

## Agent instruction files

The installer supports these native defaults:

- Codex: `~/.codex/AGENTS.md` globally; `AGENTS.md` in a project. Honor `CODEX_HOME` and an existing non-empty `AGENTS.override.md`.
- Claude Code: `~/.claude/CLAUDE.md` globally; `CLAUDE.md` in a project. Honor `CLAUDE_CONFIG_DIR`.
- Grok Build: `~/.grok/AGENTS.md` globally; `AGENTS.md` in a project. See [Grok project rules](https://docs.x.ai/build/features/project-rules).
- Antigravity: `~/.gemini/GEMINI.md` globally; `AGENTS.md` in a project. See [Antigravity rules](https://www.antigravity.google/docs/rules/).
- OpenCode: `~/.config/opencode/AGENTS.md` globally; `AGENTS.md` in a project, or existing `CLAUDE.md` when there is no `AGENTS.md`. Honor `OPENCODE_CONFIG_DIR` and `XDG_CONFIG_HOME`. See [OpenCode rules](https://opencode.ai/docs/rules/) and [config path resolution](https://github.com/anomalyco/opencode/blob/dev/packages/core/src/global.ts).
- Pi: `~/.pi/agent/AGENTS.md` globally; `AGENTS.md` in a project. Honor `PI_CODING_AGENT_DIR` and use the first existing context file in Pi's order: `AGENTS.override.md`, `AGENTS.md`, `AGENTS.MD`, `CLAUDE.md`, `CLAUDE.MD`. This includes empty overrides. See [Pi configuration](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/configuration.md).

Agent selection controls the files edited. Compatible tools may also read them: project `AGENTS.md` is shared by several agents, and global `GEMINI.md` is shared with Gemini CLI. Shared paths and case-insensitive filename aliases are processed once.

## Options and automation

Explicit scope, agent, or project-folder options bypass the UI. Add `--interactive` to review those values in the UI. Use `--yes` (or `-y`) to skip interaction with the defaults; without a terminal, the same defaults apply: personal scope, Codex + Claude Code.

```bash
./scripts/install-coding-principles.sh --yes
./scripts/install-coding-principles.sh --scope global --agent codex,opencode,pi
```

Use comma-separated names or repeat `--agent`. `--agent all` selects all six; `--agent both` keeps the original Codex + Claude Code selection. `--help` lists the options.

## Project installation

From the AgentSkills checkout, specify the project folder:

```bash
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
```

This example uses the default Codex + Claude Code selection. Add `--agent` for other agents. Without `--project-dir`, project scope uses the current folder. Existing symlinks are followed and kept intact.

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
