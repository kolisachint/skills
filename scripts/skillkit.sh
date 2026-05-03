#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT/catalog.tsv"
MARK_BEGIN="<!-- BEGIN AI SKILLKIT -->"
MARK_END="<!-- END AI SKILLKIT -->"

ALL_CATEGORIES="skill prompt command tool agent workflow"
ALL_PLATFORMS="opencode pi copilot codex claude"
ALL_SOURCES="internal external"

usage() {
  cat <<'EOF'
Portable AI Skillkit

Commands:
  skillkit.sh list                          Show all components grouped by category & source
  skillkit.sh list-categories               Show available categories
  skillkit.sh list-platforms                Show available platforms
  skillkit.sh search KEYWORD                Search components by name/description
  skillkit.sh top [N]                       Show top-N starred external components
  skillkit.sh install --target PATH         Install all components (internal + external)
  skillkit.sh install --target PATH --source internal       Install only internal components
  skillkit.sh install --target PATH --source external       Install only external components
  skillkit.sh install --target PATH --category workflow     Install only workflow components
  skillkit.sh install --target PATH --platform pi           Install only Pi-compatible components
  skillkit.sh install --target PATH --agent-target codex    Install only Codex-targeted agents/workflows
  skillkit.sh install --target PATH --skill control-first   Install a specific component by name
  skillkit.sh install --target PATH --skill skill1,skill2   Install multiple specific components
  skillkit.sh install --target PATH --scope all             Include external components (default: local only)
  skillkit.sh export --output PATH          Export portable bundle

Dimensions:
  Source:    internal, external
  Category:  skill, prompt, command, tool, agent, workflow
  Platform:  opencode, pi, copilot, codex, claude
  Agent:     all, pi, copilot, codex, claude, opencode, or specific name

Examples:
  ./scripts/skillkit.sh list
  ./scripts/skillkit.sh install --target ~/repo
  ./scripts/skillkit.sh install --target ~/repo --source internal --category workflow
  ./scripts/skillkit.sh install --target ~/repo --platform copilot --agent-target copilot
  ./scripts/skillkit.sh install --target ~/repo --category agent --platform codex
  ./scripts/skillkit.sh install --target ~/repo --skill control-first
  ./scripts/skillkit.sh install --target ~/repo --skill caveman,grill-me
  ./scripts/skillkit.sh install --target ~/repo --scope all
  ./scripts/skillkit.sh search review
  ./scripts/skillkit.sh top 5
EOF
}

# ---------------------------------------------------------------------------
# Catalog parsing
# ---------------------------------------------------------------------------

# Read catalog and output matching records
# Fields: 1=name, 2=category, 3=source, 4=platforms, 5=agent_target, 6=description, 7=install_command, 8=stars
catalog_filter() {
  local source_filter="${1:-}"
  local category_filter="${2:-}"
  local platform_filter="${3:-}"
  local agent_target_filter="${4:-}"
  local skill_filter="${5:-}"

  awk -F'\t' -v src="$source_filter" -v cat="$category_filter" -v plat="$platform_filter" -v agent="$agent_target_filter" -v skill="$skill_filter" '
    BEGIN { split(skill, skill_arr, ",") }
    /^#/ {next}
    $1=="name" {next}
    NF>=6 {
      match_src = (src=="" || $3==src)
      match_cat = (cat=="" || $2==cat)
      match_plat = (plat=="" || $4=="all" || $4==plat || $4 ~ ("(^|,)" plat "($|,)"))
      match_agent = (agent=="" || $5=="all" || $5==agent)
      match_skill = 0
      if (skill=="") {
        match_skill = 1
      } else {
        for (i in skill_arr) {
          if ($1 == skill_arr[i]) { match_skill = 1; break }
        }
      }
      if (match_src && match_cat && match_plat && match_agent && match_skill) {
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8
      }
    }
  ' "$CATALOG"
}

catalog_get_unique() {
  local field="$1"
  awk -F'\t' -v field="$field" '
    /^#/ {next}
    $1=="name" {next}
    NF>=6 { print $field }
  ' "$CATALOG" | sort -u
}

