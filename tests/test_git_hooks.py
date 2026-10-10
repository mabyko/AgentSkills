import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GitHooksTests(unittest.TestCase):
    def test_cached_hook_runs_without_skills_and_reminds_each_class_once(self):
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            plugin = workspace / "plugin cache with spaces"
            shutil.copytree(ROOT / "plugins/git-hooks", plugin)
            self.assertFalse((plugin / "skills").exists())
            for host, relative in (("claude", "hooks/hooks.json"), ("codex", "codex-hooks/hooks.json")):
                handler = json.loads((plugin / relative).read_text())["hooks"]["PreToolUse"][0]["hooks"][0]
                env = dict(os.environ, CLAUDE_PLUGIN_ROOT=str(plugin), CODEX_PLUGIN_ROOT=str(plugin), TMPDIR=str(workspace))

                def run(command):
                    return subprocess.run(["bash", "-c", handler["command"]], cwd=workspace, env=env, input=json.dumps({"session_id": host, "tool_input": {"command": command}}), capture_output=True, text=True)

                benign = run("git status --short")
                self.assertEqual(benign.returncode, 0, benign.stderr)
                self.assertEqual(benign.stdout, "")
                for command, rule in (("git checkout feature", "git status --short"), ("git commit", "git commit -S --signoff")):
                    with self.subTest(host=host, command=command):
                        first = run(command)
                        self.assertEqual(first.returncode, 0, first.stderr)
                        output = json.loads(first.stdout)["hookSpecificOutput"]
                        context = output["additionalContext" if host == "claude" else "permissionDecisionReason"]
                        self.assertIn(rule, context)
                        self.assertIn("If the git-workflow skill is available", context)
                        self.assertNotIn("references/commits.md", context)
                        if host == "codex":
                            self.assertEqual(output["permissionDecision"], "deny")
                        retry = run(command)
                        self.assertEqual(retry.returncode, 0, retry.stderr)
                        self.assertEqual(retry.stdout, "")


if __name__ == "__main__":
    unittest.main()
