#!/usr/bin/env bash
set -eo pipefail
export LC_ALL=C

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' 'Usage: install-coding-principles.sh [install|uninstall] [--scope global|project] [--agent codex|claude|both] [--project-dir PATH]'
}

action=install
scope=global
agent=both
project_dir=
if [[ "${1:-}" == install || "${1:-}" == uninstall ]]; then
  action=$1
  shift
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope|--agent|--project-dir)
      [[ $# -ge 2 && -n "$2" ]] || die "$1 requires a value"
      case "$1" in
        --scope) scope=$2 ;;
        --agent) agent=$2 ;;
        --project-dir) project_dir=$2 ;;
      esac
      shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done
[[ "$scope" == global || "$scope" == project ]] || die 'Scope must be global or project'
[[ "$agent" == codex || "$agent" == claude || "$agent" == both ]] || die 'Agent must be codex, claude, or both'
[[ "$scope" == project || -z "$project_dir" ]] || die '--project-dir requires --scope project'

expand_home() {
  case "$1" in
    '~') resolved=$HOME ;;
    '~/'*) resolved="$HOME/${1#\~/}" ;;
    *) resolved=$1 ;;
  esac
}

# Resolve the destination rather than replacing its symlink during an atomic write.
resolve_path() {
  local path=$1 parent name link count=0
  [[ "$path" == /* ]] || path="$PWD/$path"
  while [[ -L "$path" ]]; do
    count=$((count + 1))
    [[ $count -le 40 ]] || die "Symlink loop: $path"
    link=$(readlink "$path") || die "Cannot read symlink: $path"
    if [[ "$link" == /* ]]; then path=$link; else path="$(dirname "$path")/$link"; fi
  done
  parent=$(dirname "$path")
  name=$(basename "$path")
  if [[ -d "$parent" ]]; then
    resolved="$(cd -P -- "$parent" && pwd)/$name"
  else
    resolve_path "$parent"
    resolved="$resolved/$name"
  fi
}

read_file() {
  content=
  [[ -f "$1" && -r "$1" ]] || die "Cannot read file: $1"
  # read retains final newlines; a NUL byte means this is not an instruction file.
  if IFS= read -r -d '' content < "$1"; then die "NUL byte in instruction file: $1"; fi
}

if [[ "$scope" == project ]]; then
  expand_home "${project_dir:-$PWD}"
  [[ -d "$resolved" ]] || die "Project directory does not exist: $resolved"
  project_dir=$(cd -P -- "$resolved" && pwd)
  codex_dir=$project_dir
  claude_dir=$project_dir
else
  expand_home "${CODEX_HOME:-$HOME/.codex}"
  codex_dir=$resolved
  expand_home "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  claude_dir=$resolved
fi

targets=()
if [[ "$agent" != claude ]]; then
  base="$codex_dir/AGENTS.md"
  override="$codex_dir/AGENTS.override.md"
  if [[ "$action" == uninstall ]]; then
    targets+=("$base" "$override")
  else
    content=
    if [[ -f "$override" ]]; then read_file "$override"; fi
    if [[ -n "${content//[[:space:]]/}" ]]; then targets+=("$override"); else targets+=("$base"); fi
  fi
fi
if [[ "$agent" != codex ]]; then targets+=("$claude_dir/CLAUDE.md"); fi

temporary=
staged=()
cleanup() {
  if [[ -n "$temporary" ]]; then rm -rf -- "$temporary"; fi
  for file in "${staged[@]}"; do [[ -z "$file" ]] || rm -f -- "$file"; done
}
trap cleanup EXIT
principles=
if [[ "$action" == install ]]; then
  source_file=
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    source_file="$directory/../docs/coding-principles.md"
  fi
  if [[ ! -f "$source_file" ]]; then
    temporary=$(mktemp -d "${TMPDIR:-/tmp}/agent-skills-principles.XXXXXXXX")
    source_file="$temporary/coding-principles.md"
    curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/docs/coding-principles.md -o "$source_file"
  fi
  read_file "$source_file"
  principles=$content
  shopt -s extglob
  principles=${principles%%+([[:space:]])}
  [[ -n "$principles" ]] || die 'Coding principles are empty'
fi

START='<!-- AgentSkills:coding-principles:start -->'
END='<!-- AgentSkills:coding-principles:end -->'
CREATED='<!-- AgentSkills:coding-principles:created-file -->'
paths=()
changes=()
remove=()
seen=()
for target in "${targets[@]}"; do
  resolve_path "$target"
  path=$resolved
  duplicate=false
  for prior in "${seen[@]}"; do if [[ "$prior" == "$path" ]]; then duplicate=true; fi; done
  if $duplicate; then continue; fi
  seen+=("$path")
  original=
  created=true
  if [[ -e "$path" ]]; then read_file "$path"; original=$content; created=false; fi
  before=$original
  after=
  import_text=
  if [[ "$scope" == project && "$target" == "$project_dir/CLAUDE.md" && ! -e "$path" && -f "$project_dir/AGENTS.md" ]]; then
    read_file "$project_dir/AGENTS.md"
    if [[ -n "${content//[[:space:]]/}" ]]; then import_text=$'@AGENTS.md\n'; fi
  fi
  if [[ "$original" == *"$START"* || "$original" == *"$END"* ]]; then
    [[ "$original" == *"$START"* && "$original" == *"$END"* ]] || die "Incomplete managed block: $path"
    before=${original%%"$START"*}
    body=${original#*"$START"}
    [[ "$body" != *"$START"* && "$body" == *"$END"* ]] || die "Duplicated or reversed managed block: $path"
    after=${body#*"$END"}
    body=${body%%"$END"*}
    [[ "$before" != *"$END"* && "$after" != *"$END"* ]] || die "Duplicated or reversed managed block: $path"
    [[ "$before" == *$'\n\n' && "$after" == $'\n'* ]] || die "Managed block boundaries were changed: $path"
    before=${before%$'\n\n'}
    after=${after#$'\n'}
    created=false
    if [[ "$body" == *"$CREATED"* ]]; then created=true; fi
    if [[ "$body" == *$'@AGENTS.md\n'* ]]; then import_text=$'@AGENTS.md\n'; fi
  fi
  changed="$before$after"
  if [[ "$action" == install ]]; then
    metadata=
    if $created; then metadata="$CREATED"$'\n'; fi
    changed="$before"$'\n\n'"$START"$'\n'"$metadata$import_text$principles"$'\n'"$END"$'\n'"$after"
  fi
  if [[ "$changed" != "$original" ]]; then
    paths+=("$path")
    changes+=("$changed")
    if [[ "$action" == uninstall && "$created" == true && -z "$changed" ]]; then remove+=(true); else remove+=(false); fi
  fi
done

# Validate all destinations and stage replacements before changing either agent's file.
for ((i=0; i<${#paths[@]}; i++)); do
  path=${paths[i]}
  staged[i]=
  if [[ "${remove[i]}" == false ]]; then
    mkdir -p -- "$(dirname "$path")"
    staged[i]=$(mktemp "$(dirname "$path")/.coding-principles.XXXXXXXX")
    printf '%s' "${changes[i]}" > "${staged[i]}"
    if [[ -e "$path" ]]; then
      mode=$(stat -f '%Lp' "$path" 2>/dev/null) || mode=$(stat -c '%a' "$path")
      chmod "$mode" "${staged[i]}"
    fi
  fi
done
for ((i=0; i<${#paths[@]}; i++)); do
  if [[ "${remove[i]}" == true ]]; then rm -- "${paths[i]}"; else mv -f -- "${staged[i]}" "${paths[i]}"; fi
  printf '%s: %s\n' "$action" "${paths[i]}"
done
if [[ ${#paths[@]} -eq 0 ]]; then
  if [[ "$action" == install ]]; then printf 'Already installed.\n'; else printf 'No installed block found.\n'; fi
fi
