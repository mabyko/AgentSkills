import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GitHubHooksTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.workspace = Path(self.temporary.name)
        self.plugin = self.workspace / "plugin cache with spaces"
        shutil.copytree(ROOT / "plugins/github-hooks", self.plugin)
        self.assertFalse((self.plugin / "skills").exists())
        self.env = dict(os.environ, CLAUDE_PLUGIN_ROOT=str(self.plugin), TMPDIR=str(self.workspace))
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

    def test_mutation_reminders_work_without_skills_or_github_access(self):
        commands = {
            "gh pr create --title Test": "PR template",
            "gh pr edit 8 --base main": "stack parent",
            "gh pr ready 8": "draft state",
            "gh pr reopen 8": "exact repository",
            "gh pr review 8 --approve": "only when requested",
            "gh pr comment 8 --body Test": "only when requested",
            "gh pr merge 8 --auto --squash": "current head SHA",
            "gh pr close 8": "explicit authorization",
            "gh stack init --base main feature/one": "clean and idle",
            "gh stack add feature/two --message Test": "implicit commits",
            "gh stack rebase --upstack": "repository signing/DCO",
            "gh stack submit --auto": "force-push with leases",
            "gh stack push": "force-push with leases",
            "gh stack sync --prune": "Sync aborted",
            "gh stack merge 8 --yes --squash": "every unmerged layer below",
            "gh release create v1.0.0 --draft": "candidate SHA",
            "gh release edit v1.0.0 --draft=false": "Preparation does not authorize",
            "gh release upload v1.0.0 app.zip": "assets",
            "gh release delete v1.0.0 --yes": "recovery process",
            "gh release delete-asset v1.0.0 app.zip": "explicit authorization",
            "/usr/local/bin/gh pr merge 8": "Stack membership",
            "GH_HOST=github.example gh stack sync": "remote state",
        }
        for host in ("claude", "codex"):
            for index, (command, expected) in enumerate(commands.items()):
                with self.subTest(host=host, command=command):
                    context = self.context(host, self.run_hook(host, command, str(index)))
                    self.assertIn("If the github-workflow skill is available", context)
                    self.assertIn(expected, context)

    def test_publication_does_not_consume_landing_or_release_reminders(self):
        for host in ("claude", "codex"):
            for command in (
                "gh pr create", "gh pr merge 8", "gh stack add feature/two",
                "gh stack submit", "gh stack merge 8", "gh release create v1.0.0",
            ):
                self.context(host, self.run_hook(host, command))
                retry = self.run_hook(host, command)
                self.assertEqual((retry.returncode, retry.stdout), (0, ""), retry.stderr)
            self.context(host, self.run_hook(host, "gh pr merge 8", "new_session"))

    def test_compound_command_reminds_each_category_without_executing_it(self):
        unwanted = self.workspace / "should not exist"
        command = f'gh stack sync && gh stack merge 8; gh release create v1.0.0; touch "{unwanted}"'
        for host in ("claude", "codex"):
            context = self.context(host, self.run_hook(host, command))
            self.assertIn("force-push with leases", context)
            self.assertIn("every unmerged layer below", context)
            self.assertIn("candidate SHA", context)
            self.assertFalse(unwanted.exists())
            self.assertEqual(self.run_hook(host, command).stdout, "")

    def test_read_only_unrelated_and_unsupported_operations_are_quiet(self):
        for host in ("claude", "codex"):
            for command in (
                "gh pr view 8", "gh pr checks 8", "gh pr list", "gh pr diff 8",
                "gh stack view --json", "gh stack status", "gh stack --help",
                "gh release view v1.0.0", "gh release list", "gh release download v1.0.0",
                "gh api repos/acme/repo/pulls", "gh --repo acme/repo pr merge 8",
                "gh pr merger", "gh release created", "echo github pr merge",
                "git commit -S --signoff", "flutter build macos", "",
            ):
                with self.subTest(host=host, command=command):
                    result = self.run_hook(host, command)
                    self.assertEqual((result.returncode, result.stdout), (0, ""), result.stderr)

    def test_underscore_sessions_are_isolated(self):
        for host in ("claude", "codex"):
            for session in ("thr_123", "thr_456"):
                self.context(host, self.run_hook(host, "gh pr merge 8", session))
                retry = self.run_hook(host, "gh pr merge 8", session)
                self.assertEqual((retry.returncode, retry.stdout), (0, ""), retry.stderr)

    def test_symlink_collision_preserves_target_and_allows_retry(self):
        target = self.workspace / "existing directory"
        target.mkdir()
        original = target / "keep.txt"
        original.write_text("Preserve this data")
        for host in ("claude", "codex"):
            marker = self.workspace / f"github-workflow-hook-pr-landing-{host}-test"
            marker.symlink_to(target, target_is_directory=True)
            self.context(host, self.run_hook(host, "gh pr merge 8"))
            self.assertEqual(self.run_hook(host, "gh pr merge 8").stdout, "")
            self.assertTrue(marker.is_symlink())
            self.assertEqual(list(target.iterdir()), [original])
            self.assertEqual(original.read_text(), "Preserve this data")

    def test_marker_failure_keeps_codex_command_available(self):
        marker = self.workspace / "github-workflow-hook-pr-landing-codex-test"
        marker.write_text("Existing file must remain untouched")
        for _ in range(2):
            result = self.run_hook("codex", "gh pr merge 8")
            self.assertEqual((result.returncode, result.stdout), (0, ""))
            self.assertIn("could not save session state", result.stderr)
        self.assertEqual(marker.read_text(), "Existing file must remain untouched")

    def test_runtime_needs_no_python_node_gh_or_installed_skills(self):
        tools = self.workspace / "bin"
        tools.mkdir()
        for command in ("bash", "cat", "grep", "head", "tr", "mkdir"):
            (tools / command).symlink_to(shutil.which(command))
        env = dict(self.env, PATH=str(tools), CODEX_PLUGIN_ROOT=str(self.plugin))
        self.context("codex", self.run_hook("codex", "gh stack sync", env=env))


if __name__ == "__main__":
    unittest.main()
