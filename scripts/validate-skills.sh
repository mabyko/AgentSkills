#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
failed=0
count=0

if [ ! -d "$skills_dir" ]; then
  echo "Missing skills directory: $skills_dir" >&2
  exit 1
fi

while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "$skill_dir")"
  count=$((count + 1))

  if ! printf '%s' "$skill_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo "Invalid skill folder name: $skill_name" >&2
    failed=1
  fi

  skill_md="$skill_dir/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    echo "Missing SKILL.md: $skill_dir" >&2
    failed=1
    continue
  fi

  if ! sed -n '1p' "$skill_md" | grep -qx -- '---'; then
    echo "Missing opening YAML frontmatter marker: $skill_md" >&2
    failed=1
  fi

  if ! grep -Eq '^name: [a-z0-9]+(-[a-z0-9]+)*$' "$skill_md"; then
    echo "Missing or invalid name field: $skill_md" >&2
    failed=1
  fi

  if ! grep -Eq '^description: .{20,}$' "$skill_md"; then
    echo "Missing or too-short description field: $skill_md" >&2
    failed=1
  fi

  if [ -f "$skill_dir/agents/openai.yaml" ]; then
    if ! grep -Eq '^interface:$' "$skill_dir/agents/openai.yaml"; then
      echo "Missing interface block: $skill_dir/agents/openai.yaml" >&2
      failed=1
    fi
    if ! grep -Eq '^[[:space:]]+default_prompt: ".*\$'"$skill_name"'.*"$' "$skill_dir/agents/openai.yaml"; then
      echo "default_prompt should mention \$$skill_name: $skill_dir/agents/openai.yaml" >&2
      failed=1
    fi
  fi
done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -print0)

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Validated $count skill(s)."