# ---------------------------------------------------------------------------
# List commands
# ---------------------------------------------------------------------------

cmd_list() {
  printf '\n📦 Portable AI Skillkit - Curated Components\n\n'

  local category
  while IFS= read -r category; do
    [[ -z "$category" ]] && continue

    local icon label
    case "$category" in
      skill)    icon='🧠'; label='Skills' ;;
      prompt)   icon='💬'; label='Prompts' ;;
      command)  icon='🎯'; label='Commands' ;;
      tool)     icon='🔧'; label='Tools' ;;
      agent)    icon='🤖'; label='Agents' ;;
      workflow) icon='⚡'; label='Workflows' ;;
      *)        icon='  '; label="$category" ;;
    esac
    printf '%s %s\n' "$icon" "$label"

    awk -F'\t' -v cat="$category" '
      /^#/ {next}
      $1=="name" {next}
      $2==cat {
        source=""
        if ($3=="internal") source=" [internal]"
        else if ($3=="external") source=" [external]"

        platforms=""
        if ($4!="all") platforms=" ["$4"]"

        agent=""
        if ($5!="all") agent=" → "$5

        stars=""
        if ($8!="" && $8!="-") stars=" ("$8"★)"

        printf "  %-20s %s%s%s%s%s\n", $1, $6, source, platforms, agent, stars
      }
    ' "$CATALOG"
    printf '\n'
  done < <(catalog_get_unique 2)

  printf 'Install everything:    ./scripts/skillkit.sh install --target ~/repo\n'
  printf 'Install by category:   ./scripts/skillkit.sh install --target ~/repo --category workflow\n'
  printf 'Install by source:     ./scripts/skillkit.sh install --target ~/repo --source internal\n'
  printf 'Install by platform:   ./scripts/skillkit.sh install --target ~/repo --platform pi\n'
  printf 'Install by agent:      ./scripts/skillkit.sh install --target ~/repo --agent-target codex\n\n'
}

cmd_list_categories() {
  printf '\nAvailable Categories:\n\n'
  local category
  while IFS= read -r category; do
    [[ -z "$category" ]] && continue
    local count
    count=$(awk -F'\t' -v cat="$category" '!/^#/ && $1!="name" && $2==cat {count++} END {print count+0}' "$CATALOG")
    local icon
    case "$category" in
      skill)    icon='🧠' ;;
      prompt)   icon='💬' ;;
      command)  icon='🎯' ;;
      tool)     icon='🔧' ;;
      agent)    icon='🤖' ;;
      workflow) icon='⚡' ;;
      *)        icon='  ' ;;
    esac
    printf '  %s %-12s (%d components)\n' "$icon" "$category" "$count"
  done < <(catalog_get_unique 2)
  printf '\n'
}

cmd_list_platforms() {
  printf '\nSupported Platforms:\n\n'
  printf '  🌐 all      - Platform-agnostic (works everywhere)\n'
  printf '  🔷 opencode - OpenCode IDE/agent\n'
  printf '  🥧 pi       - Pi Coding Agent\n'
  printf '  🐙 copilot  - GitHub Copilot\n'
  printf '  🟢 codex    - OpenAI Codex\n'
  printf '  🟣 claude   - Claude Code\n\n'

  printf 'Platform-specific components:\n\n'
  local plat
  while IFS= read -r plat; do
    [[ -z "$plat" || "$plat" == "all" ]] && continue
    local count
    count=$(awk -F'\t' -v p="$plat" '!/^#/ && $1!="name" && ($4==p || $4 ~ ("(^|,)" p "($|,)")) {count++} END {print count+0}' "$CATALOG")
    printf '  %-10s (%d components)\n' "$plat" "$count"
  done < <(catalog_get_unique 4)
  printf '\n'
}

# ---------------------------------------------------------------------------
# Search commands
# ---------------------------------------------------------------------------

