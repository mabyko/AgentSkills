import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PluginBundleTests(unittest.TestCase):
    def test_marketplaces_select_expected_skills_and_hooks(self):
        expected = {
            "git-hooks": (set(), {"PreToolUse"}),
            "github-hooks": (set(), {"PreToolUse"}),
            "apple-dev-hooks": (set(), {"PreToolUse"}),
        }
        for catalog_path, host in ((".claude-plugin/marketplace.json", "claude"), (".agents/plugins/marketplace.json", "codex")):
            catalog = json.loads((ROOT / catalog_path).read_text())
            self.assertEqual({entry["name"] for entry in catalog["plugins"]}, set(expected))
            for entry in catalog["plugins"]:
                name = entry["name"]
                with self.subTest(host=host, plugin=name):
                    source = entry["source"]
                    selected = (ROOT / (source if isinstance(source, str) else source["path"])).resolve()
                    self.assertEqual(selected, ROOT / "plugins" / name)
                    manifest = json.loads((selected / f".{host}-plugin/plugin.json").read_text())
                    self.assertEqual(manifest["name"], name)
                    counterpart = "codex" if host == "claude" else "claude"
                    other = json.loads((selected / f".{counterpart}-plugin/plugin.json").read_text())
                    self.assertEqual(manifest["version"], other["version"])
                    skills = selected / manifest.get("skills", "skills")
                    actual_skills = {path.name for path in skills.iterdir() if path.is_dir()} if skills.is_dir() else set()
                    self.assertEqual(actual_skills, expected[name][0])
                    hooks_path = selected / manifest.get("hooks", "hooks/hooks.json")
                    hooks = json.loads(hooks_path.read_text())["hooks"] if hooks_path.is_file() else {}
                    self.assertEqual(set(hooks), expected[name][1])
        for relative in (".claude-plugin/plugin.json", ".codex-plugin/plugin.json", "hooks/hooks.json", "codex-hooks/hooks.json"):
            self.assertFalse((ROOT / relative).exists(), relative)

    def copy_checkout(self, temporary):
        checkout = Path(temporary) / "checkout"
        shutil.copytree(ROOT, checkout, ignore=shutil.ignore_patterns(".git", ".serena", "__pycache__"))
        return checkout

    def build(self, checkout, *args):
        return subprocess.run(["python3", str(checkout / "scripts/build-plugin-bundles.py"), *args], capture_output=True, text=True)

    def test_bundler_refreshes_changes_and_removes_stale_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            checkout = self.copy_checkout(temporary)
            for name, script in (("git-hooks", "git-workflow-trigger.sh"), ("github-hooks", "github-workflow-trigger.sh"), ("apple-dev-hooks", "apple-dev-trigger.sh")):
                with self.subTest(plugin=name):
                    source = checkout / "scripts/hooks" / script
                    source.write_text(source.read_text() + "\n# Updated canonical hook\n")
                    plugin = checkout / "plugins" / name
                    obsolete = plugin / "scripts/hooks/deleted-hook.sh"
                    obsolete.write_text("Removed upstream\n")
                    unwanted_skill = plugin / "skills/git-workflow/SKILL.md"
                    unwanted_skill.parent.mkdir(parents=True)
                    unwanted_skill.write_text("Skills belong in the canonical directory\n")
                    changed = plugin / "hooks/hooks.json"
                    changed.write_text("Outdated hook configuration\n")
                    self.assertNotEqual(self.build(checkout, "--check").returncode, 0)
                    result = self.build(checkout)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    bundled = plugin / "scripts/hooks" / script
                    self.assertEqual(bundled.read_bytes(), source.read_bytes())
                    self.assertFalse(obsolete.exists())
                    self.assertFalse(unwanted_skill.exists())
                    self.assertTrue(bundled.stat().st_mode & 0o111)
                    self.assertEqual(self.build(checkout, "--check").returncode, 0)

    def test_missing_canonical_resource_does_not_replace_bundle(self):
        with tempfile.TemporaryDirectory() as temporary:
            checkout = self.copy_checkout(temporary)
            bundled = checkout / "plugins/git-hooks/scripts/hooks/git-workflow-trigger.sh"
            original = bundled.read_bytes()
            (checkout / "scripts/hooks/git-workflow-trigger.sh").unlink()
            result = self.build(checkout)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Missing canonical resource", result.stderr)
            self.assertEqual(bundled.read_bytes(), original)


    def test_validator_checks_nested_plugin_invariants(self):
        with tempfile.TemporaryDirectory() as temporary:
            checkout = Path(temporary) / "checkout"
            shutil.copytree(ROOT, checkout, ignore=shutil.ignore_patterns(".git", ".serena", "__pycache__"))
            plugin = checkout / "plugins/git-hooks"
            mutations = {
                ".codex-plugin/plugin.json": lambda value: value.replace('"version": "0.1.0"', '"version": "0.2.0"'),
                "hooks/hooks.json": lambda value: value.replace('${CLAUDE_PLUGIN_ROOT}/', './'),
            }
            for relative, mutate in mutations.items():
                with self.subTest(file=relative):
                    path = plugin / relative
                    original = path.read_text()
                    path.write_text(mutate(original))
                    result = subprocess.run([str(checkout / "scripts/validate-skills.sh")], capture_output=True, text=True)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(str(plugin), result.stderr)
                    path.write_text(original)
            script = plugin / "scripts/hooks/git-workflow-trigger.sh"
            script.chmod(script.stat().st_mode & ~0o111)
            result = subprocess.run([str(checkout / "scripts/validate-skills.sh")], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Hook script is not executable", result.stderr)

if __name__ == "__main__":
    unittest.main()
