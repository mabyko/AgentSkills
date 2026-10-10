# Install coding principles

Use the installer to add the [coding principles](coding-principles.md) to native agent instruction files. It manages one marked block, keeping existing instructions outside it intact. Skill and plugin installation do not activate these principles.

Requires Bash 3.2 or later and standard Unix commands (`dirname`, `basename`, `readlink`, `mktemp`, `mkdir`, `rm`, `mv`, `stat`, and `chmod`). Remote installation also needs curl. No Python or Node runtime is needed. Use Bash on macOS or Linux; on Windows, use a Unix environment such as WSL rather than PowerShell or CMD directly.

Once this installer is published on the repository's `main` branch, install without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

The command runs the Bash installer and downloads the principles from `main`, then installs for both agents in personal scope. The downloaded principles file is removed after execution. Until published, use the local checkout commands below.

If you already have a checkout, run `./scripts/install-coding-principles.sh` from its root. Otherwise, clone it first:

```bash
git clone https://github.com/mabyko/AgentSkills.git
cd AgentSkills
```

## Personal installation

Install for both Codex and Claude Code:

```bash
./scripts/install-coding-principles.sh
```

Default files are `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`. The installer respects `CODEX_HOME` and `CLAUDE_CONFIG_DIR`. Codex uses an existing non-empty `AGENTS.override.md` when that is the active instruction file.

Add `--agent codex` or `--agent claude` to select one agent; the default is `--agent both`.

## Project installation

From the AgentSkills checkout, specify the project folder:

```bash
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
```

This adds the block to the project's `AGENTS.md` (or an existing active `AGENTS.override.md`) and `CLAUDE.md`. Without `--project-dir`, project scope uses the current folder. Existing symlinks are followed and kept intact.

If the project already has `AGENTS.md` and the installer creates a new `CLAUDE.md`, the new file imports `AGENTS.md` to retain existing project instructions. Review and commit the project instruction changes so teammates receive them through the normal repository checkout.

After publication, run this from the target project folder to install without cloning AgentSkills:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- --scope project
```

## Update and remove

Rerun the same install command to update. Local execution uses the principles in that checkout, so update the checkout first; remote execution downloads the current `main` version. It replaces the marked block without adding duplicates. Keep personal additions outside the block; its contents are managed by the installer.

Remove personal installation:

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

Use the same agent selection and directory settings as installation. Options also work remotely: pass them after `bash -s --`. Uninstall removes only the block. A file created by the installer is removed only if no other content remains; existing files, including previously empty ones, remain. Malformed or duplicated markers stop the command before either agent's file changes.

The single Bash installer handles local and remote execution. `--help` prints its options. Local removal needs neither network access nor the original principles file. Blocks created by the former Python installer can be updated and removed with the same commands.

Start a new agent session after installing, updating, or removing instructions. Confirm that the expected instruction file appears in the agent's loaded context. Instructions guide behavior; they do not enforce compliance.

These principles adapt [Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) and [the third-party guidelines](https://github.com/multica-ai/andrej-karpathy-skills), preserving necessary protections and proportional verification.