cmd_search() {
  local query="${1:-}"
  if [[ -z "$query" ]]; then
    printf 'Error: search requires a KEYWORD\n' >&2
    usage >&2
    exit 1
  fi

  printf '\n🔍 Search results for: %s\n\n' "$query"

  local results
  results=$(awk -F'\t' -v q="$query" '
    /^#/ {next}
    $1=="name" {next}
    NF>=6 {
      lq = tolower(q)
      if (tolower($1) ~ lq || tolower($6) ~ lq || tolower($2) ~ lq || tolower($5) ~ lq) {
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$8
      }
    }
  ' "$CATALOG")

  if [[ -z "$results" ]]; then
    printf 'No components match "%s".\n\n' "$query"
    printf 'Try:\n'
    printf '  ./scripts/skillkit.sh list           to see all components\n'
    printf '  ./scripts/skillkit.sh top 5          to see top starred skills\n'
    printf '\n'
    return 0
  fi

  local count
  count=$(printf '%s\n' "$results" | wc -l | tr -d ' ')
  printf 'Found %d result(s):\n\n' "$count"

  printf '%s\n' "$results" | awk -F'\t' '
    NF>=6 {
      icon=""
      if ($2=="skill")    icon="🧠"
      else if ($2=="prompt")   icon="💬"
      else if ($2=="command")  icon="🎯"
      else if ($2=="tool")     icon="🔧"
      else if ($2=="agent")    icon="🤖"
      else if ($2=="workflow") icon="⚡"

      src=""
      if ($3=="internal") src=" [internal]"
      else if ($3=="external") src=" [external]"

      plat=""
      if ($4!="all") plat=" ["$4"]"

      agent=""
      if ($5!="all") agent=" → "$5

      star=""
      if ($7!="" && $7!="-") star=" ("$7"★)"

      printf "  %s %-20s %s%s%s%s%s\n", icon, $1, $6, src, plat, agent, star
    }
  '

  printf '\nInstall a result:\n'
  printf '  ./scripts/skillkit.sh install --target ~/repo --agent-target <name>\n'
  printf '  ./scripts/skillkit.sh install --target ~/repo --category <category>\n\n'
}

cmd_top() {
  local n="${1:-10}"
  if ! [[ "$n" =~ ^[0-9]+$ ]]; then
    n=10
  fi

  printf '\n⭐ Top %d Starred External Components\n\n' "$n"

  local results
  results=$(awk -F'\t' '
    /^#/ {next}
    $1=="name" {next}
    $3=="external" && $8!="" && $8!="-" {
      # Normalize stars: remove K, +, etc.
      stars = $8
      gsub(/[K+]/, "", stars)
      if (stars ~ /^[0-9]+$/) {
        # If original had K, multiply by 1000
        if ($8 ~ /K/) { stars = stars * 1000 }
        print stars"\t"$1"\t"$2"\t"$4"\t"$5"\t"$6"\t"$8
      }
    }
  ' "$CATALOG" | sort -t$'\t' -k1,1 -nr | head -n "$n")

  if [[ -z "$results" ]]; then
    printf 'No starred external components found.\n\n'
    return 0
  fi

  local rank=1
  local stars_raw name category platforms agent_target description stars_display
  while IFS=$'\t' read -r stars_raw name category platforms agent_target description stars_display; do
    local icon
    case "$category" in
      skill)    icon='🧠' ;;
      prompt)   icon='💬' ;;
      command)  icon='🎯' ;;
      tool)     icon='🔧' ;;
      agent)    icon='🤖' ;;
      workflow) icon='⚡' ;;
      *)        icon='  ' ;;
    esac

    local plat_tag=""
    [[ "$platforms" != "all" ]] && plat_tag=" [$platforms]"

    local agent_tag=""
    [[ "$agent_target" != "all" ]] && agent_tag=" → $agent_target"

    printf '  %2d. %s %-20s %s%s%s (%s★)\n' "$rank" "$icon" "$name" "$description" "$plat_tag" "$agent_tag" "$stars_display"
    rank=$((rank + 1))
  done < <(printf '%s\n' "$results")

  printf '\nInstall one:\n'
  printf '  ./scripts/skillkit.sh install --target ~/repo --agent-target <name>\n\n'
}

