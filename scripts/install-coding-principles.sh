#!/usr/bin/env bash
set -eo pipefail
export LC_ALL=C

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' \
    'Usage: install-coding-principles.sh [install|uninstall] [options]' \
    '  --scope global|project   Installation scope (default: global)' \
    '  --agent NAMES           Comma-separated agents; repeatable (default: codex,claude)' \
    '                          codex, claude, grok, antigravity, opencode, pi, both, all' \
    '  --project-dir PATH      Project folder (default: current folder)' \
    '  --interactive           Open the terminal selection UI' \
    '  --yes, -y               Use options/defaults without the selection UI'
}

action=install
scope=global
agent_spec=codex,claude
agent_given=false
selection_given=false
interactive_mode=auto
interactive=false
project_dir=
if [[ "${1:-}" == install || "${1:-}" == uninstall ]]; then
  action=$1
  shift
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope|--agent|--project-dir)
      [[ $# -ge 2 && -n "$2" ]] || die "$1 requires a value"
      selection_given=true
      case "$1" in
        --scope) scope=$2 ;;
        --agent)
          if ! $agent_given; then agent_spec=$2; else agent_spec="$agent_spec,$2"; fi
          agent_given=true ;;
        --project-dir) project_dir=$2 ;;
      esac
      shift 2 ;;
    --interactive) interactive_mode=true; shift ;;
    --yes|-y) interactive_mode=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done
[[ "$scope" == global || "$scope" == project ]] || die 'Scope must be global or project'

agent_ids=(codex claude grok antigravity opencode pi)
agent_labels=('Codex' 'Claude Code' 'Grok Build' 'Antigravity' 'OpenCode' 'Pi')
normalize_agents() {
  local items item existing duplicate
  [[ -n "$agent_spec" && "$agent_spec" != ,* && "$agent_spec" != *, && "$agent_spec" != *,,* ]] || die 'Select at least one agent; separate names with commas'
  IFS=, read -r -a items <<< "$agent_spec"
  selected_agents=()
  for item in "${items[@]}"; do
    case "$item" in
      both) selected_agents+=(codex claude); continue ;;
      all) selected_agents+=("${agent_ids[@]}"); continue ;;
      codex|claude|grok|antigravity|opencode|pi) ;;
      *) die "Unknown agent: $item" ;;
    esac
    duplicate=false
    for existing in "${selected_agents[@]}"; do if [[ "$existing" == "$item" ]]; then duplicate=true; fi; done
    if ! $duplicate; then selected_agents+=("$item"); fi
  done
}
normalize_agents

