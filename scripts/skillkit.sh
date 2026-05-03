#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARK_BEGIN="<!-- BEGIN AI SKILLKIT -->"
MARK_END="<!-- END AI SKILLKIT -->"

usage() {
  cat <<'EOF'
Portable AI Skillkit

Commands:
  skillkit.sh list
  skillkit.sh list-components
  skillkit.sh install [--target PATH] [--skills all|a,b] [--agents all|a,b]
  skillkit.sh export --output PATH [--skills all|a,b]

Agents:
  all, shared, codex, claude, opencode, github, pi

Examples:
  ./scripts/install.sh --target ~/repo
  ./scripts/install.sh --target ~/repo --skills grill-me,caveman
  ./scripts/install.sh --target ~/repo --agents codex,claude
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
    printf 'Use `grill-me` only when unclear requirements would make implementation risky.\n'
    printf 'Use `caveman` when the user wants terse output or token discipline.\n'
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
    install) cmd_install "$@" ;;
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