# ---------------------------------------------------------------------------
# Platform detection & paths
# ---------------------------------------------------------------------------

detect_platforms() {
  local target="$1"
  local detected=""

  [[ -d "$target/.pi" || -f "$target/AGENTS.md" ]] && detected="${detected:+$detected }pi"
  [[ -d "$target/.opencode" ]] && detected="${detected:+$detected }opencode"
  [[ -d "$target/.github/copilot-skills" || -f "$target/.github/copilot-instructions.md" ]] && detected="${detected:+$detected }copilot"
  [[ -d "$target/.codex" ]] && detected="${detected:+$detected }codex"
  [[ -d "$target/.claude" ]] && detected="${detected:+$detected }claude"

  printf '%s' "$detected"
}

platform_skill_dir() {
  local platform="$1"
  local target="$2"
  case "$platform" in
    pi)       printf '%s/.pi/skills' "$target" ;;
    opencode) printf '%s/.opencode/skills' "$target" ;;
    copilot)  printf '%s/.github/copilot-skills' "$target" ;;
    codex)    printf '%s/.codex/skills' "$target" ;;
    claude)   printf '%s/.claude/skills' "$target" ;;
    *)        printf '%s/.ai/skillkit/skills' "$target" ;;
  esac
}

# Return the destination path for a skill file on a given platform.
# Pi and Codex use .<platform>/skills/<name>/SKILL.md (dir per skill).
# Others use flat files: .<platform>/skills/<name>.md
platform_skill_dest() {
  local platform="$1"
  local target="$2"
  local name="$3"
  local src_file="$4"
  local plat_dir
  plat_dir=$(platform_skill_dir "$platform" "$target")
  case "$platform" in
    pi|codex)
      printf '%s/%s/%s' "$plat_dir" "$name" "$(basename "$src_file")"
      ;;
    *)
      printf '%s/%s.md' "$plat_dir" "$name"
      ;;
  esac
}

platform_agent_dir() {
  local platform="$1"
  local target="$2"
  case "$platform" in
    pi)       printf '%s/.pi/agents' "$target" ;;
    opencode) printf '%s/.opencode/agents' "$target" ;;
    copilot)  printf '%s/.github/copilot-agents' "$target" ;;
    codex)    printf '%s/.codex/agents' "$target" ;;
    claude)   printf '%s/.claude/agents' "$target" ;;
    *)        printf '' ;;
  esac
}

# Determine source file name based on category
source_file_name() {
  local category="$1"
  case "$category" in
    prompt)  printf 'PROMPT.md' ;;
    command) printf 'COMMAND.md' ;;
    *)       printf 'SKILL.md' ;;
  esac
}

# ---------------------------------------------------------------------------
# Install helpers
# ---------------------------------------------------------------------------

install_internal() {
  local target="$1"
  local name="$2"
  local category="$3"
  local platforms="$4"
  local agent_target="$5"
  local description="$6"
  local active_platforms="$7"

  local src_file
  src_file="$ROOT/skills/$name/$(source_file_name "$category")"

  if [[ ! -f "$src_file" ]]; then
    printf '  ⚠ %s: source file not found (%s)\n' "$name" "$src_file" >&2
    return 0
  fi

  # Install to shared neutral directory
  local shared_dir="$target/.ai/skillkit/$(printf '%ss' "$category")"
  mkdir -p "$shared_dir"
  cp "$src_file" "$shared_dir/$name.md"

  # Install to platform-specific directories
  local plat
  for plat in $active_platforms; do
    local plat_dest
    plat_dest=$(platform_skill_dest "$plat" "$target" "$name" "$src_file")
    if [[ -n "$plat_dest" ]]; then
      mkdir -p "$(dirname "$plat_dest")"
      cp "$src_file" "$plat_dest"
    fi

    # If this is an agent-specific workflow, also install agent configs
    if [[ "$category" == "agent" || "$category" == "workflow" ]]; then
      local agent_dir
      agent_dir=$(platform_agent_dir "$plat" "$target")
      if [[ -n "$agent_dir" ]]; then
        local config_file
        for config_file in "$ROOT/skills/$name/agent."*; do
          [[ -e "$config_file" ]] || continue
          mkdir -p "$agent_dir"
          cp "$config_file" "$agent_dir/$name.$(basename "$config_file" | sed 's/agent\.//')"
        done
      fi
    fi
  done

  printf '  ✓ %s - %s\n' "$name" "$description"
}

