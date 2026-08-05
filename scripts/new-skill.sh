#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: scripts/new-skill.sh <skill-name>" >&2
  exit 2
fi

skill_name="$1"

case "$skill_name" in
  *[!a-z0-9-]* | "" | -* | *- | *--*)
    echo "Skill name must be kebab-case: lowercase letters, numbers, and single hyphens." >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_root/skills/$skill_name"

if [ -e "$target" ]; then
  echo "Skill already exists: $target" >&2
  exit 1
fi

mkdir -p "$target"
cp -R "$repo_root/templates/skill/." "$target/"

display_name="$(printf '%s' "$skill_name" | awk -F- '{ for (i=1; i<=NF; i++) { $i=toupper(substr($i,1,1)) substr($i,2) } print }' OFS=' ')"

for seeded_file in "$target/SKILL.md" "$target/agents/openai.yaml"; do
  tmp_file="$(mktemp)"
  sed "s/replace-me/$skill_name/g; s/Replace Me/$display_name/g" "$seeded_file" > "$tmp_file"
  mv "$tmp_file" "$seeded_file"
done

cat <<EOF
Created $target

Next:
  1. Fill in SKILL.md (name, trigger-focused description, workflow steps).
  2. Fill in agents/openai.yaml (display name, short description, default_prompt
     mentioning \$$skill_name).
  3. Add "- \`$skill_name\`: ..." to the Skills section of README.md and README.ko.md.
  4. Bump version in .claude-plugin/plugin.json and .codex-plugin/plugin.json.
  5. Run scripts/validate-skills.sh
EOF