terminal_state=
restore_terminal() { if [[ -n "$terminal_state" ]]; then stty "$terminal_state" <&3; fi; }
cancel() { printf '\nCancelled. No files changed.\n' >&3; exit 0; }
menu() {
  local title=$1 mode=$2 initial=$3 cursor=0 key sequence mark pointer i message=
  shift 3
  local labels=("$@") checked=()
  for ((i=0; i<${#labels[@]}; i++)); do checked[i]=false; done
  for i in $initial; do checked[i]=true; done
  if [[ "$mode" == single ]]; then cursor=$initial; fi
  stty -echo -icanon -isig min 1 time 0 <&3
  while :; do
    printf '%s\n' "$title" >&3
    if [[ "$mode" == multiple ]]; then
      printf '  Up/Down: move  Space: toggle  Enter: continue  q/Esc: cancel\n' >&3
    else
      printf '  Up/Down: move  Enter: select  q/Esc: cancel\n' >&3
    fi
    for ((i=0; i<${#labels[@]}; i++)); do
      pointer=' '
      mark=' '
      if [[ $i -eq $cursor ]]; then pointer='>'; fi
      if [[ "$mode" == multiple && "${checked[i]}" == true ]]; then mark=x; fi
      if [[ "$mode" == multiple ]]; then
        printf '  %s [%s] %s\n' "$pointer" "$mark" "${labels[i]}" >&3
      else
        printf '  %s %s\n' "$pointer" "${labels[i]}" >&3
      fi
    done
    printf '  %s\n' "$message" >&3
    IFS= read -r -n 1 key <&3 || cancel
    if [[ "$key" == $'\033' ]]; then
      sequence=
      IFS= read -r -n 2 -t 1 sequence <&3 || :
      [[ -n "$sequence" ]] || cancel
      key="$key$sequence"
    fi
    message=
    case "$key" in
      $'\033[A'|$'\033OA') cursor=$(((cursor + ${#labels[@]} - 1) % ${#labels[@]})) ;;
      $'\033[B'|$'\033OB') cursor=$(((cursor + 1) % ${#labels[@]})) ;;
      ' ')
        if [[ "$mode" == multiple ]]; then
          if ${checked[cursor]}; then checked[cursor]=false; else checked[cursor]=true; fi
        fi ;;
      '')
        choices=()
        if [[ "$mode" == single ]]; then choices=("$cursor"); restore_terminal; return; fi
        for ((i=0; i<${#labels[@]}; i++)); do if ${checked[i]}; then choices+=("$i"); fi; done
        if [[ ${#choices[@]} -gt 0 ]]; then restore_terminal; return; fi
        message='Select at least one agent.' ;;
      q|Q) cancel ;;
      $'\003') printf '\nCancelled. No files changed.\n' >&3; exit 130 ;;
    esac
    printf '\033[%sA\033[J' "$((${#labels[@]} + 3))" >&3
  done
}

# Read UI input from the terminal so a piped Bash program keeps its own stdin.
if [[ "$interactive_mode" == true ]] || { [[ "$interactive_mode" == auto && "$selection_given" == false && "${TERM:-dumb}" != dumb ]] && [[ -t 1 ]]; }; then
  if { exec 3<>/dev/tty; } 2>/dev/null; then interactive=true; elif [[ "$interactive_mode" == true ]]; then die 'Interactive mode requires a controlling terminal'; fi
fi
if $interactive; then
  terminal_state=$(stty -g <&3)
  # Bash 3.2 can exit during a key read before restoring its terminal settings.
  trap restore_terminal EXIT
  trap 'printf "\nCancelled. No files changed.\n" >&3; exit 130' INT TERM
  printf '\nAgentSkills / Coding principles / %s\n\n' "$action" >&3
  initial=0
  if [[ "$scope" == project ]]; then initial=1; fi
  menu 'Installation scope' single "$initial" 'Personal / global' 'Project'
  if [[ "${choices[0]}" == 0 ]]; then scope=global; project_dir=; else
    scope=project
    printf 'Project folder [%s]: ' "${project_dir:-$PWD}" >&3
    IFS= read -r directory <&3 || cancel
    project_dir=${directory:-${project_dir:-$PWD}}
  fi
  initial=
  for ((i=0; i<${#agent_ids[@]}; i++)); do
    for chosen in "${selected_agents[@]}"; do if [[ "$chosen" == "${agent_ids[i]}" ]]; then initial="$initial $i"; fi; done
  done
  menu 'Choose agents' multiple "$initial" "${agent_labels[@]}"
  selected_agents=()
  for i in "${choices[@]}"; do selected_agents+=("${agent_ids[i]}"); done
fi
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
fi

targets=()
opencode_global_target=
for agent in "${selected_agents[@]}"; do
  if [[ "$scope" == project ]]; then directory=$project_dir; else
    case "$agent" in
      codex) directory=${CODEX_HOME:-$HOME/.codex} ;;
      claude) directory=${CLAUDE_CONFIG_DIR:-$HOME/.claude} ;;
      grok) directory=$HOME/.grok ;;
      antigravity) directory=$HOME/.gemini ;;
      opencode) directory=${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode} ;;
      pi) directory=${PI_CODING_AGENT_DIR:-$HOME/.pi/agent} ;;
    esac
    expand_home "$directory"
    directory=$resolved
  fi
  filename=AGENTS.md
  if [[ "$agent" == claude ]]; then filename=CLAUDE.md; fi
  if [[ "$agent" == antigravity && "$scope" == global ]]; then filename=GEMINI.md; fi
  if [[ "$agent" == opencode && "$scope" == project ]]; then
    if [[ "$action" == uninstall ]]; then targets+=("$directory/AGENTS.md" "$directory/CLAUDE.md"); continue; fi
    if [[ ! -f "$directory/AGENTS.md" && -f "$directory/CLAUDE.md" ]]; then filename=CLAUDE.md; fi
  fi
  if [[ "$agent" == codex ]]; then
    if [[ "$action" == uninstall ]]; then targets+=("$directory/AGENTS.md" "$directory/AGENTS.override.md"); continue; fi
    content=
    if [[ -f "$directory/AGENTS.override.md" ]]; then read_file "$directory/AGENTS.override.md"; fi
    if [[ -n "${content//[[:space:]]/}" ]]; then filename=AGENTS.override.md; fi
  elif [[ "$agent" == pi ]]; then
    # Pi reads the first existing context filename, including an empty override.
    for candidate in AGENTS.override.md AGENTS.md AGENTS.MD CLAUDE.md CLAUDE.MD; do
      if [[ "$action" == uninstall ]]; then targets+=("$directory/$candidate"); elif [[ -f "$directory/$candidate" ]]; then filename=$candidate; break; fi
    done
    if [[ "$action" == uninstall ]]; then continue; fi
  fi
  if [[ "$agent" == opencode && "$scope" == global ]]; then opencode_global_target="$directory/$filename"; fi
  targets+=("$directory/$filename")
done

if $interactive; then
  printf '\n%s / %s\nInstruction files to check:\n' "$action" "$scope" >&3
  preview=()
  for target in "${targets[@]}"; do
    resolve_path "$target"
    duplicate=false
    for prior in "${preview[@]}"; do if [[ "$prior" == "$resolved" || "$prior" -ef "$resolved" ]]; then duplicate=true; fi; done
    if ! $duplicate; then preview+=("$resolved"); printf '  %s\n' "$resolved" >&3; fi
  done
  menu 'Apply these choices?' single 0 "$action principles" 'Cancel'
  [[ "${choices[0]}" == 0 ]] || cancel
  restore_terminal
  terminal_state=
  exec 3>&-
  trap - EXIT INT TERM
fi

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
GLOBAL_POINTER='Read and follow the existing global instructions in [CLAUDE.md]('
paths=()
changes=()
remove=()
seen=()
for target in "${targets[@]}"; do
  resolve_path "$target"
  path=$resolved
  duplicate=false
  for prior in "${seen[@]}"; do if [[ "$prior" == "$path" || "$prior" -ef "$path" ]]; then duplicate=true; fi; done
  if $duplicate; then continue; fi
  seen+=("$path")
  original=
  created=true
  if [[ -e "$path" ]]; then read_file "$path"; original=$content; created=false; fi
  before=$original
  after=
  import_text=
  if [[ "$scope" == global && "$target" == "$opencode_global_target" && ! -e "$path" && -f "$HOME/.claude/CLAUDE.md" ]]; then
    case "${OPENCODE_DISABLE_CLAUDE_CODE:-}:${OPENCODE_DISABLE_CLAUDE_CODE_PROMPT:-}" in
      1:*|true:*|*:1|*:true) ;;
      *) import_text="$GLOBAL_POINTER<$HOME/.claude/CLAUDE.md>)."$'\n\n' ;;
    esac
  fi
  if [[ "$scope" == project && "$target" == "$project_dir/AGENTS.md" && ! -e "$path" ]]; then
    for candidate in AGENTS.MD CLAUDE.md CLAUDE.MD; do
      if [[ -f "$project_dir/$candidate" ]]; then
        import_text="Read and follow the project instructions in [$candidate]($candidate)."$'\n\n'
        break
      fi
    done
  fi
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
    for candidate in AGENTS.MD CLAUDE.md CLAUDE.MD; do
      pointer="Read and follow the project instructions in [$candidate]($candidate)."$'\n\n'
      if [[ "$body" == *"$pointer"* ]]; then import_text=$pointer; fi
    done
    if [[ "$body" == *"$GLOBAL_POINTER"* ]]; then
      pointer=${body#*"$GLOBAL_POINTER"}
      import_text="$GLOBAL_POINTER${pointer%%$'\n'*}"$'\n\n'
    fi
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