install_external() {
  local target="$1"
  local name="$2"
  local description="$3"
  local install_cmd="$4"

  if [[ -z "$install_cmd" || "$install_cmd" == "-" ]]; then
    printf '  ⚠ %s: no install command\n' "$name" >&2
    return 0
  fi

  printf '  → %s (%s)\n' "$name" "$description"
  printf '    Running: %s\n' "$install_cmd"
  # Run from target directory so tools like `npx skills add` create
  # project-local .agents/skills/ and platform symlinks in the right place.
  if (cd "$target" && eval "$install_cmd"); then
    printf '  ✓ %s installed\n' "$name"
  else
    printf '  ⚠ %s installation failed (non-fatal)\n' "$name" >&2
  fi
}

# ---------------------------------------------------------------------------
# Index / manifest generation
# ---------------------------------------------------------------------------

write_shared_index() {
  local target="$1"
  local components="$2"
  local shared_dir="$target/.ai/skillkit"
  local index="$shared_dir/AGENTS.md"

  mkdir -p "$shared_dir"

  {
    printf '# AI Skillkit\n\n'
    printf 'Shared instructions installed from Portable AI Skillkit.\n\n'
    printf '## Active Components\n\n'

    local category prev_cat=""
    while IFS=$'\t' read -r name category source platforms agent_target description _ _; do
      [[ -z "$name" ]] && continue
      if [[ "$category" != "$prev_cat" ]]; then
        case "$category" in
          skill)    printf '### 🧠 Skills\n' ;;
          prompt)   printf '### 💬 Prompts\n' ;;
          command)  printf '### 🎯 Commands\n' ;;
          tool)     printf '### 🔧 Tools\n' ;;
          agent)    printf '### 🤖 Agents\n' ;;
          workflow) printf '### ⚡ Workflows\n' ;;
          *)        printf '### %s\n' "$category" ;;
        esac
        prev_cat="$category"
      fi

      local tags=""
      [[ "$source" == "external" ]] && tags="${tags:+$tags }[external]"
      [[ "$platforms" != "all" ]] && tags="${tags:+$tags }[$platforms]"
      [[ "$agent_target" != "all" ]] && tags="${tags:+$tags }→ $agent_target"

      printf -- '- `%s`%s: %s\n' "$name" "${tags:+ $tags}" "$description"
    done < <(printf '%s\n' "$components" | sort -t$'\t' -k2,2 -k1,1)

    printf '\n## Usage\n\n'
    printf 'Components are organized by category and source.\n'
    printf 'For normal coding work, default to workflow components when available.\n'
    printf 'Platform-specific components are installed to their respective directories.\n'
  } > "$index"
}

