#!/usr/bin/env bash
set -eo pipefail
export LC_ALL=C

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' \
    'Usage: install-coding-principles.sh [install|uninstall] [options]' \
    'Default action: install; reinstall updates the managed block.' \
    '' \
    '  --scope global|project   Installation scope (default: global)' \
    '  --agent NAMES           Comma-separated agents; repeatable (default: codex,claude)' \
    '                          codex, claude (claude-code), grok, antigravity, opencode, pi,' \
    '                          amp, cline, cursor, droid, gemini-cli, github-copilot, goose,' \
    '                          junie, kimi-code-cli, kiro-cli, mistral-vibe, qwen-code, roo,' \
    '                          warp, windsurf, zed, both, all' \
    '  --project-dir PATH      Project folder; requires --scope project (default: current folder)' \
    '  --interactive           Open the terminal UI with options preselected; requires a terminal' \
    '  --yes, -y               Use options/defaults without the selection UI' \
    '  --help, -h              Show this help without changing files' \
    '' \
    'Without selection options, a terminal opens the UI. Explicit --scope,' \
    '--agent, or --project-dir skips it unless --interactive is supplied.' \
    'Without a terminal, the defaults apply unless options override them.' \
    'Node.js 22.20+ uses skills CLI search and Clack prompts; otherwise the UI uses Bash.' \
    'Select agents first, then scope. Esc/Ctrl-C cancels; q searches in the Node agent list.' \
    'Cursor, Junie, Kimi Code CLI, and Warp support project scope in this installer.' \
    '--agent all selects every supported agent for the chosen scope.' \
    'No npm install is needed.' \
    '' \
    'Examples:' \
    '  ./scripts/install-coding-principles.sh' \
    '  ./scripts/install-coding-principles.sh --scope global --agent codex' \
    '  ./scripts/install-coding-principles.sh --scope project --agent codex --project-dir /path/to/project' \
    '  ./scripts/install-coding-principles.sh --interactive --scope global --agent codex' \
    '  ./scripts/install-coding-principles.sh uninstall --scope global --agent codex'
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

agent_ids=(codex claude grok antigravity opencode pi amp cline cursor droid gemini-cli github-copilot goose junie kimi-code-cli kiro-cli mistral-vibe qwen-code roo warp windsurf zed)
agent_labels=('Codex' 'Claude Code' 'Grok Build' 'Antigravity' 'OpenCode' 'Pi' 'Amp' 'Cline' 'Cursor' 'Droid' 'Gemini CLI' 'GitHub Copilot' 'Goose' 'Junie' 'Kimi Code CLI' 'Kiro CLI' 'Mistral Vibe' 'Qwen Code' 'Roo Code' 'Warp' 'Windsurf' 'Zed')
# Default instruction paths, not skills directories; the final summary resolves overrides.
agent_hints=('AGENTS.md / ~/.codex/AGENTS.md' 'CLAUDE.md / ~/.claude/CLAUDE.md' 'AGENTS.md / ~/.grok/AGENTS.md' 'AGENTS.md / ~/.gemini/GEMINI.md' 'AGENTS.md / ~/.config/opencode/AGENTS.md' 'AGENTS.md / ~/.pi/agent/AGENTS.md' 'AGENTS.md / ~/.config/amp/AGENTS.md' 'AGENTS.md / ~/.agents/AGENTS.md' 'AGENTS.md / project only' 'AGENTS.md / ~/.factory/AGENTS.md' 'GEMINI.md / ~/.gemini/GEMINI.md' '.github/copilot-instructions.md / ~/.copilot/copilot-instructions.md' '.goosehints / ~/.config/goose/.goosehints' '.junie/guidelines.md / project only' 'AGENTS.md / project only' 'AGENTS.md / ~/.kiro/steering/AGENTS.md' 'AGENTS.md / ~/.vibe/AGENTS.md' 'QWEN.md / ~/.qwen/QWEN.md' '.roo/rules/coding-principles.md / ~/.roo/rules/coding-principles.md' 'AGENTS.md / project only' 'AGENTS.md / ~/.codeium/windsurf/memories/global_rules.md' 'AGENTS.md / ~/.config/zed/AGENTS.md')
project_only_agent() { case "$1" in cursor|junie|kimi-code-cli|warp) return 0 ;; *) return 1 ;; esac; }
normalize_agents() {
  local items item existing duplicate known
  [[ -n "$agent_spec" && "$agent_spec" != ,* && "$agent_spec" != *, && "$agent_spec" != *,,* ]] || die 'Select at least one agent; separate names with commas'
  IFS=, read -r -a items <<< "$agent_spec"
  selected_agents=()
  for item in "${items[@]}"; do
    case "$item" in
      both) selected_agents+=(codex claude); continue ;;
      all)
        for existing in "${agent_ids[@]}"; do
          if [[ "$scope" == project ]] || ! project_only_agent "$existing"; then selected_agents+=("$existing"); fi
        done
        continue ;;
      claude-code) item=claude ;;
    esac
    known=false
    for existing in "${agent_ids[@]}"; do if [[ "$existing" == "$item" ]]; then known=true; fi; done
    $known || die "Unknown or unverified agent: $item; see --help for supported instruction installs"
    duplicate=false
    for existing in "${selected_agents[@]}"; do if [[ "$existing" == "$item" ]]; then duplicate=true; fi; done
    if ! $duplicate; then selected_agents+=("$item"); fi
  done
}
normalize_agents

