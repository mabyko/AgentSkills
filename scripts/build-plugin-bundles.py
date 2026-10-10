#!/usr/bin/env python3
"""Refresh or check self-contained plugin bundles from canonical repository files."""

import argparse
import json
from pathlib import Path
import shutil
import sys


ROOT = Path(__file__).resolve().parents[1]
HOOKS = {
    "git-hooks": "git-workflow-trigger.sh",
    "apple-dev-hooks": "apple-dev-trigger.sh",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if bundled resources differ from their canonical sources.")
    args = parser.parse_args()
    # Validate sources before replacing any generated bundle.
    required = [ROOT / "scripts/hooks" / script for script in HOOKS.values()]
    for source in required:
        if not source.is_file():
            parser.error(f"Missing canonical resource: {source.relative_to(ROOT)}")
    stale = []
    for name, script in HOOKS.items():
        plugin = ROOT / "plugins" / name
        sources = {
            Path("scripts/hooks") / script: ROOT / "scripts/hooks" / script,
        }
        directories = ["skills", "scripts/hooks", "instructions", "hooks", "codex-hooks"]
        generated = {}
        for client, relative, command_root in (
            ("claude", "hooks/hooks.json", '"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/'),
            ("codex", "codex-hooks/hooks.json", '"${CODEX_PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT}"/scripts/hooks/'),
        ):
            command = command_root + script + ('"' if client == "claude" else '') + " --client=" + client
            hooks = {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": command}]}]}
            generated[Path(relative)] = (json.dumps({"hooks": hooks}, indent=2) + "\n").encode()
        expected = {path: (source.read_bytes(), source.stat().st_mode & 0o111) for path, source in sources.items()}
        expected.update({path: (data, 0) for path, data in generated.items()})
        for directory in directories:
            destination = plugin / directory
            if args.check:
                actual = {path.relative_to(plugin): (path.read_bytes(), path.stat().st_mode & 0o111) for path in destination.rglob("*") if path.is_file()}
                wanted = {path: data for path, data in expected.items() if path.is_relative_to(directory)}
                if actual != wanted:
                    stale.append(str(destination.relative_to(ROOT)))
            else:
                if destination.exists():
                    shutil.rmtree(destination)
                for relative, (data, _) in expected.items():
                    if relative.is_relative_to(directory):
                        target = plugin / relative
                        target.parent.mkdir(parents=True, exist_ok=True)
                        if relative in sources:
                            shutil.copy2(sources[relative], target)
                        else:
                            target.write_bytes(data)
    if stale:
        print("Stale plugin bundles; run python3 scripts/build-plugin-bundles.py:\n" + "\n".join(stale), file=sys.stderr)
        return 1
    print("Checked" if args.check else "Built", len(HOOKS), "hook plugin bundles.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