update_agents_md() {
  local target="$1"
  local components="$2"
  local agents_file="$target/AGENTS.md"

  if [[ ! -f "$agents_file" ]]; then
    return 0
  fi

  local content=""
  content=$(cat "$agents_file")

  # Check if markers exist
  if [[ "$content" != *"$MARK_BEGIN"* ]]; then
    return 0
  fi

  # Extract before/after portions
  local before after
  before="${content%%$MARK_BEGIN*}"
  after="${content#*$MARK_END}"

  # Rewrite the file with updated block
  {
    printf '%s' "$before"
    printf '%s\n\n' "$MARK_BEGIN"
    printf '# AI Skillkit (auto-installed)\n\n'
    printf 'The following components are managed by Portable AI Skillkit.\n'
    printf 'Do not edit this block manually; it will be regenerated on install.\n\n'

    local category prev_cat=""
    while IFS=$'\t' read -r name category source platforms agent_target description _ _; do
      [[ -z "$name" ]] && continue
      if [[ "$category" != "$prev_cat" ]]; then
        case "$category" in
          skill)    printf '### Skills\n' ;;
          prompt)   printf '### Prompts\n' ;;
          command)  printf '### Commands\n' ;;
          tool)     printf '### Tools\n' ;;
          agent)    printf '### Agents\n' ;;
          workflow) printf '### Workflows\n' ;;
          *)        printf '### %s\n' "$category" ;;
        esac
        prev_cat="$category"
      fi
      printf -- '- `%s`: %s\n' "$name" "$description"
    done < <(printf '%s\n' "$components" | sort -t$'\t' -k2,2 -k1,1)

    printf '\n%s\n' "$MARK_END"
    printf '%s' "$after"
  } > "$agents_file"
}

write_platform_index() {
  local target="$1"
  local platform="$2"
  local components="$3"

  local index_path=""
  case "$platform" in
    pi)
      index_path="$target/.pi/AGENTS.md"
      ;;
    opencode)
      index_path="$target/.opencode/AGENTS.md"
      ;;
    copilot)
      index_path="$target/.github/copilot-instructions.md"
      ;;
    codex)
      index_path="$target/.codex/AGENTS.md"
      ;;
    claude)
      index_path="$target/.claude/AGENTS.md"
      ;;
    *)
      return 0
      ;;
  esac

  [[ -z "$index_path" ]] && return 0

  # Only write if directory exists
  local index_dir
  index_dir=$(dirname "$index_path")
  [[ -d "$index_dir" ]] || return 0

  {
    printf '# AI Skillkit - %s\n\n' "$(tr '[:lower:]' '[:upper:]' <<< "${platform:0:1}")${platform:1}"
    printf 'Platform-specific instructions installed from Portable AI Skillkit.\n\n'
    printf '## Components\n\n'

    local name category description
    while IFS=$'\t' read -r name category _ _ _ description _ _; do
      [[ -z "$name" ]] && continue
      printf -- '- \`%s\` (%s): %s\n' "$name" "$category" "$description"
    done < <(printf '%s\n' "$components" | sort -t$'\t' -k2,2 -k1,1)
  } > "$index_path"
}

# ---------------------------------------------------------------------------
# Main install command
# ---------------------------------------------------------------------------

