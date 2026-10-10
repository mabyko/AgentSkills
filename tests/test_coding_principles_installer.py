import os
import fcntl
import pty
import re
import select
import signal
import shutil
import struct
from pathlib import Path
import subprocess
import tempfile
import termios
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/install-coding-principles.sh"
START = b"<!-- AgentSkills:coding-principles:start -->"
END = b"<!-- AgentSkills:coding-principles:end -->"


class CodingPrinciplesInstallerTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.codex = self.directory / "codex"
        self.claude = self.directory / "claude"
        self.home = self.directory / "home"
        self.home.mkdir()
        self.xdg = self.directory / "xdg"
        self.pi = self.directory / "pi"
        self.project = self.directory / "project with spaces"
        self.project.mkdir()
        self.binaries = self.directory / "bin"
        self.binaries.mkdir()
        # Bash coverage excludes interpreters; Node UI tests opt in explicitly.
        for command in ("bash", "basename", "dirname", "readlink", "mktemp", "cp", "mkdir", "rm", "mv", "stat", "chmod", "stty"):
            self.binaries.joinpath(command).symlink_to("/bin/bash" if command == "bash" else shutil.which(command))
        self.env = dict(os.environ, PATH=str(self.binaries), HOME=str(self.home), XDG_CONFIG_HOME=str(self.xdg), OPENCODE_CONFIG_DIR=str(self.xdg / "opencode"), OPENCODE_DISABLE_CLAUDE_CODE="", OPENCODE_DISABLE_CLAUDE_CODE_PROMPT="", PI_CODING_AGENT_DIR=str(self.pi), CODEX_HOME=str(self.codex), CLAUDE_CONFIG_DIR=str(self.claude), COPILOT_HOME=str(self.home / ".copilot"), VIBE_HOME=str(self.home / ".vibe"))

    def run_installer(self, action, scope="global", agent="both", *extra):
        return subprocess.run([str(SCRIPT), action, "--scope", scope, "--agent", agent, *extra], cwd=self.project, env=self.env, capture_output=True, text=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_round_trip_preserves_existing_text_and_permissions(self):
        for original, mode in ((b"", 0o640), (b"Existing instructions", 0o640), (b"Existing instructions\n", 0o640), (b"Existing instructions\r\n", 0o640), ("기존 지침\n".encode(), 0o640), (b"Read-only instructions\n", 0o440)):
            with self.subTest(original=original, mode=mode):
                self.codex.mkdir(exist_ok=True)
                self.claude.mkdir(exist_ok=True)
                paths = (self.codex / "AGENTS.md", self.claude / "CLAUDE.md")
                for path in paths:
                    path.write_bytes(original)
                    path.chmod(mode)
                self.assert_success(self.run_installer("install"))
                installed = [path.read_bytes() for path in paths]
                for data in installed:
                    self.assertEqual(data.count(START), 1)
                    self.assertIn((ROOT / "docs/coding-principles.md").read_bytes().rstrip(), data)
                self.assert_success(self.run_installer("install"))
                self.assertEqual([path.read_bytes() for path in paths], installed)
                self.assert_success(self.run_installer("uninstall"))
                for path in paths:
                    self.assertEqual(path.read_bytes(), original)
                    self.assertEqual(path.stat().st_mode & 0o777, mode)

    def test_project_and_agent_selection_stay_in_scope(self):
        self.assert_success(self.run_installer("install", "project", "codex"))
        self.assertTrue((self.project / "AGENTS.md").is_file())
        self.assertFalse((self.project / "CLAUDE.md").exists())
        self.assertFalse(self.codex.exists())
        explicit = self.directory / "another project"
        explicit.mkdir()
        self.assert_success(self.run_installer("install", "project", "claude", "--project-dir", str(explicit)))
        self.assertTrue((explicit / "CLAUDE.md").is_file())
        self.assertFalse((explicit / "AGENTS.md").exists())
        self.assertFalse(self.claude.exists())

    def test_malformed_block_stops_before_either_file_changes(self):
        self.codex.mkdir()
        self.claude.mkdir()
        codex = self.codex / "AGENTS.md"
        claude = self.claude / "CLAUDE.md"
        codex.write_bytes(b"Existing Codex instructions\n")
        for malformed in (START, START + END + START + END, END + START, START + b"\n" + END + b"\n", b"\n\n" + START + b"\n" + END):
            with self.subTest(malformed=malformed):
                claude.write_bytes(malformed)
                result = self.run_installer("install")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(str(claude), result.stderr)
                self.assertEqual(codex.read_bytes(), b"Existing Codex instructions\n")
                self.assertEqual(claude.read_bytes(), malformed)

    def test_override_is_used_without_hiding_base_instructions(self):
        self.codex.mkdir()
        base = self.codex / "AGENTS.md"
        override = self.codex / "AGENTS.override.md"
        base.write_bytes(b"Base instructions\n")
        override.write_bytes(b"Active override\n")
        self.assert_success(self.run_installer("install", "global", "codex"))
        self.assertEqual(base.read_bytes(), b"Base instructions\n")
        self.assertIn(START, override.read_bytes())
        self.assert_success(self.run_installer("uninstall", "global", "codex"))
        self.assertEqual(override.read_bytes(), b"Active override\n")
        override.write_bytes(b"")
        self.assert_success(self.run_installer("install", "global", "codex"))
        self.assertIn(START, base.read_bytes())
        self.assertEqual(override.read_bytes(), b"")
        override.write_bytes(b"A later override\n")
        self.assert_success(self.run_installer("uninstall", "global", "codex"))
        self.assertEqual(base.read_bytes(), b"Base instructions\n")
        self.assertEqual(override.read_bytes(), b"A later override\n")

    def test_symlink_and_later_content_survive_uninstall(self):
        self.codex.mkdir()
        shared = self.directory / "shared.md"
        shared.write_bytes(b"Shared instructions\n")
        link = self.codex / "AGENTS.md"
        link.symlink_to(shared)
        self.assert_success(self.run_installer("install", "global", "codex"))
        shared.write_bytes(shared.read_bytes() + b"Later user instructions\n")
        self.assert_success(self.run_installer("uninstall", "global", "codex"))
        self.assertTrue(link.is_symlink())
        self.assertEqual(shared.read_bytes(), b"Shared instructions\nLater user instructions\n")

    def test_relative_links_and_shared_destination_are_preserved(self):
        actual = self.directory / "actual config"
        actual.mkdir()
        self.codex.symlink_to(actual, target_is_directory=True)
        shared = actual / "shared.md"
        shared.write_bytes(b"Shared rules\n")
        codex = self.codex / "AGENTS.md"
        claude = actual / "CLAUDE.md"
        codex.symlink_to("shared.md")
        claude.symlink_to("shared.md")
        self.env["CLAUDE_CONFIG_DIR"] = str(actual)
        result = self.run_installer("install")
        self.assert_success(result)
        self.assertEqual(shared.read_bytes().count(START), 1)
        self.assertEqual(len(result.stdout.splitlines()), 1)
        self.assert_success(self.run_installer("uninstall"))
        self.assertEqual(shared.read_bytes(), b"Shared rules\n")
        self.assertTrue(self.codex.is_symlink())
        self.assertTrue(codex.is_symlink())
        self.assertTrue(claude.is_symlink())

    def test_old_python_installer_block_can_be_updated_and_removed(self):
        self.codex.mkdir()
        destination = self.codex / "AGENTS.md"
        destination.write_bytes(b"Original instructions\r\n\n\n" + START + b"\n## Old principles\n" + END + b"\nLater instructions")
        self.assert_success(self.run_installer("install", "global", "codex"))
        self.assertNotIn(b"Old principles", destination.read_bytes())
        self.assert_success(self.run_installer("uninstall", "global", "codex"))
        self.assertEqual(destination.read_bytes(), b"Original instructions\r\nLater instructions")

    def test_install_refreshes_changed_principles_without_duplicates(self):
        fixture = self.directory / "installer"
        (fixture / "scripts").mkdir(parents=True)
        (fixture / "docs").mkdir()
        script = fixture / "scripts/install-coding-principles.sh"
        source = fixture / "docs/coding-principles.md"
        shutil.copy2(SCRIPT, script)
        source.write_bytes(b"## Original principles\n")
        self.codex.mkdir()
        destination = self.codex / "AGENTS.md"
        destination.write_bytes(b"User instructions\n")
        command = [str(script), "install", "--scope", "global", "--agent", "codex"]
        self.assert_success(subprocess.run(command, env=self.env, capture_output=True, text=True))
        source.write_bytes(b"## Updated principles\n")
        self.assert_success(subprocess.run(command, env=self.env, capture_output=True, text=True))
        content = destination.read_bytes()
        self.assertTrue(content.startswith(b"User instructions\n"))
        self.assertIn(b"Updated principles", content)
        self.assertNotIn(b"Original principles", content)
        self.assertEqual(content.count(START), 1)

    def test_uninstall_missing_install_does_not_create_files(self):
        self.assert_success(self.run_installer("uninstall"))
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.claude.exists())

    def test_new_files_are_removed_but_existing_empty_files_are_preserved(self):
        self.assert_success(self.run_installer("install"))
        self.assert_success(self.run_installer("install"))
        self.assert_success(self.run_installer("uninstall"))
        self.assertFalse((self.codex / "AGENTS.md").exists())
        self.assertFalse((self.claude / "CLAUDE.md").exists())

    def test_new_claude_file_preserves_existing_project_agents_guidance(self):
        agents = self.project / "AGENTS.md"
        agents.write_bytes(b"Existing project rules\n")
        self.assert_success(self.run_installer("install", "project", "claude"))
        claude = self.project / "CLAUDE.md"
        self.assertIn(b"@AGENTS.md\n", claude.read_bytes())
        self.assertEqual(agents.read_bytes(), b"Existing project rules\n")
        self.assert_success(self.run_installer("install", "project", "claude"))
        self.assertEqual(claude.read_bytes().count(b"@AGENTS.md\n"), 1)
        self.assert_success(self.run_installer("uninstall", "project", "claude"))
        self.assertFalse(claude.exists())
        self.assertEqual(agents.read_bytes(), b"Existing project rules\n")

    def test_invalid_project_does_not_create_it(self):
        missing = self.directory / "missing project"
        result = self.run_installer("install", "project", "both", "--project-dir", str(missing))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(missing.exists())
        result = self.run_installer("install", "global", "both", "--project-dir", str(self.project))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.codex.exists())

    def test_local_short_command_defaults_to_global_and_forwards_project_options(self):
        for args in ([], ["uninstall"]):
            self.assert_success(subprocess.run([str(SCRIPT), *args], cwd=self.project, env=self.env, capture_output=True, text=True))
            self.assertEqual((self.codex / "AGENTS.md").exists(), not args)
            self.assertEqual((self.claude / "CLAUDE.md").exists(), not args)
        self.assert_success(subprocess.run([str(SCRIPT), "--scope", "project", "--agent", "claude"], cwd=self.project, env=self.env, capture_output=True, text=True))
        self.assertTrue((self.project / "CLAUDE.md").exists())
        self.assertFalse((self.project / "AGENTS.md").exists())
        self.assertFalse((self.codex / "AGENTS.md").exists())

    def remote_environment(self, fail_document=False):
        curl = self.binaries / "curl"
        curl.write_text('''#!/bin/bash
set -e
[[ "$1" == -fsSL && "$3" == -o ]]
printf '%s\\n' "$2" >> "$DOWNLOAD_LOG"
case "$2" in
  https://raw.githubusercontent.com/mabyko/AgentSkills/main/docs/coding-principles.md)
    [[ -z "${FAIL_DOCUMENT:-}" ]] || exit 22
    cp "$FIXTURE_ROOT/docs/coding-principles.md" "$4" ;;
  https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/coding-principles-ui.cjs)
    [[ -z "${FAIL_UI:-}" ]] || exit 22
    cp "$FIXTURE_ROOT/scripts/coding-principles-ui.cjs" "$4" ;;
  *) exit 22 ;;
esac
''')
        curl.chmod(0o755)
        temporary = self.directory / "downloads"
        temporary.mkdir()
        env = dict(self.env, TMPDIR=str(temporary), FIXTURE_ROOT=str(ROOT), DOWNLOAD_LOG=str(self.directory / "download.log"))
        if fail_document:
            env["FAIL_DOCUMENT"] = "1"
        return env, temporary

    def test_piped_bootstrap_installs_removes_and_keeps_project_cwd(self):
        env, temporary = self.remote_environment()
        for args in ([], ["uninstall"], ["--scope", "project", "--agent", "codex"]):
            result = subprocess.run(["/bin/bash", "-s", "--", *args], input=SCRIPT.read_text(), cwd=self.project, env=env, capture_output=True, text=True)
            self.assert_success(result)
            self.assertEqual(list(temporary.iterdir()), [])
            if not args:
                self.assertIn(START, (self.codex / "AGENTS.md").read_bytes())
                self.assertIn(START, (self.claude / "CLAUDE.md").read_bytes())
            else:
                self.assertFalse((self.codex / "AGENTS.md").exists())
                self.assertFalse((self.claude / "CLAUDE.md").exists())
        self.assertIn(START, (self.project / "AGENTS.md").read_bytes())
        self.assertFalse((self.project / "CLAUDE.md").exists())
        self.assertEqual(len(Path(env["DOWNLOAD_LOG"]).read_text().splitlines()), 2)

    def test_failed_download_cleans_up_without_changing_instructions(self):
        env, temporary = self.remote_environment(fail_document=True)
        self.codex.mkdir()
        agents = self.codex / "AGENTS.md"
        agents.write_bytes(b"Existing instructions\n")
        result = subprocess.run(["/bin/bash", "-s"], input=SCRIPT.read_text(), cwd=self.project, env=env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(agents.read_bytes(), b"Existing instructions\n")
        self.assertFalse(self.claude.exists())
        self.assertEqual(list(temporary.iterdir()), [])

    def test_invalid_arguments_help_and_binary_input_leave_files_unchanged(self):
        for args in (["--scope"], ["--scope", "invalid"], ["--agent", "invalid"], ["unknown"]):
            result = subprocess.run([str(SCRIPT), *args], cwd=self.project, env=self.env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(self.codex.exists())
            self.assertFalse(self.claude.exists())
        help_result = subprocess.run([str(SCRIPT), "--help"], env=self.env, capture_output=True, text=True)
        self.assert_success(help_result)
        self.assertIn("Usage:", help_result.stdout)
        self.codex.mkdir()
        self.claude.mkdir()
        agents = self.codex / "AGENTS.md"
        agents.write_bytes(b"Keep this\n")
        claude = self.claude / "CLAUDE.md"
        claude.write_bytes(b"Before\x00after")
        self.assertNotEqual(self.run_installer("install").returncode, 0)
        self.assertEqual(agents.read_bytes(), b"Keep this\n")
        self.assertEqual(claude.read_bytes(), b"Before\x00after")

    def test_all_global_agents_and_repeated_selection_round_trip(self):
        paths = (self.codex / "AGENTS.md", self.claude / "CLAUDE.md", self.home / ".grok/AGENTS.md", self.home / ".gemini/GEMINI.md", self.xdg / "opencode/AGENTS.md", self.pi / "AGENTS.md")
        for path in paths:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"Existing rules\r\n")
        for action in ("install", "install", "uninstall"):
            self.assert_success(self.run_installer(action, "global", "all", "--agent", "pi,opencode"))
        for path in paths:
            self.assertEqual(path.read_bytes(), b"Existing rules\r\n")

    def test_shared_project_files_are_changed_only_once(self):
        result = self.run_installer("install", "project", "all")
        self.assert_success(result)
        self.assertEqual(len(result.stdout.splitlines()), 8)
        for name in ("AGENTS.md", "CLAUDE.md", "GEMINI.md", "QWEN.md", ".github/copilot-instructions.md", ".goosehints", ".junie/guidelines.md", ".roo/rules/coding-principles.md"):
            self.assertEqual((self.project / name).read_bytes().count(START), 1)
        self.assert_success(self.run_installer("uninstall", "project", "all"))
        self.assertEqual([path for path in self.project.rglob("*") if path.is_file()], [])

    def test_expanded_agents_preserve_existing_instructions_in_both_scopes(self):
        cases = (
            ("amp", ".config/amp/AGENTS.md", "AGENTS.md"),
            ("cline", ".agents/AGENTS.md", "AGENTS.md"),
            ("cursor", None, "AGENTS.md"),
            ("droid", ".factory/AGENTS.md", "AGENTS.md"),
            ("gemini-cli", ".gemini/GEMINI.md", "GEMINI.md"),
            ("github-copilot", ".copilot/copilot-instructions.md", ".github/copilot-instructions.md"),
            ("goose", ".config/goose/.goosehints", ".goosehints"),
            ("junie", None, ".junie/guidelines.md"),
            ("kimi-code-cli", None, "AGENTS.md"),
            ("kiro-cli", ".kiro/steering/AGENTS.md", "AGENTS.md"),
            ("mistral-vibe", ".vibe/AGENTS.md", "AGENTS.md"),
            ("qwen-code", ".qwen/QWEN.md", "QWEN.md"),
            ("roo", ".roo/rules/coding-principles.md", ".roo/rules/coding-principles.md"),
            ("warp", None, "AGENTS.md"),
            ("windsurf", ".codeium/windsurf/memories/global_rules.md", "AGENTS.md"),
            ("zed", ".config/zed/AGENTS.md", "AGENTS.md"),
        )
        for agent, global_path, project_path in cases:
            for scope, root, relative in (("global", self.home, global_path), ("project", self.project, project_path)):
                if relative is None:
                    continue
                with self.subTest(agent=agent, scope=scope):
                    path = root / relative
                    path.parent.mkdir(parents=True, exist_ok=True)
                    original = b"Existing instructions\r\n"
                    path.write_bytes(original)
                    path.chmod(0o640)
                    for action in ("install", "install"):
                        self.assert_success(self.run_installer(action, scope, agent))
                        self.assertEqual(path.read_bytes().count(START), 1)
                    self.assert_success(self.run_installer("uninstall", scope, agent))
                    self.assertEqual(path.read_bytes(), original)
                    self.assertEqual(path.stat().st_mode & 0o777, 0o640)
                    path.unlink()

    def test_project_only_agents_fail_globally_before_any_files_change(self):
        for agent in ("cursor", "junie", "kimi-code-cli", "warp"):
            result = self.run_installer("install", "global", "codex," + agent)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("--scope project", result.stderr)
            self.assertFalse(self.codex.exists())
        self.assert_success(self.run_installer("install", "project", "claude-code"))
        self.assertIn(START, (self.project / "CLAUDE.md").read_bytes())

    def test_zed_updates_active_legacy_file_and_ignores_rule_directories_on_removal(self):
        rules = self.project / ".rules"
        rules.write_bytes(b"Active Zed rules\n")
        (self.project / ".clinerules").mkdir()
        self.assert_success(self.run_installer("install", "project", "zed"))
        self.assertIn(START, rules.read_bytes())
        self.assertFalse((self.project / "AGENTS.md").exists())
        self.assert_success(self.run_installer("uninstall", "project", "zed"))
        self.assertEqual(rules.read_bytes(), b"Active Zed rules\n")
        self.assertTrue((self.project / ".clinerules").is_dir())

    def test_junie_updates_ide_guidelines_and_active_cli_context(self):
        cli = self.project / ".junie/AGENTS.md"
        cli.parent.mkdir()
        cli.write_bytes(b"Existing CLI guidance\n")
        self.assert_success(self.run_installer("install", "project", "junie"))
        guidelines = self.project / ".junie/guidelines.md"
        self.assertIn(START, cli.read_bytes())
        self.assertIn(START, guidelines.read_bytes())
        self.assert_success(self.run_installer("uninstall", "project", "junie"))
        self.assertEqual(cli.read_bytes(), b"Existing CLI guidance\n")
        self.assertFalse(guidelines.exists())

    def test_roo_retains_legacy_workspace_guidance(self):
        legacy = self.project / ".roorules"
        original = b"Legacy workspace instructions\n"
        legacy.write_bytes(original)
        target = self.project / ".roo/rules/coding-principles.md"
        for _ in range(2):
            self.assert_success(self.run_installer("install", "project", "roo"))
            self.assertIn(b"Read and follow the existing Roo rules", target.read_bytes())
            self.assertEqual(legacy.read_bytes(), original)
        self.assert_success(self.run_installer("uninstall", "project", "roo"))
        self.assertFalse(target.exists())
        self.assertEqual(legacy.read_bytes(), original)

    def test_windsurf_size_limit_stops_before_other_agents_change(self):
        rules = self.home / ".codeium/windsurf/memories/global_rules.md"
        rules.parent.mkdir(parents=True)
        original = b"x" * 5900
        rules.write_bytes(original)
        result = self.run_installer("install", "global", "codex,windsurf")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("6000", result.stderr)
        self.assertEqual(rules.read_bytes(), original)
        self.assertFalse(self.codex.exists())

    def test_windsurf_limit_applies_to_shared_symlink_target(self):
        rules = self.home / ".codeium/windsurf/memories/global_rules.md"
        rules.parent.mkdir(parents=True)
        self.codex.mkdir()
        shared = self.codex / "AGENTS.md"
        original = b"x" * 5900
        shared.write_bytes(original)
        rules.symlink_to(shared)
        result = self.run_installer("install", "global", "codex,windsurf")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("6000", result.stderr)
        self.assertEqual(shared.read_bytes(), original)
        self.assertTrue(rules.is_symlink())

    def test_pi_honors_existing_context_filename_and_empty_override(self):
        self.pi.mkdir()
        claude = self.pi / "CLAUDE.md"
        claude.write_bytes(b"Existing Pi rules\n")
        self.assert_success(self.run_installer("install", "global", "pi"))
        self.assertIn(START, claude.read_bytes())
        self.assertFalse((self.pi / "AGENTS.md").exists())
        override = self.pi / "AGENTS.override.md"
        override.write_bytes(b"")
        self.assert_success(self.run_installer("install", "global", "pi"))
        self.assertIn(START, override.read_bytes())
        self.assert_success(self.run_installer("uninstall", "global", "pi"))
        self.assertEqual(override.read_bytes(), b"")
        self.assertEqual(claude.read_bytes(), b"Existing Pi rules\n")

    def test_opencode_config_override_and_project_claude_fallback(self):
        config = self.directory / "custom OpenCode config"
        self.env["OPENCODE_CONFIG_DIR"] = str(config)
        self.assert_success(self.run_installer("install", "global", "opencode"))
        self.assertIn(START, (config / "AGENTS.md").read_bytes())
        self.assertFalse(self.xdg.exists())
        self.assert_success(self.run_installer("uninstall", "global", "opencode"))
        claude = self.project / "CLAUDE.md"
        claude.write_bytes(b"Existing rules\n")
        self.assert_success(self.run_installer("install", "project", "opencode"))
        self.assertIn(START, claude.read_bytes())
        self.assertFalse((self.project / "AGENTS.md").exists())
        (self.project / "AGENTS.md").write_bytes(b"Later AGENTS rules\n")
        self.assert_success(self.run_installer("uninstall", "project", "opencode"))
        self.assertEqual(claude.read_bytes(), b"Existing rules\n")
        self.assertEqual((self.project / "AGENTS.md").read_bytes(), b"Later AGENTS rules\n")

    def test_opencode_retains_existing_global_fallback_guidance(self):
        fallback = self.home / ".claude/CLAUDE.md"
        fallback.parent.mkdir()
        fallback.write_bytes(b"Existing shared global instructions\n")
        agents = self.xdg / "opencode/AGENTS.md"
        for _ in range(2):
            self.assert_success(self.run_installer("install", "global", "opencode"))
            self.assertIn(str(fallback).encode(), agents.read_bytes())
        self.assert_success(self.run_installer("uninstall", "global", "opencode"))
        self.assertFalse(agents.exists())
        self.assertEqual(fallback.read_bytes(), b"Existing shared global instructions\n")
        self.env["OPENCODE_DISABLE_CLAUDE_CODE_PROMPT"] = "1"
        self.assert_success(self.run_installer("install", "global", "opencode"))
        self.assertNotIn(str(fallback).encode(), agents.read_bytes())

    def test_new_shared_agents_file_points_to_existing_project_guidance(self):
        claude = self.project / "CLAUDE.md"
        original = b"Existing project instructions\n"
        claude.write_bytes(original)
        for _ in range(2):
            self.assert_success(self.run_installer("install", "project", "all"))
            self.assertIn(b"Read and follow the project instructions in [CLAUDE.md](CLAUDE.md).", (self.project / "AGENTS.md").read_bytes())
        self.assert_success(self.run_installer("uninstall", "project", "all"))
        self.assertEqual(claude.read_bytes(), original)
        self.assertFalse((self.project / "AGENTS.md").exists())

    def run_ui(self, steps, args=(), env=None, piped=False):
        env = dict(env or self.env, TERM="xterm", UI_SCRIPT=str(SCRIPT))
        pid, terminal = pty.fork()
        if pid == 0:
            fcntl.ioctl(1, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
            signal.signal(signal.SIGINT, signal.SIG_DFL)
            signal.signal(signal.SIGTERM, signal.SIG_DFL)
            os.chdir(self.project)
            if piped:
                command = 'printf "%s\\n" "$(<"$UI_SCRIPT")" | /bin/bash -s -- "$@"'
                os.execve("/bin/bash", ["/bin/bash", "-c", command, "test-pipe", *args], env)
            os.execve(str(SCRIPT), [str(SCRIPT), *args], env)
        output = bytearray()
        pending = bytearray()
        status = None
        deadline = time.monotonic() + 12

        def receive():
            if time.monotonic() >= deadline:
                self.fail("Terminal UI timed out: " + output.decode(errors="replace"))
            if select.select([terminal], [], [], 0.1)[0]:
                try:
                    data = os.read(terminal, 65536)
                except OSError:
                    data = b""
                output.extend(data)
                pending.extend(data)

        try:
            for expected, keys in steps:
                while expected not in pending:
                    receive()
                del pending[:pending.index(expected) + len(expected)]
                os.write(terminal, keys.replace(b"\n", b"\r"))
            while status is None:
                receive()
                finished, wait_status = os.waitpid(pid, os.WNOHANG)
                if finished:
                    status = wait_status
            self.assertEqual(termios.tcgetattr(terminal)[3] & (termios.ECHO | termios.ICANON), termios.ECHO | termios.ICANON, "Terminal echo/canonical mode was not restored")
            return os.waitstatus_to_exitcode(status), output.decode(errors="replace")
        finally:
            if status is None:
                os.killpg(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            os.close(terminal)

    def test_ui_selects_only_grok_globally(self):
        grok = self.home / ".grok/AGENTS.md"
        for args in ((), ("uninstall",)):
            code, output = self.run_ui([(b"Installation scope", b"\n"), (b"Choose agents", b" \x1b[B \x1b[B \n"), (b"Proceed with", b"\n")], args=args)
            self.assertEqual(code, 0, output)
            self.assertIn(str(grok), output)
            if not args:
                self.assertIn(START, grok.read_bytes())
            else:
                self.assertFalse(grok.exists())
            self.assertFalse(self.codex.exists())
            self.assertFalse(self.claude.exists())

    def test_piped_ui_selects_all_agents_in_current_project(self):
        env, temporary = self.remote_environment()
        code, output = self.run_ui([(b"Installation scope", b"\x1b[A\n"), (b"Choose agents", b"\n"), (b"Project folder", b"\n"), (b"Proceed with", b"\n")], args=("--interactive", "--agent", "all"), env=env, piped=True)
        self.assertEqual(code, 0, output)
        self.assertEqual((self.project / "AGENTS.md").read_bytes().count(START), 1)
        self.assertEqual((self.project / "CLAUDE.md").read_bytes().count(START), 1)
        self.assertEqual((self.project / ".junie/guidelines.md").read_bytes().count(START), 1)
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.claude.exists())
        self.assertFalse(self.pi.exists())
        self.assertEqual(list(temporary.iterdir()), [])
        self.assertEqual(len(Path(env["DOWNLOAD_LOG"]).read_text().splitlines()), 1)

    def test_ui_cancel_and_interrupt_leave_files_unchanged(self):
        self.codex.mkdir()
        agents = self.codex / "AGENTS.md"
        agents.write_bytes(b"Existing instructions\n")
        for steps, expected_code in (([(b"Installation scope", b"q")], 0), ([(b"Installation scope", b"\x1b")], 0), ([(b"Installation scope", b"\x03")], 130), ([(b"Installation scope", b"\n"), (b"Choose agents", b"q")], 0), ([(b"Installation scope", b"\n"), (b"Choose agents", b"\n"), (b"Proceed with", b"\x1b[B\n")], 0)):
            with self.subTest(steps=steps):
                code, output = self.run_ui(steps)
                self.assertEqual(code, expected_code, output)
                self.assertIn("Cancelled", output)
                self.assertEqual(agents.read_bytes(), b"Existing instructions\n")
                self.assertFalse(self.claude.exists())
                self.assertEqual(list(self.project.iterdir()), [])
        env, temporary = self.remote_environment()
        code, output = self.run_ui([(b"Installation scope", b"\n"), (b"Choose agents", b"\n"), (b"Proceed with", b"q")], env=env, piped=True)
        self.assertEqual(code, 0, output)
        self.assertFalse(Path(env["DOWNLOAD_LOG"]).exists())
        self.assertEqual(list(temporary.iterdir()), [])

    def test_ui_requires_one_agent_and_yes_skips_the_ui(self):
        code, output = self.run_ui([(b"Installation scope", b"\n"), (b"Choose agents", b" \x1b[B \n"), (b"at least one", b" \n"), (b"Proceed with", b"\n")])
        self.assertEqual(code, 0, output)
        self.assertFalse(self.codex.exists())
        self.assertIn(START, (self.claude / "CLAUDE.md").read_bytes())
        code, output = self.run_ui([], args=("uninstall", "--yes"))
        self.assertEqual(code, 0, output)
        self.assertNotIn("Installation scope", output)
        self.assertFalse((self.claude / "CLAUDE.md").exists())

    def test_explicit_ui_without_a_terminal_fails_without_writing(self):
        result = subprocess.run([str(SCRIPT), "--interactive"], env=self.env, start_new_session=True, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires a controlling terminal", result.stderr)
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.claude.exists())

    def enable_node(self):
        node = shutil.which("node")
        if not node or subprocess.run([node, str(ROOT / "scripts/coding-principles-ui.cjs"), "--check"], capture_output=True).returncode:
            self.skipTest("Node.js 22.20+ is required for Clack UI coverage")
        self.binaries.joinpath("node").symlink_to(node)
        return node

    def test_node_ui_selects_and_removes_only_grok(self):
        self.enable_node()
        self.test_ui_selects_only_grok_globally()

    def test_node_ui_uses_skills_search_selection_and_summary(self):
        self.enable_node()
        env = dict(self.env, FORCE_COLOR="1")
        env.pop("NO_COLOR", None)
        code, output = self.run_ui([(b"Installation scope", b"\r"), (b"Choose agents", b" \x1b[B pi"), (b"pi", b" \r"), (b"Proceed with", b"\r")], env=env)
        self.assertEqual(code, 0, output)
        plain = re.sub(r"\x1b\[[0-9;]*m", "", output)
        self.assertIn("Search: pi", plain)
        self.assertIn("Selected: Pi", plain)
        self.assertIn("Instruction Summary", plain)
        self.assertIn("Yes", plain)
        self.assertIn("\x1b[32m", output)
        self.assertIn(START, (self.pi / "AGENTS.md").read_bytes())
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.claude.exists())

    def test_search_q_is_input_and_escape_cancels(self):
        self.enable_node()
        code, output = self.run_ui([(b"Installation scope", b"\r"), (b"Choose agents", b"q"), (b"Search: q", b"\x1b")])
        self.assertEqual(code, 0, output)
        self.assertIn("Cancelled", output)
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.claude.exists())

    def test_node_ui_requires_one_agent_and_yes_bypasses_it(self):
        self.enable_node()
        code, output = self.run_ui([(b"Installation scope", b"\r"), (b"Choose agents", b" \x1b[B \r"), (b"Selected: (none)", b" \r"), (b"Proceed with", b"\r")])
        self.assertEqual(code, 0, output)
        self.assertFalse(self.codex.exists())
        self.assertIn(START, (self.claude / "CLAUDE.md").read_bytes())
        code, output = self.run_ui([], args=("uninstall", "--yes"))
        self.assertEqual(code, 0, output)
        self.assertNotIn("Search:", output)
        self.assertFalse((self.claude / "CLAUDE.md").exists())

    def test_node_agent_paths_and_project_only_scope(self):
        self.enable_node()
        code, output = self.run_ui([(b"Installation scope", b"\r"), (b"Choose agents", b"cursor\r"), (b"Project folder", b"\r"), (b"Proceed with", b"\r")], args=("--interactive", "--agent", "cursor"))
        self.assertEqual(code, 0, output)
        self.assertIn("Cursor", output)
        self.assertIn("Shared instructions (AGENTS.md)", output)
        self.assertNotIn("AGENTS.md / project only", output)
        self.assertNotIn("AstrBot", output)
        self.assertIn(START, (self.project / "AGENTS.md").read_bytes())
        self.assertFalse(self.codex.exists())

    def test_bash_agent_menu_scrolls_to_new_agents(self):
        code, output = self.run_ui([(b"Installation scope", b"\n"), (b"Choose agents", b"\x1b[B" * 17), (b"Zed", b"q")])
        self.assertEqual(code, 0, output)
        self.assertIn("Zed", output)
        self.assertIn("Cancelled", output)
        self.assertEqual(list(self.project.iterdir()), [])

    def test_node_ui_honors_project_and_agent_preselection(self):
        self.enable_node()
        code, output = self.run_ui([(b"Installation scope", b"\n"), (b"Choose agents", b"\n"), (b"Project folder", b"\n"), (b"Proceed with", b"\n")], args=("--interactive", "--scope", "project", "--project-dir", str(self.project), "--agent", "grok"))
        self.assertEqual(code, 0, output)
        self.assertIn("coding principles", output)
        self.assertEqual((self.project / "AGENTS.md").read_bytes().count(START), 1)
        self.assertFalse((self.project / "CLAUDE.md").exists())
        self.assertFalse(self.codex.exists())
        self.assertFalse(self.home.joinpath(".grok").exists())

    def test_node_project_group_selects_shared_targets_once_and_can_remove_them(self):
        self.enable_node()
        for action in ("install", "uninstall"):
            with self.subTest(action=action):
                code, output = self.run_ui([
                    (b"Installation scope", b"\r"),
                    (b"Choose agents", b" \r"),
                    (b"Project folder", b"\r"),
                    (b"Proceed with", b"\r"),
                ], args=(action, "--interactive", "--scope", "project", "--agent", "grok"))
                self.assertEqual(code, 0, output)
                self.assertIn("22 agents", output)
                self.assertIn("Shared instructions (AGENTS.md)", output)
                self.assertNotIn("always included", output)
                if action == "install":
                    self.assertEqual((self.project / "AGENTS.md").read_bytes().count(START), 1)
                else:
                    self.assertFalse((self.project / "AGENTS.md").exists())
                self.assertEqual(sorted(path.name for path in self.home.iterdir()), [])
                self.assertFalse((self.project / "CLAUDE.md").exists())
                self.assertFalse(self.codex.exists())
                self.assertFalse(self.pi.exists())

    def test_project_separate_file_selection_does_not_force_shared_install(self):
        for node in (False, True):
            with self.subTest(node=node):
                if node:
                    self.enable_node()
                code, output = self.run_ui([
                    (b"Installation scope", b"\r"),
                    (b"Choose agents", b"\r"),
                    (b"Project folder", b"\r"),
                    (b"Proceed with", b"\r"),
                ], args=("--interactive", "--scope", "project", "--agent", "claude"))
                self.assertEqual(code, 0, output)
                self.assertIn("Shared instructions (AGENTS.md)", output)
                self.assertIn(START, (self.project / "CLAUDE.md").read_bytes())
                self.assertFalse((self.project / "AGENTS.md").exists())
                self.assert_success(self.run_installer("uninstall", "project", "claude"))

    def test_node_groups_collapse_and_global_selection_omits_project_only_tools(self):
        self.enable_node()
        code, output = self.run_ui([
            (b"Installation scope", b"\r"),
            (b"Choose agents", b"\x1b[D"),
            (b"Separate instruction files", b"\x1b"),
        ], args=("--interactive", "--scope", "project"))
        self.assertEqual(code, 0, output)
        self.assertEqual(list(self.project.iterdir()), [])
        self.assertNotIn("always included", output)
        code, output = self.run_ui([
            (b"Installation scope", b"\r"),
            (b"Choose agents", b"cursor"),
            (b"No matches found", b"\x1b"),
        ])
        self.assertEqual(code, 0, output)
        self.assertIn("18 agents", output)
        self.assertIn("~/.codex/AGENTS.md", output)
        self.assertNotIn("Shared instructions", output)
        self.assertNotIn("(AGENTS.md /", output)
        self.assertFalse(self.codex.exists())

    def test_node_piped_ui_and_failed_download_fallback(self):
        self.enable_node()
        env, temporary = self.remote_environment()
        for fail in (False, True):
            with self.subTest(fail_ui_download=fail):
                run_env = dict(env, FAIL_UI="1" if fail else "")
                code, output = self.run_ui([(b"Installation scope", b"\x1b[A\n"), (b"Choose agents", b"\n"), (b"Project folder", b"\n"), (b"Proceed with", b"\n")], env=run_env, piped=True)
                self.assertEqual(code, 0, output)
                self.assertIn("Bash UI" if fail else "coding principles", output)
                for name in ("AGENTS.md", "CLAUDE.md"):
                    self.assertEqual((self.project / name).read_bytes().count(START), 1)
                self.assertEqual(list(temporary.iterdir()), [])
                self.assert_success(self.run_installer("uninstall", "project"))
        self.assertEqual(len(Path(env["DOWNLOAD_LOG"]).read_text().splitlines()), 4)

    def test_node_ui_cancel_restores_terminal_without_changing_files(self):
        self.enable_node()
        self.codex.mkdir()
        agents = self.codex / "AGENTS.md"
        agents.write_bytes(b"Existing instructions\n")
        for steps, expected in (([(b"Installation scope", b"\x1b")], 0), ([(b"Installation scope", b"\x03")], 130), ([(b"Installation scope", b"q")], 0), ([(b"Installation scope", b"\r"), (b"Choose agents", b"\x1b")], 0), ([(b"Installation scope", b"\r"), (b"Choose agents", b"\x03")], 130), ([(b"Installation scope", b"\r"), (b"Choose agents", b"\r"), (b"Proceed with", b"\x1b[B\r")], 0)):
            with self.subTest(steps=steps):
                code, output = self.run_ui(steps)
                self.assertEqual(code, expected, output)
                self.assertIn("Cancelled", output)
                self.assertEqual(agents.read_bytes(), b"Existing instructions\n")
                self.assertFalse(self.claude.exists())
        env, temporary = self.remote_environment()
        code, output = self.run_ui([(b"Installation scope", b"\x1b")], env=env, piped=True)
        self.assertEqual(code, 0, output)
        self.assertEqual(list(temporary.iterdir()), [])
        self.assertEqual(Path(env["DOWNLOAD_LOG"]).read_text().splitlines(), ["https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/coding-principles-ui.cjs"])

    def test_unsupported_or_unloadable_node_uses_bash_ui(self):
        node = self.enable_node()
        self.binaries.joinpath("node").unlink()
        shim = self.binaries / "node"
        for body in ("exit 1", '[[ "$1" == -e ]] || exit 1\nexec "$REAL_NODE" "$@"'):
            with self.subTest(shim=body):
                shim.write_text("#!/bin/bash\n" + body + "\n")
                shim.chmod(0o755)
                code, output = self.run_ui([(b"Installation scope", b"q")], env=dict(self.env, REAL_NODE=node))
                self.assertEqual(code, 0, output)
                self.assertIn("Bash UI", output)
                self.assertFalse(self.codex.exists())
                self.assertFalse(self.claude.exists())

    def test_explicit_options_and_help_never_invoke_node(self):
        shim = self.binaries / "node"
        shim.write_text('#!/bin/bash\nprintf "invoked\\n" >> "$NODE_CALL_LOG"\nexit 1\n')
        shim.chmod(0o755)
        log = self.directory / "node.log"
        env = dict(self.env, NODE_CALL_LOG=str(log))
        for args in (("--help",), ("--yes",), ("--scope", "global", "--agent", "codex")):
            code, output = self.run_ui([], args=args, env=env)
            self.assertEqual(code, 0, output)
            self.assertNotIn("UI:", output)
            self.assertFalse(log.exists())

    def test_node_ui_failure_or_invalid_result_stops_before_writing(self):
        node = self.enable_node()
        self.binaries.joinpath("node").unlink()
        shim = self.binaries / "node"
        for body in ("exit 7", 'printf "99\\n"', 'printf "0 1\\n"', 'printf "unexpected text\\n"'):
            with self.subTest(result=body):
                shim.write_text('#!/bin/bash\nif [[ "$1" == -e || "$2" == --check ]]; then exec "$REAL_NODE" "$@"; fi\n' + body + "\n")
                shim.chmod(0o755)
                code, output = self.run_ui([], env=dict(self.env, REAL_NODE=node))
                self.assertNotEqual(code, 0, output)
                self.assertIn("Error:", output)
                self.assertFalse(self.codex.exists())
                self.assertFalse(self.claude.exists())


if __name__ == "__main__":
    unittest.main()
