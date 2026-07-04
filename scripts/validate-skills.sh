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

readme_skills_section() {
  awk '/^## /{f=0} $0=="## Skills" || $0=="## 스킬"{f=1; next} f' "$1"
}

while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "$skill_dir")"
  count=$((count + 1))

  if ! printf '%s' "$skill_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo "Invalid skill folder name: $skill_name" >&2
    failed=1
    continue
  fi

  skill_md="$skill_dir/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    echo "Missing SKILL.md: $skill_dir" >&2
    failed=1
    continue
  fi

  if grep -q $'\r' "$skill_md"; then
    echo "CRLF line endings (convert to LF): $skill_md" >&2
    failed=1
    continue
  fi

  if ! sed -n '1p' "$skill_md" | grep -qx -- '---'; then
    echo "Missing opening YAML frontmatter marker: $skill_md" >&2
    failed=1
  fi

  after_first_line="$(sed -n '2,$p' "$skill_md")"
  if ! printf '%s\n' "$after_first_line" | grep -qx -- '---'; then
    echo "Missing closing YAML frontmatter marker: $skill_md" >&2
    failed=1
  fi
  frontmatter="$(printf '%s\n' "$after_first_line" | sed -n '/^---$/q;p')"

  if ! printf '%s\n' "$frontmatter" | grep -Eq "^name: [\"']?$skill_name[\"']?\$"; then
    echo "name field must match folder name ($skill_name): $skill_md" >&2
    failed=1
  fi

  # Single-line description, or a folded/literal block whose first line has 20+ chars.
  if ! printf '%s\n' "$frontmatter" | grep -Eq '^description: .{20,}$' \
    && ! printf '%s\n' "$frontmatter" | grep -A1 -E '^description: *[>|][+-]?$' | grep -Eq '^[[:space:]]+.{20,}'; then
    echo "Missing or too-short description field: $skill_md" >&2
    failed=1
  fi

  if printf '%s\n' "$frontmatter" | grep -E "^(name|description): [\"']" | grep -Evq "^name: (\"[^\"]*\"|'[^']*')\$|^description: (\"[^\"]*\"|'[^']*')\$"; then
    echo "Unbalanced quote in name or description: $skill_md" >&2
    failed=1
  fi

  stray_lines="$(printf '%s\n' "$frontmatter" | grep -Ev '^[A-Za-z_-]+:([[:space:]]|$)|^[[:space:]]|^$' || true)"
  if [ -n "$stray_lines" ]; then
    echo "Frontmatter contains non-YAML lines: $skill_md ($(printf '%s' "$stray_lines" | head -1))" >&2
    failed=1
  fi

  extra_keys="$(printf '%s\n' "$frontmatter" | grep -E '^[A-Za-z_-]+:' | grep -Ev '^(name|description):' || true)"
  if [ -n "$extra_keys" ]; then
    echo "Frontmatter must contain only name and description: $skill_md ($(printf '%s' "$extra_keys" | tr '\n' ' '))" >&2
    failed=1
  fi

  while IFS= read -r ref; do
    if [ -n "$ref" ] && [ ! -f "$skill_dir/$ref" ]; then
      echo "SKILL.md points at missing file: $skill_dir/$ref" >&2
      failed=1
    fi
  done < <(grep -oE '(references|scripts|assets)/[A-Za-z0-9._/-]+\.[A-Za-z0-9]+' "$skill_md" | sort -u)

  # Placeholder scan covers only the files new-skill.sh seeds; references/ may
  # legitimately quote the templates.
  placeholder_files=("$skill_md")
  if [ -f "$skill_dir/agents/openai.yaml" ]; then
    placeholder_files+=("$skill_dir/agents/openai.yaml")
  fi
  if grep -q -e 'replace-me' -e 'Replace Me' -e 'Describe the task, trigger words' -e 'Short UI description' "${placeholder_files[@]}"; then
    echo "Unfilled template placeholder in: $skill_dir" >&2
    failed=1
  fi

  for readme in README.md README.ko.md; do
    if ! readme_skills_section "$repo_root/$readme" | grep -Eq "^- \`$skill_name\`:"; then
      echo "Skill not listed in $readme Skills section: $skill_name" >&2
      failed=1
    fi
  done

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

for readme in README.md README.ko.md; do
  while IFS= read -r listed; do
    if [ ! -d "$skills_dir/$listed" ]; then
      echo "$readme lists unknown skill: $listed" >&2
      failed=1
    fi
  done < <(readme_skills_section "$repo_root/$readme" | grep -oE '^- `[a-z0-9-]+`:' | sed -E 's/^- `([a-z0-9-]+)`:$/\1/')
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Validated $count skill(s)."
