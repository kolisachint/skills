#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARK_BEGIN="<!-- BEGIN AI SKILLKIT -->"
MARK_END="<!-- END AI SKILLKIT -->"

# External skill registry - sourced from actively maintained GitHub repos
# Format: skill_name~source_url~description~install_command
EXTERNAL_SKILLS_LIST="caveman~grill-me~codeburn~plannotator~context-audit~superpowers~agent-skills"

EXTERNAL_SKILL_caveman="https://github.com/JuliusBrussee/caveman~Ultra-compressed communication mode - 75% token reduction~npx skills add JuliusBrussee/caveman"
EXTERNAL_SKILL_grill_me="https://github.com/mattpocock/skills~One-question-at-a-time requirement interrogation~npx skills add mattpocock/skills --skill grill-me"
EXTERNAL_SKILL_codeburn="https://github.com/AgentSeal/CodeBurn~Interactive TUI dashboard for token/cost observability~npm install -g codeburn"
EXTERNAL_SKILL_plannotator="https://github.com/backnotprop/plannotator~Visual plan and diff review with annotations~curl -s https://plannotator.ai/install.sh | sh"
EXTERNAL_SKILL_context_audit="https://github.com/sanjeed5/ctxaudit~Context bloat detection and instruction drift monitoring~npm install -g ctxaudit"
EXTERNAL_SKILL_superpowers="https://github.com/obra/superpowers~Complete TDD and development methodology framework with 20+ production skills~npx skills add obra/superpowers"
EXTERNAL_SKILL_agent_skills="https://github.com/addyosmani/agent-skills~Production-grade engineering skills from Google's culture~npx skills add addyosmani/agent-skills"

get_external_skill_var() {
  local skill="$1"
  local var_name="EXTERNAL_SKILL_${skill//-/_}"
  printf '%s' "${!var_name:-}"
}

list_external_skill_names() {
  printf '%s\n' "$EXTERNAL_SKILLS_LIST" | tr '~' '\n'
}

usage() {
  cat <<'EOF'
Portable AI Skillkit

Commands:
  skillkit.sh list
  skillkit.sh list-components
  skillkit.sh list-external
  skillkit.sh install [--target PATH] [--skills all|a,b] [--agents all|a,b]
  skillkit.sh install-external [--skills caveman,grill-me,codeburn,plannotator,context-audit,superpowers,agent-skills]
  skillkit.sh export --output PATH [--skills all|a,b]

Agents:
  all, shared, codex, claude, opencode, github, pi

Examples:
  ./scripts/install.sh --target ~/repo
  ./scripts/install.sh --target ~/repo --skills control-first,pi-coding-agent
  ./scripts/install.sh --target ~/repo --agents codex,claude
  ./scripts/install-external.sh --skills caveman,grill-me
EOF
}

