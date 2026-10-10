import os
import shutil
from pathlib import Path
import subprocess
import tempfile
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
        self.project = self.directory / "project with spaces"
        self.project.mkdir()
        self.binaries = self.directory / "bin"
        self.binaries.mkdir()
        # Every installer test runs without Python, Node, or other interpreters on PATH.
        for command in ("bash", "basename", "dirname", "readlink", "mktemp", "cp", "mkdir", "rm", "mv", "stat", "chmod"):
            self.binaries.joinpath(command).symlink_to("/bin/bash" if command == "bash" else shutil.which(command))
        self.env = dict(os.environ, PATH=str(self.binaries), CODEX_HOME=str(self.codex), CLAUDE_CONFIG_DIR=str(self.claude))

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
[[ "$2" == https://raw.githubusercontent.com/mabyko/AgentSkills/main/docs/coding-principles.md ]]
printf '%s\\n' "$2" >> "$DOWNLOAD_LOG"
if [[ -n "${FAIL_DOCUMENT:-}" ]]; then exit 22; fi
cp "$FIXTURE_ROOT/docs/coding-principles.md" "$4"
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


if __name__ == "__main__":
    unittest.main()
