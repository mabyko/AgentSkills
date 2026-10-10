import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class AppleDevHooksTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.workspace = Path(self.temporary.name)
        self.plugin = self.workspace / "plugin cache with spaces"
        shutil.copytree(ROOT / "plugins/apple-dev-hooks", self.plugin)
        self.assertFalse((self.plugin / "skills").exists())
        self.env = dict(os.environ, CLAUDE_PLUGIN_ROOT=str(self.plugin), TMPDIR=str(self.workspace))
        # Codex must work with its documented Claude-root fallback too.
        self.env.pop("CODEX_PLUGIN_ROOT", None)

    def run_hook(self, host, command, session="test", env=None):
        relative = "hooks/hooks.json" if host == "claude" else "codex-hooks/hooks.json"
        handler = json.loads((self.plugin / relative).read_text())["hooks"]["PreToolUse"][0]["hooks"][0]
        return subprocess.run(
            ["bash", "-c", handler["command"]], cwd=self.workspace, env=env or self.env,
            input=json.dumps({"session_id": f"{host}-{session}", "tool_input": {"command": command}}),
            capture_output=True, text=True,
        )

    def context(self, host, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        output = json.loads(result.stdout)["hookSpecificOutput"]
        self.assertEqual(output["hookEventName"], "PreToolUse")
        if host == "codex":
            self.assertEqual(output["permissionDecision"], "deny")
        return output["additionalContext" if host == "claude" else "permissionDecisionReason"]

    def test_cached_hooks_cover_apple_and_flutter_commands(self):
        commands = (
            "xcodebuild -scheme MyApp build",
            "xcodebuild -scheme MyApp archive",
            "flutter build ios --flavor personal",
            "flutter build ipa --flavor prod",
            "flutter build macos --flavor dev",
            "flutter run --flavor dev -d macos",
            "flutter run --device-id=macos --flavor dev",
            "codesign --force --sign 'Apple Development' '/tmp/My App.app'",
            "xcrun simctl install booted '/tmp/My App.app'",
            "xcrun devicectl device install app --device abc '/tmp/My App.app'",
        )
        for host in ("claude", "codex"):
            for index, command in enumerate(commands):
                with self.subTest(host=host, command=command):
                    context = self.context(host, self.run_hook(host, command, str(index)))
                    self.assertIn("If the apple-bundle-id-guardrails skill is available", context)
                    self.assertIn("signing team", context)
                    self.assertIn("selected flavor", context)
                    self.assertIn("preserve existing IDs", context)

    def test_cleanup_reminder_preserves_data_without_executing_commands(self):
        app = self.workspace / "My Dev.app"
        app.mkdir()
        commands = (
            f'rm -rf "{app}"',
            "rm -rf build/macos",
            "find /tmp -name '*.app' -delete",
            "find /tmp -name '*.app' -exec rm -rf {} +",
            f'/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "{app}"',
            "defaults delete com.acme.myapp.dev",
        )
        for host in ("claude", "codex"):
            for index, command in enumerate(commands):
                with self.subTest(host=host, command=command):
                    context = self.context(host, self.run_hook(host, command, str(index)))
                    self.assertIn("If the macos-dev-app-cleanup skill is available", context)
                    self.assertIn("Preserve Release apps", context)
                    self.assertIn("existing authorization", context)
                    self.assertTrue(app.is_dir())

    def test_categories_remind_once_independently_and_sessions_are_isolated(self):
        for host in ("claude", "codex"):
            self.context(host, self.run_hook(host, "flutter build macos"))
            quiet = self.run_hook(host, "xcodebuild build")
            self.assertEqual((quiet.returncode, quiet.stdout), (0, ""))
            self.context(host, self.run_hook(host, "rm -rf /tmp/MyApp.app"))
            retry = self.run_hook(host, "rm -rf /tmp/MyApp.app")
            self.assertEqual((retry.returncode, retry.stdout), (0, ""))
            self.context(host, self.run_hook(host, "flutter build macos", "new-session"))

    def test_compound_command_reminds_both_categories_then_allows_retry(self):
        for host in ("claude", "codex"):
            command = "flutter build macos && rm -rf /tmp/MyApp.app"
            context = self.context(host, self.run_hook(host, command))
            self.assertIn("macos-dev-app-cleanup", context)
            self.assertIn("apple-bundle-id-guardrails", context)
            self.assertEqual(self.run_hook(host, command).stdout, "")

    def test_unrelated_commands_and_read_only_cleanup_inventory_are_quiet(self):
        for host in ("claude", "codex"):
            for command in (
                "git status --short", "npm test", "flutter build apk", "flutter build appbundle",
                "flutter build web", "flutter build windows", "flutter build linux",
                "flutter run -d chrome", "find /Applications -name '*.app'",
                "codesign --verify --deep '/tmp/My App.app'", "xcrun simctl list", "",
            ):
                with self.subTest(host=host, command=command):
                    result = self.run_hook(host, command)
                    self.assertEqual((result.returncode, result.stdout), (0, ""), result.stderr)

    def test_marker_failure_keeps_codex_command_available(self):
        marker = self.workspace / "apple-dev-hook-identity-codex-test"
        marker.write_text("Existing file must remain untouched")
        for _ in range(2):
            result = self.run_hook("codex", "flutter build ios")
            self.assertEqual((result.returncode, result.stdout), (0, ""))
            self.assertIn("could not save session state", result.stderr)
        self.assertEqual(marker.read_text(), "Existing file must remain untouched")

    def test_runtime_needs_no_python_node_or_installed_skills(self):
        tools = self.workspace / "bin"
        tools.mkdir()
        for command in ("bash", "cat", "grep", "head", "tr", "mkdir"):
            (tools / command).symlink_to(shutil.which(command))
        env = dict(self.env, PATH=str(tools), CODEX_PLUGIN_ROOT=str(self.plugin))
        self.context("codex", self.run_hook("codex", "flutter build macos", env=env))


if __name__ == "__main__":
    unittest.main()