terminal_state=
node_ui=
ui_temporary=
restore_terminal() { if [[ -n "$terminal_state" ]]; then stty "$terminal_state" <&3; fi; }
cleanup_ui() { restore_terminal; if [[ -n "$ui_temporary" ]]; then rm -rf -- "$ui_temporary"; fi; }
cancel() { printf '\nCancelled. No files changed.\n' >&3; exit 0; }
prepare_node_ui() {
  command -v node >/dev/null 2>&1 || return 0
  # Match the supported Node baseline of skills CLI before downloading its UI library.
  node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 22 || (major === 22 && minor >= 20) ? 0 : 1)' >/dev/null 2>&1 || return 0
  local directory
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    node_ui="$directory/coding-principles-ui.cjs"
  fi
  if [[ ! -f "$node_ui" ]]; then
    if command -v curl >/dev/null 2>&1; then
      ui_temporary=$(mktemp -d)
      node_ui="$ui_temporary/coding-principles-ui.cjs"
      if ! curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/coding-principles-ui.cjs -o "$node_ui" --connect-timeout 5 --max-time 15 2>/dev/null; then node_ui=; fi
    else node_ui=; fi
  fi
  if [[ -n "$node_ui" ]] && node "$node_ui" --check >/dev/null 2>&1; then return; fi
  node_ui=
  printf 'Node UI unavailable; using Bash UI.\n' >&3
}
run_node_ui() {
  # Selection results use stdout; retain terminal colors on the separate UI stream.
  if [[ -z "${NO_COLOR+x}" && -z "${FORCE_COLOR+x}" && "${TERM:-dumb}" != dumb ]]; then
    FORCE_COLOR=1 node "$node_ui" "$@" <&3 2>&3
  else node "$node_ui" "$@" <&3 2>&3; fi
}
menu() {
  local title=$1 mode=$2 initial=$3 cursor=0 key sequence mark pointer i message= result status start end height
  shift 3
  local labels=("$@") checked=()
  if [[ -n "$node_ui" ]]; then
    if result=$(run_node_ui "$title" "$mode" "$initial" "${labels[@]}"); then
      if [[ "$mode" == note ]]; then return; fi
      if [[ "$mode" == text ]]; then directory=$result; restore_terminal; return; fi
      [[ -n "$result" && "$result" != *[!0-9\ ]* ]] || die 'Invalid Node UI selection'
      IFS=' ' read -r -a choices <<< "$result"
      [[ "$mode" == multiple || ${#choices[@]} -eq 1 ]] || die 'Invalid Node UI selection'
      for i in "${choices[@]}"; do [[ $i -lt ${#labels[@]} ]] || die 'Invalid Node UI selection'; done
      restore_terminal
      return
    else
      status=$?
      if [[ $status -eq 2 ]]; then cancel; fi
      if [[ $status -eq 130 ]]; then printf '\nCancelled. No files changed.\n' >&3; exit 130; fi
      die 'Node selection failed; no files changed'
    fi
  fi
  if [[ "$mode" == confirm ]]; then mode=single; fi
  for ((i=0; i<${#labels[@]}; i++)); do checked[i]=false; done
  for i in $initial; do checked[i]=true; done
  if [[ "$mode" == single ]]; then cursor=$initial; fi
  stty -echo -icanon -isig min 1 time 0 <&3
  while :; do
    start=$((cursor / 8 * 8))
    end=$((start + 8))
    if [[ $end -gt ${#labels[@]} ]]; then end=${#labels[@]}; fi
    height=$((end - start + 3))
    printf '%s\n' "$title" >&3
    if [[ "$mode" == multiple ]]; then
      printf '  Up/Down: move  Space: toggle  Enter: continue  q/Esc: cancel\n' >&3
    else
      printf '  Up/Down: move  Enter: select  q/Esc: cancel\n' >&3
    fi
    for ((i=start; i<end; i++)); do
      pointer=' '
      mark=' '
      if [[ $i -eq $cursor ]]; then pointer='>'; fi
      if [[ "$mode" == multiple && "${checked[i]}" == true ]]; then mark=x; fi
      if [[ "$mode" == multiple ]]; then
        printf '  %s [%s] %s\n' "$pointer" "$mark" "${labels[i]%%$'\t'*}" >&3
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
    printf '\033[%sA\033[J' "$height" >&3
  done
}

# Read UI input from the terminal so a piped Bash program keeps its own stdin.
if [[ "$interactive_mode" == true ]] || { [[ "$interactive_mode" == auto && "$selection_given" == false && "${TERM:-dumb}" != dumb ]] && [[ -t 1 ]]; }; then
  if { exec 3<>/dev/tty; } 2>/dev/null; then interactive=true; elif [[ "$interactive_mode" == true ]]; then die 'Interactive mode requires a controlling terminal'; fi
fi
if $interactive; then
  terminal_state=$(stty -g <&3)
  # Bash 3.2 can exit during a key read before restoring its terminal settings.
  trap cleanup_ui EXIT
  trap 'printf "\nCancelled. No files changed.\n" >&3; exit 130' INT TERM
  prepare_node_ui
  if [[ -z "$node_ui" ]]; then printf '\nAgentSkills / Coding principles / %s / Bash UI\n\n' "$action" >&3; fi
  initial=
  ui_agents=()
  for ((i=0; i<${#agent_ids[@]}; i++)); do
    ui_agents+=("${agent_labels[i]}"$'\t'"${agent_hints[i]}")
    for chosen in "${selected_agents[@]}"; do if [[ "$chosen" == "${agent_ids[i]}" ]]; then initial="$initial $i"; fi; done
  done
  menu 'Choose agents' multiple "$initial" "${ui_agents[@]}"
  selected_agents=()
  for i in "${choices[@]}"; do selected_agents+=("${agent_ids[i]}"); done
  project_required=false
  for chosen in "${selected_agents[@]}"; do if project_only_agent "$chosen"; then project_required=true; fi; done
  if $project_required; then
    menu 'Installation scope' single 0 'Project'
  else
    initial=1
    if [[ "$scope" == project ]]; then initial=0; fi
    menu 'Installation scope' single "$initial" 'Project' 'Global'
  fi
  if [[ "${choices[0]}" == 1 ]]; then scope=global; project_dir=; else
    scope=project
    if [[ -n "$node_ui" ]]; then menu 'Project folder' text "${project_dir:-$PWD}"; else
      printf 'Project folder [%s]: ' "${project_dir:-$PWD}" >&3
      IFS= read -r directory <&3 || cancel
    fi
    project_dir=${directory:-${project_dir:-$PWD}}
  fi
fi
[[ "$scope" == project || -z "$project_dir" ]] || die '--project-dir requires --scope project'
if [[ "$scope" == global ]]; then
  for chosen in "${selected_agents[@]}"; do
    if project_only_agent "$chosen"; then die "$chosen supports project instructions here; use --scope project"; fi
  done
fi

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
      amp) directory=$HOME/.config/amp ;;
      cline) directory=$HOME/.agents ;;
      droid) directory=$HOME/.factory ;;
      gemini-cli) directory=$HOME/.gemini ;;
      github-copilot) directory=${COPILOT_HOME:-$HOME/.copilot} ;;
      goose) directory=$HOME/.config/goose ;;
      kiro-cli) directory=$HOME/.kiro/steering ;;
      mistral-vibe) directory=${VIBE_HOME:-$HOME/.vibe} ;;
      qwen-code) directory=$HOME/.qwen ;;
      roo) directory=$HOME/.roo/rules ;;
      windsurf) directory=$HOME/.codeium/windsurf/memories ;;
      zed) directory=$HOME/.config/zed ;;
    esac
    expand_home "$directory"
    directory=$resolved
  fi
  filename=AGENTS.md
  if [[ "$agent" == claude ]]; then filename=CLAUDE.md; fi
  if [[ "$agent" == antigravity && "$scope" == global ]]; then filename=GEMINI.md; fi
  case "$agent" in
    gemini-cli) filename=GEMINI.md ;;
    qwen-code) filename=QWEN.md ;;
    github-copilot)
      filename=copilot-instructions.md
      if [[ "$scope" == project ]]; then directory=$project_dir/.github; fi ;;
    goose) filename=.goosehints ;;
    roo)
      filename=coding-principles.md
      if [[ "$scope" == project ]]; then directory=$project_dir/.roo/rules; fi ;;
    windsurf) if [[ "$scope" == global ]]; then filename=global_rules.md; windsurf_global_target="$directory/$filename"; fi ;;
    junie)
      directory=$project_dir/.junie
      filename=guidelines.md
      if [[ -f "$directory/AGENTS.md" ]]; then targets+=("$directory/AGENTS.md")
      elif [[ -f "$project_dir/AGENTS.md" ]]; then targets+=("$project_dir/AGENTS.md"); fi
      if [[ "$action" == uninstall ]]; then targets+=("$project_dir/.junie/guidelines.md" "$project_dir/.junie/AGENTS.md" "$project_dir/AGENTS.md"); continue; fi ;;
    zed)
      if [[ "$scope" == project ]]; then
        for candidate in .rules .cursorrules .windsurfrules .clinerules .github/copilot-instructions.md AGENT.md AGENTS.md CLAUDE.md GEMINI.md; do
          if [[ "$action" == uninstall ]]; then
            if [[ ! -e "$directory/$candidate" || -f "$directory/$candidate" ]]; then targets+=("$directory/$candidate"); fi
          elif [[ -f "$directory/$candidate" ]]; then filename=$candidate; break; fi
        done
        if [[ "$action" == uninstall ]]; then continue; fi
      fi ;;
  esac
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
  if [[ -z "$node_ui" ]]; then printf '\n%s / %s\nInstruction files to check:\n' "$action" "$scope" >&3; fi
  preview=()
  for target in "${targets[@]}"; do
    resolve_path "$target"
    duplicate=false
    for prior in "${preview[@]}"; do if [[ "$prior" == "$resolved" || "$prior" -ef "$resolved" ]]; then duplicate=true; fi; done
    if ! $duplicate; then
      preview+=("$resolved")
      if [[ -z "$node_ui" ]]; then printf '  %s\n' "$resolved" >&3; fi
    fi
  done
  if [[ -n "$node_ui" ]]; then menu 'Instruction Summary' note "$action / $scope" "${preview[@]}"; fi
  if [[ "$action" == install ]]; then confirmation='Proceed with installation?'; else confirmation='Proceed with removal?'; fi
  menu "$confirmation" confirm 0 "$action principles" 'Cancel'
  [[ "${choices[0]}" == 0 ]] || cancel
  cleanup_ui
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
ROO_POINTER='Read and follow the existing Roo rules in [.roorules]('
windsurf_global_path=
if [[ -n "${windsurf_global_target:-}" ]]; then resolve_path "$windsurf_global_target"; windsurf_global_path=$resolved; fi
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
  # Adding a Roo rules directory makes the legacy workspace fallback inactive.
  if [[ "$scope" == project && "$target" == "$project_dir/.roo/rules/coding-principles.md" && ! -e "$path" && -f "$project_dir/.roorules" ]]; then
    import_text="$ROO_POINTER<$project_dir/.roorules>)."$'\n\n'
  fi
  if [[ "$scope" == global && "$target" == "$opencode_global_target" && ! -e "$path" && -f "$HOME/.claude/CLAUDE.md" ]]; then
    case "${OPENCODE_DISABLE_CLAUDE_CODE:-}:${OPENCODE_DISABLE_CLAUDE_CODE_PROMPT:-}" in
      1:*|true:*|*:1|*:true) ;;
      *) import_text="$GLOBAL_POINTER<$HOME/.claude/CLAUDE.md>)."$'\n\n' ;;
    esac
  fi
  if [[ "$scope" == project && "$target" == "$project_dir/AGENTS.md" && ! -e "$path" ]]; then
    for candidate in AGENT.md AGENTS.MD CLAUDE.md CLAUDE.MD; do
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
    for candidate in AGENT.md AGENTS.MD CLAUDE.md CLAUDE.MD; do
      pointer="Read and follow the project instructions in [$candidate]($candidate)."$'\n\n'
      if [[ "$body" == *"$pointer"* ]]; then import_text=$pointer; fi
    done
    if [[ "$body" == *"$GLOBAL_POINTER"* ]]; then
      pointer=${body#*"$GLOBAL_POINTER"}
      import_text="$GLOBAL_POINTER${pointer%%$'\n'*}"$'\n\n'
    fi
    if [[ "$body" == *"$ROO_POINTER"* ]]; then
      pointer=${body#*"$ROO_POINTER"}
      import_text="$ROO_POINTER${pointer%%$'\n'*}"$'\n\n'
    fi
  fi
  changed="$before$after"
  if [[ "$action" == install ]]; then
    metadata=
    if $created; then metadata="$CREATED"$'\n'; fi
    changed="$before"$'\n\n'"$START"$'\n'"$metadata$import_text$principles"$'\n'"$END"$'\n'"$after"
  fi
  if [[ "$changed" != "$original" ]]; then
    # shortcut: bytes conservatively bound UTF-8 characters; count characters if this blocks real rules.
    if [[ "$action" == install && ${#changed} -gt 6000 ]] && { [[ "$path" == "$windsurf_global_path" ]] || [[ -n "$windsurf_global_path" && "$path" -ef "$windsurf_global_path" ]]; }; then
      die 'Windsurf global rules would exceed 6000 bytes; use project scope or shorten existing rules'
    fi
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