all_skills() {
  find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

all_components() {
  find "$ROOT/components" -mindepth 1 -maxdepth 1 -type f -name '*.md' -exec basename {} .md \; | sort
}

description_for() {
  local skill="$1"
  awk '
    /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$ROOT/skills/$skill/SKILL.md"
}

resolve_csv() {
  local value="$1"
  local kind="$2"

  if [[ "$value" == "all" ]]; then
    if [[ "$kind" == "skill" ]]; then
      all_skills
    else
      printf '%s\n' shared codex claude opencode github pi
    fi
    return
  fi

  printf '%s\n' "$value" | tr ',' '\n' | while IFS= read -r item; do
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done
}

validate_skills() {
  while IFS= read -r skill; do
    if [[ ! -f "$ROOT/skills/$skill/SKILL.md" ]]; then
      printf 'Unknown skill: %s\n' "$skill" >&2
      exit 1
    fi
    printf '%s\n' "$skill"
  done
}

collect_skills() {
  local csv="$1"
  local skill

  skills=()
  while IFS= read -r skill; do
    skills+=("$skill")
  done < <(resolve_csv "$csv" skill | validate_skills)
}

collect_agents() {
  local csv="$1"
  local agent

  agents=()
  while IFS= read -r agent; do
    agents+=("$agent")
  done < <(resolve_csv "$csv" agent)
}

join_by_comma() {
  local IFS=","
  printf '%s' "$*"
}

update_block() {
  local file="$1"
  local body="$2"
  local dir
  local tmp

  dir="$(dirname "$file")"
  mkdir -p "$dir"
  tmp="$(mktemp)"

  if [[ -f "$file" ]]; then
    awk -v begin="$MARK_BEGIN" -v end="$MARK_END" '
      index($0, begin) { skip=1; next }
      index($0, end) { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp"
  else
    : > "$tmp"
  fi

  {
    cat "$tmp"
    printf '\n%s\n%s\n%s\n' "$MARK_BEGIN" "$body" "$MARK_END"
  } > "$file"

  rm -f "$tmp"
}

  write_shared_index() {
  local target="$1"
  shift
  local skills=("$@")
  local shared_dir="$target/.ai/skillkit"
  local index="$shared_dir/AGENTS.md"

  mkdir -p "$shared_dir/skills"

  {
    printf '# AI Skillkit\n\n'
    printf 'Shared instructions installed from Portable AI Skillkit.\n\n'
    printf '## Active Skills\n\n'
    for skill in "${skills[@]}"; do
      cp "$ROOT/skills/$skill/SKILL.md" "$shared_dir/skills/$skill.md"
      printf -- '- `%s`: %s\n' "$skill" "$(description_for "$skill")"
    done
    printf '\n## Usage\n\n'
    printf 'When the user names one of the active skills, follow its instructions from `.ai/skillkit/skills/<skill>.md`.\n'
    printf 'For normal coding work, default to `control-first` when it is installed.\n'
    printf '\n## External Skills (Install Separately)\n\n'
    printf 'The following skills are sourced from actively maintained external repositories:\n\n'
    printf '- `caveman`: Ultra-compressed communication (JuliusBrussee/caveman)\n'
    printf '  Install: npx skills add JuliusBrussee/caveman\n\n'
    printf '- `grill-me`: One-question-at-a-time requirement interrogation (mattpocock/skills)\n'
    printf '  Install: npx skills add mattpocock/skills --skill grill-me\n\n'
    printf '- `codeburn`: Token/cost observability dashboard (AgentSeal/CodeBurn)\n'
    printf '  Install: npm install -g codeburn\n\n'
    printf '- `plannotator`: Visual plan/diff review (backnotprop/plannotator)\n'
    printf '  Install: curl -s https://plannotator.ai/install.sh | sh\n\n'
    printf '- `context-audit`: Context bloat detection (sanjeed5/ctxaudit)\n'
    printf '  Install: npm install -g ctxaudit\n\n'
    printf 'Run `./scripts/install-external.sh` to install all external skills.\n'
  } > "$index"
}

install_stack_docs() {
  local target="$1"
  local shared_dir="$target/.ai/skillkit"
  local component

  mkdir -p "$shared_dir/components" "$shared_dir/stacks"

  cp "$ROOT/stacks/control-first.md" "$shared_dir/stacks/control-first.md"

  for component in $(all_components); do
    cp "$ROOT/components/$component.md" "$shared_dir/components/$component.md"
  done
}

install_shared() {
  local target="$1"
  shift
  local skills=("$@")
  local lines=""

  lines+=$'## AI Skillkit\n'
  lines+=$'Follow the shared instructions in `.ai/skillkit/AGENTS.md`.\n\n'
  lines+=$'Active skills:\n'
  for skill in "${skills[@]}"; do
    lines+="- \`$skill\`: .ai/skillkit/skills/$skill.md"$'\n'
  done

  update_block "$target/AGENTS.md" "$lines"
}

install_claude() {
  local target="$1"
  local body
  body=$'@.ai/skillkit/AGENTS.md\n\nUse the shared AI Skillkit instructions above. For risky work, prefer a short plan before edits.'
  update_block "$target/CLAUDE.md" "$body"
}

install_github() {
  local target="$1"
  local body
  body=$'Follow the repository AI Skillkit instructions in `.ai/skillkit/AGENTS.md` and `AGENTS.md`.\n\nKeep changes narrowly scoped, preserve existing project conventions, run relevant tests, and summarize verification.'
  update_block "$target/.github/copilot-instructions.md" "$body"
}

install_opencode() {
  local target="$1"
  local body
  body=$'Follow `../AGENTS.md` and `.ai/skillkit/AGENTS.md` for project behavior.\n\nUse installed skills from `.ai/skillkit/skills/` when the user names them.'
  update_block "$target/.opencode/AGENTS.md" "$body"
}

install_codex() {
  local target="$1"
  shift
  local skills=("$@")
  local skill

  for skill in "${skills[@]}"; do
    mkdir -p "$target/.codex/skills/$skill"
    cp "$ROOT/skills/$skill/SKILL.md" "$target/.codex/skills/$skill/SKILL.md"
  done
}

install_pi() {
  local target="$1"
  shift
  local skills=("$@")
  local skill

  for skill in "${skills[@]}"; do
    mkdir -p "$target/.pi/skills/$skill"
    cp "$ROOT/skills/$skill/SKILL.md" "$target/.pi/skills/$skill/SKILL.md"
  done
}

cmd_list() {
  all_skills | while IFS= read -r skill; do
    printf '%s\t%s\n' "$skill" "$(description_for "$skill")"
  done
}

cmd_list_components() {
  all_components | while IFS= read -r component; do
    printf '%s\tcomponents/%s.md\n' "$component" "$component"
  done
}

list_external_skills() {
  local skill
  list_external_skill_names | while IFS= read -r skill; do
    local data
    data=$(get_external_skill_var "$skill")
    local url="${data%%~*}"
    local rest="${data#*~}"
    local desc="${rest%%~*}"
    printf '%s\t%s\t%s\n' "$skill" "$desc" "$url"
  done | sort
}

cmd_list_external() {
  printf 'External Skills (sourced from GitHub):\n\n'
  list_external_skills | while IFS=$'\t' read -r skill desc url; do
    printf '  %s\n' "$skill"
    printf '    Description: %s\n' "$desc"
    printf '    Source: %s\n' "$url"
    printf '\n'
  done
}

install_external_skill() {
  local skill="$1"
  local data
  
  data=$(get_external_skill_var "$skill")
  if [[ -z "$data" ]]; then
    printf 'Unknown external skill: %s\n' "$skill" >&2
    printf 'Run "skillkit.sh list-external" to see available skills\n' >&2
    return 1
  fi
  
  local url="${data%%~*}"
  local rest="${data#*~}"
  local desc="${rest%%~*}"
  local cmd="${rest##*~}"
  
  printf 'Installing external skill: %s\n' "$skill"
  printf 'Source: %s\n' "$url"
  printf 'Command: %s\n' "$cmd"
  
  eval "$cmd" || {
    printf 'Failed to install %s\n' "$skill" >&2
    return 1
  }
  
  printf 'Successfully installed: %s\n' "$skill"
}

cmd_install_external() {
  local skills_csv="all"
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skills)
        skills_csv="$2"
        shift 2
        ;;
      -h|--help)
        printf 'Usage: skillkit.sh install-external [--skills all|skill1,skill2,...]\n' >&2
        printf '\nInstalls external skills from actively maintained GitHub repositories.\n' >&2
        printf '\nAvailable skills:\n' >&2
        list_external_skills | while IFS=$'\t' read -r skill desc url; do
          printf '  - %s: %s\n' "$skill" "$desc" >&2
        done
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        exit 1
        ;;
    esac
  done
  
  if [[ "$skills_csv" == "all" ]]; then
    local skill
    list_external_skill_names | while IFS= read -r skill; do
      install_external_skill "$skill"
      printf '\n'
    done
  else
    local skill
    printf '%s\n' "$skills_csv" | tr ',' '\n' | while IFS= read -r skill; do
      [[ -n "$skill" ]] && install_external_skill "$skill"
    done
  fi
}