cmd_install() {
  local target=""
  local source_filter=""
  local category_filter=""
  local platform_filter=""
  local agent_target_filter=""
  local skill_filter=""
  local scope=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      --source) source_filter="$2"; shift 2 ;;
      --category) category_filter="$2"; shift 2 ;;
      --platform) platform_filter="$2"; shift 2 ;;
      --agent-target) agent_target_filter="$2"; shift 2 ;;
      --skill) skill_filter="$2"; shift 2 ;;
      --scope) scope="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Default scope is "local" (repo-only). Use "all" to include external.
  if [[ -z "$scope" ]]; then
    scope="local"
  fi
  if [[ "$scope" == "local" ]]; then
    source_filter="internal"
  fi

  if [[ -z "$target" ]]; then
    printf 'Error: --target is required\n' >&2
    usage >&2
    exit 1
  fi

  mkdir -p "$target"
  target="$(cd "$target" && pwd)"

  printf 'Installing Portable AI Skillkit to %s\n' "$target"

  # Determine active platforms
  local active_platforms=""
  if [[ -n "$platform_filter" && "$platform_filter" != "all" ]]; then
    active_platforms="$platform_filter"
  else
    active_platforms=$(detect_platforms "$target")
  fi

  if [[ -n "$active_platforms" ]]; then
    printf 'Target platforms: %s\n' "$active_platforms"
  else
    printf 'No platform directories detected. Installing to shared .ai/skillkit/ only.\n'
    printf 'Use --platform <name> to force platform-specific installation.\n'
  fi

  # Get filtered components
  local components
  components=$(catalog_filter "$source_filter" "$category_filter" "$platform_filter" "$agent_target_filter" "$skill_filter")

  if [[ -z "$components" ]]; then
    printf 'No components match the filter (source=%s, category=%s, platform=%s, agent=%s, skill=%s)\n' \
      "$source_filter" "$category_filter" "$platform_filter" "$agent_target_filter" "$skill_filter"
    exit 0
  fi

  # Count summary
  local internal_count external_count
  internal_count=$(printf '%s\n' "$components" | awk -F'\t' '$3=="internal" {count++} END {print count+0}')
  external_count=$(printf '%s\n' "$components" | awk -F'\t' '$3=="external" {count++} END {print count+0}')

  printf '  Internal: %d\n' "$internal_count"
  printf '  External: %d\n\n' "$external_count"

  # Install internal components
  if [[ "$internal_count" -gt 0 ]]; then
    printf '→ Installing internal components...\n'
    local name category source platforms agent_target description
    while IFS=$'\t' read -r name category source platforms agent_target description _ _; do
      [[ -z "$name" ]] && continue
      install_internal "$target" "$name" "$category" "$platforms" "$agent_target" "$description" "$active_platforms"
    done < <(printf '%s\n' "$components" | awk -F'\t' '$3=="internal"')
  fi

  # Install external components
  if [[ "$external_count" -gt 0 ]]; then
    printf '\n→ Installing external components...\n'
    local name description install_cmd
    while IFS=$'\t' read -r name _ _ _ _ description install_cmd _; do
      [[ -z "$name" ]] && continue
      install_external "$target" "$name" "$description" "$install_cmd"
    done < <(printf '%s\n' "$components" | awk -F'\t' '$3=="external"')
  fi

  # Generate indices
  write_shared_index "$target" "$components"
  update_agents_md "$target" "$components"

  local plat
  for plat in $active_platforms; do
    write_platform_index "$target" "$plat" "$components"
  done

  printf '\n✓ Installation complete\n'
  printf '  Shared index:      %s/.ai/skillkit/AGENTS.md\n' "$target"
  if [[ -n "$active_platforms" ]]; then
    printf '  Platform dirs:     installed to detected platform directories\n'
  fi
}

# ---------------------------------------------------------------------------
# Export command
# ---------------------------------------------------------------------------

cmd_export() {
  local output=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output) output="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  if [[ -z "$output" ]]; then
    printf 'Error: --output is required\n' >&2
    usage >&2
    exit 1
  fi

  mkdir -p "$output"

  printf 'Exporting Portable AI Skillkit to %s\n' "$output"

  cp "$CATALOG" "$output/catalog.tsv"

  if [[ -d "$ROOT/skills" ]]; then
    cp -r "$ROOT/skills" "$output/"
  fi

  mkdir -p "$output/scripts"
  cp "$ROOT/scripts/skillkit.sh" "$output/scripts/"
  cp "$ROOT/scripts/skillkit.ps1" "$output/scripts/"

  for doc in README.md AGENTS.md PHILOSOPHY.md MIGRATION.md; do
    if [[ -f "$ROOT/$doc" ]]; then
      cp "$ROOT/$doc" "$output/"
    fi
  done

  printf '✓ Exported to %s\n' "$output"
}

# ---------------------------------------------------------------------------
# Main dispatcher
# ---------------------------------------------------------------------------

case "${1:-}" in
  list)
    shift
    cmd_list "$@"
    ;;
  list-categories)
    shift
    cmd_list_categories "$@"
    ;;
  list-platforms)
    shift
    cmd_list_platforms "$@"
    ;;
  search)
    shift
    cmd_search "$@"
    ;;
  top)
    shift
    cmd_top "$@"
    ;;
  install)
    shift
    cmd_install "$@"
    ;;
  export)
    shift
    cmd_export "$@"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
