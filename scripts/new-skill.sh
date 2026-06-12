#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: scripts/new-skill.sh <skill-name>" >&2
  exit 2
fi

skill_name="$1"

case "$skill_name" in
  *[!a-z0-9-]* | "" | -* | *-)
    echo "Skill name must be kebab-case: lowercase letters, numbers, and hyphens." >&2
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

tmp_file="$(mktemp)"
sed "s/replace-me/$skill_name/g; s/Replace Me/$display_name/g" "$target/SKILL.md" > "$tmp_file"
mv "$tmp_file" "$target/SKILL.md"

tmp_file="$(mktemp)"
sed "s/replace-me/$skill_name/g; s/Replace Me/$display_name/g" "$target/agents/openai.yaml" > "$tmp_file"
mv "$tmp_file" "$target/agents/openai.yaml"

echo "Created $target"