cmd_install() {
  local target="$PWD"
  local skills_csv="all"
  local agents_csv="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target)
        target="$2"
        shift 2
        ;;
      --skills)
        skills_csv="$2"
        shift 2
        ;;
      --agents)
        agents_csv="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  mkdir -p "$target"

  collect_skills "$skills_csv"
  collect_agents "$agents_csv"

  write_shared_index "$target" "${skills[@]}"
  install_stack_docs "$target"

  for agent in "${agents[@]}"; do
    case "$agent" in
      shared) install_shared "$target" "${skills[@]}" ;;
      codex) install_codex "$target" "${skills[@]}" ;;
      claude) install_claude "$target" ;;
      opencode) install_opencode "$target" ;;
      github) install_github "$target" ;;
      pi) install_pi "$target" "${skills[@]}" ;;
      *)
        printf 'Unknown agent: %s\n' "$agent" >&2
        exit 1
        ;;
    esac
  done

  printf 'Installed %s skill(s) for agents: %s\n' "${#skills[@]}" "$(join_by_comma "${agents[@]}")"
  printf 'Target: %s\n' "$target"
}

cmd_export() {
  local output=""
  local skills_csv="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output)
        output="$2"
        shift 2
        ;;
      --skills)
        skills_csv="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  if [[ -z "$output" ]]; then
    printf 'Missing required --output PATH\n' >&2
    exit 1
  fi

  collect_skills "$skills_csv"

  mkdir -p "$output/skills" "$output/scripts"
  mkdir -p "$output/components" "$output/stacks"
  cp "$ROOT/README.md" "$output/README.md"
  cp "$ROOT/AGENTS.md" "$output/AGENTS.md"
  cp "$ROOT/scripts/skillkit.sh" "$output/scripts/skillkit.sh"
  cp "$ROOT/scripts/install.sh" "$output/scripts/install.sh"
  cp "$ROOT/scripts/export.sh" "$output/scripts/export.sh"
  cp "$ROOT/scripts/skillkit.ps1" "$output/scripts/skillkit.ps1"
  cp "$ROOT/scripts/install.ps1" "$output/scripts/install.ps1"
  cp "$ROOT/scripts/export.ps1" "$output/scripts/export.ps1"
  cp "$ROOT/stacks/control-first.md" "$output/stacks/control-first.md"
  cp "$ROOT/components/"*.md "$output/components/"

  for skill in "${skills[@]}"; do
    mkdir -p "$output/skills/$skill"
    cp "$ROOT/skills/$skill/SKILL.md" "$output/skills/$skill/SKILL.md"
  done

  chmod +x "$output/scripts/"*.sh
  printf 'Exported %s skill(s) to %s\n' "${#skills[@]}" "$output"
}

main() {
  local command="${1:-help}"
  shift || true

  case "$command" in
    list) cmd_list "$@" ;;
    list-components) cmd_list_components "$@" ;;
    list-external) cmd_list_external "$@" ;;
    install) cmd_install "$@" ;;
    install-external) cmd_install_external "$@" ;;
    export) cmd_export "$@" ;;
    help|-h|--help) usage ;;
    *)
      printf 'Unknown command: %s\n' "$command" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
