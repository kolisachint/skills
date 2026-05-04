#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="$ROOT/catalog.tsv"

ALL_CATEGORIES="skill prompt command tool agent workflow"
ALL_PLATFORMS="opencode pi copilot codex claude"

usage() {
  cat <<'EOF'
Portable AI Skillkit — Curated catalog thin wrapper around npx skills

Commands:
  install.sh list                          Show all components grouped by category
  install.sh list-categories               Show available categories
  install.sh list-platforms                Show available platforms
  install.sh search KEYWORD                Search components by name/description
  install.sh top [N]                       Show top-N starred components
  install.sh --target PATH         Install all catalog components
  install.sh --target PATH --skill NAME          Install specific component(s)
  install.sh --category CATEGORY     Install by category (target defaults to .)
  install.sh --platform PLATFORM     Install by platform (target defaults to .)
  install.sh --agent-target AGENT    Install by agent target (target defaults to .)
  install.sh --from FILE             Install from favorites file (target defaults to .)
  install.sh --from FILE --tag TAG   Install favorites matching tags
  install.sh export --output PATH    Export portable bundle

  install.sh SKILL                   Install one skill to current directory
  install.sh SKILL1 SKILL2 ...       Install multiple skills to current directory

  install.sh remove SKILL            Remove installed skill(s)
  install.sh remove SKILL1 SKILL2 ... Remove multiple skills
  install.sh installed               List installed skills in target directory
  install.sh update [SKILL]          Update installed skills (all if no skill given)

Examples:
  ./install.sh caveman                        # one-liner: install skill to .
  ./install.sh caveman grill-me               # install multiple skills to .
  ./install.sh list
  ./install.sh search review
  ./install.sh --target ~/repo --skill caveman
  ./install.sh --target ~/repo --skill caveman,grill-me
  ./install.sh --target ~/repo --from favorites.tsv --tag daily-driver
  ./install.sh --target ~/repo --category workflow

  ./install.sh remove caveman                 # remove a skill
  ./install.sh remove caveman grill-me        # remove multiple skills
  ./install.sh remove --all                   # remove ALL installed skills
  ./install.sh installed                      # list installed skills
  ./install.sh update                         # update all skills
  ./install.sh update caveman                 # update a specific skill
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

normalize_skill_filter() {
  local input="$1"
  # Replace commas with spaces, collapse multiple spaces, trim, replace spaces with commas
  echo "$input" | tr ',' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//' | tr ' ' ','
}

# ---------------------------------------------------------------------------
# Catalog parsing
# ---------------------------------------------------------------------------

catalog_filter() {
  local category_filter="${1:-}"
  local platform_filter="${2:-}"
  local agent_target_filter="${3:-}"
  local skill_filter="${4:-}"

  awk -F'\t' -v cat="$category_filter" -v plat="$platform_filter" -v agent="$agent_target_filter" -v skill="$skill_filter" '
    BEGIN { split(skill, skill_arr, ",") }
    /^#/ {next}
    $1=="name" {next}
    NF>=6 {
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
      if (match_cat && match_plat && match_agent && match_skill) {
        print $1"\t"$2"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8
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
        platforms=""
        if ($4!="all") platforms=" ["$4"]"
        agent=""
        if ($5!="all") agent=" → "$5
        stars=""
        if ($8!="" && $8!="-") stars=" ("$8"★)"
        printf "  %-20s %s%s%s%s\n", $1, $6, platforms, agent, stars
      }
    ' "$CATALOG"
    printf '\n'
  done < <(catalog_get_unique 2)

  printf 'Install one:     ./install.sh <skill-name>\n'
  printf 'Install by cat:  ./install.sh --category <cat>\n'
  printf 'Install all:     ./install.sh --target ~/repo\n\n'
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
        print $1"\t"$2"\t"$4"\t"$5"\t"$6"\t"$8
      }
    }
  ' "$CATALOG")

  if [[ -z "$results" ]]; then
    printf 'No components match "%s".\n\n' "$query"
    printf 'Try:\n'
    printf '  ./install.sh list    to see all components\n'
    printf '  ./install.sh top 5   to see top starred skills\n\n'
    return 0
  fi

  local count
  count=$(printf '%s\n' "$results" | wc -l | tr -d ' ')
  printf 'Found %d result(s):\n\n' "$count"

  printf '%s\n' "$results" | awk -F'\t' '
    NF>=5 {
      icon=""
      if ($2=="skill")    icon="🧠"
      else if ($2=="prompt")   icon="💬"
      else if ($2=="command")  icon="🎯"
      else if ($2=="tool")     icon="🔧"
      else if ($2=="agent")    icon="🤖"
      else if ($2=="workflow") icon="⚡"

      plat=""
      if ($3!="all") plat=" ["$3"]"
      agent=""
      if ($4!="all") agent=" → "$4
      star=""
      if ($6!="" && $6!="-") star=" ("$6"★)"

      printf "  %s %-20s %s%s%s%s\n", icon, $1, $5, plat, agent, star
    }
  '

  printf '\nInstall: ./install.sh <skill-name>\n\n'
}

cmd_top() {
  local n="${1:-10}"
  if ! [[ "$n" =~ ^[0-9]+$ ]]; then
    n=10
  fi

  printf '\n⭐ Top %d Starred Components\n\n' "$n"

  local results
  results=$(awk -F'\t' '
    /^#/ {next}
    $1=="name" {next}
    $8!="" && $8!="-" {
      stars = $8
      gsub(/[K+]/, "", stars)
      if (stars ~ /^[0-9]+$/) {
        if ($8 ~ /K/) { stars = stars * 1000 }
        print stars"\t"$1"\t"$2"\t"$4"\t"$5"\t"$6"\t"$8
      }
    }
  ' "$CATALOG" | sort -t$'\t' -k1,1 -nr | head -n "$n")

  if [[ -z "$results" ]]; then
    printf 'No starred components found.\n\n'
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

  printf '\n'
}

# ---------------------------------------------------------------------------
# Favorites resolution
# ---------------------------------------------------------------------------

resolve_favorites_names() {
  local file="$1"
  local tag_filter="${2:-}"

  awk -F'\t' -v tags="$tag_filter" '
    BEGIN { split(tags, tag_arr, ",") }
    /^#/ {next}
    $1=="name" {next}
    NF>=5 {
      match_tag = 0
      if (tags=="") {
        match_tag = 1
      } else {
        for (i in tag_arr) {
          if ($4 ~ ("(^|,)" tag_arr[i] "($|,)")) { match_tag = 1; break }
        }
      }
      if (match_tag) { print $1 }
    }
  ' "$file"
}

# ---------------------------------------------------------------------------
# Platform-specific command transformation
# ---------------------------------------------------------------------------

# Transform install commands based on target platform
# Each platform has different conventions for installing skills
transform_command_for_platform() {
  local cmd="$1"
  local platform="${2:-}"

  # No platform specified - return command as-is
  [[ -z "$platform" ]] && echo "$cmd" && return

  case "$platform" in
    opencode)
      # OpenCode requires -a opencode flag for npx skills
      if [[ "$cmd" == "npx skills add"* ]]; then
        # Add -a opencode -g -y flags if not present
        if [[ "$cmd" != *"-a opencode"* ]]; then
          cmd="${cmd} -a opencode"
        fi
        if [[ "$cmd" != *"-g"* ]]; then
          cmd="${cmd} -g"
        fi
        if [[ "$cmd" != *"-y"* && "$cmd" != *"--yes"* ]]; then
          cmd="${cmd} -y"
        fi
      fi
      ;;

    pi)
      # Pi uses pi install for npm packages with pi-extension
      if [[ "$cmd" == "npm install"* ]]; then
        local pkg="${cmd#npm install }"
        # Trim leading/trailing whitespace
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        if [[ "$pkg" == *"pi-extension"* ]]; then
          cmd="pi install npm:${pkg}"
        fi
      fi
      # Pi can also install from GitHub repos
      if [[ "$cmd" == "npx skills add"* ]]; then
        # Extract repo from npx skills add command
        local repo="${cmd#npx skills add }"
        repo="${repo%% *}"  # Get first argument
        if [[ "$repo" == */* && "$repo" != *" --"* && "$repo" != *" -"* ]]; then
          # Looks like owner/repo format - convert to pi install
          cmd="pi install https://github.com/${repo}"
        fi
      fi
      ;;

    codex)
      # Codex uses: codex skills add <skill-name>
      # or creates skills in .codex/skills/ directory
      if [[ "$cmd" == "npx skills add"* ]]; then
        local repo="${cmd#npx skills add }"
        repo="${repo%% *}"
        # Extract skill name from repo (last part after /)
        local skill_name="${repo##*/}"
        cmd="codex skills add ${skill_name}"
      fi
      ;;

    copilot)
      # Copilot CLI uses: gh copilot -- plugin install <source>
      # or just: copilot -- plugin install <source>
      if [[ "$cmd" == "npx skills add"* ]]; then
        local repo="${cmd#npx skills add }"
        repo="${repo%% *}"  # Get first argument
        # Check which copilot command is available
        if command -v copilot &> /dev/null; then
          cmd="copilot -- plugin install $repo"
        else
          cmd="gh copilot -- plugin install $repo"
        fi
      fi
      ;;

    claude)
      # Claude Code uses npx skills with default behavior
      # No transformation needed - works as-is
      ;;
  esac

  echo "$cmd"
}

# ---------------------------------------------------------------------------
# Install — thin wrapper around npx skills / npm install
# ---------------------------------------------------------------------------

cmd_install() {
  local target=""
  local category_filter=""
  local platform_filter=""
  local agent_target_filter=""
  local skill_filter=""
  local from_file=""
  local tag_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      --category) category_filter="$2"; shift 2 ;;
      --platform) platform_filter="$2"; shift 2 ;;
      --agent-target) agent_target_filter="$2"; shift 2 ;;
      --skill) skill_filter="$2"; shift 2 ;;
      --from) from_file="$2"; shift 2 ;;
      --tag) tag_filter="$2"; shift 2 ;;
      -*)
        printf 'Error: unknown flag %s\n' "$1" >&2
        printf 'Did you mean --skill? Use --skill <name> to install a specific component.\n' >&2
        usage >&2
        exit 1
        ;;
      *)
        printf 'Error: unexpected argument %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  skill_filter=$(normalize_skill_filter "$skill_filter")

  if [[ -n "$tag_filter" && -z "$from_file" ]]; then
    printf 'Error: --tag requires --from <favorites-file>\n' >&2
    usage >&2
    exit 1
  fi

  if [[ -z "$target" ]]; then
    target="."
  fi

  mkdir -p "$target"
  target="$(cd "$target" && pwd)"

  printf 'Installing Portable AI Skillkit to %s\n' "$target"

  # Resolve favorites to catalog entries
  if [[ -n "$from_file" ]]; then
    if [[ ! -f "$from_file" ]]; then
      printf 'Error: favorites file not found: %s\n' "$from_file" >&2
      exit 1
    fi

    local fav_names
    fav_names=$(resolve_favorites_names "$from_file" "$tag_filter")

    if [[ -z "$fav_names" ]]; then
      printf 'No favorites match the tag filter: %s\n' "${tag_filter:-(none)}"
      exit 0
    fi

    local valid_names=""
    while IFS= read -r name; do
      [[ -z "$name" ]] && continue
      if awk -F'\t' -v n="$name" 'BEGIN{found=0} !/^#/ && $1=="name"{next} $1==n{found=1; exit} END{exit (found ? 0 : 1)}' "$CATALOG"; then
        valid_names="${valid_names:+$valid_names,}$name"
      else
        printf '  ⚠ %s: not found in catalog, skipping\n' "$name" >&2
      fi
    done < <(printf '%s\n' "$fav_names")

    if [[ -z "$valid_names" ]]; then
      printf 'No valid favorites found in catalog.\n'
      exit 0
    fi

    skill_filter="$valid_names"
  fi

  # Get filtered components
  local components
  components=$(catalog_filter "$category_filter" "$platform_filter" "$agent_target_filter" "$skill_filter")

  if [[ -z "$components" ]]; then
    printf 'No components match the filter (category=%s, platform=%s, agent=%s, skill=%s)\n' \
      "$category_filter" "$platform_filter" "$agent_target_filter" "$skill_filter"
    exit 0
  fi

  local count
  count=$(printf '%s\n' "$components" | wc -l | tr -d ' ')
  printf '  Components to install: %d\n\n' "$count"

  # Install each component by running its install_command from the catalog
  local name description install_cmd
  while IFS=$'\t' read -r name _ _ _ description install_cmd _; do
    [[ -z "$name" ]] && continue

    if [[ -z "$install_cmd" || "$install_cmd" == "-" ]]; then
      printf '  ⚠ %s: no install command\n' "$name" >&2
      continue
    fi

    # Transform command based on platform
    local cmd=$(transform_command_for_platform "$install_cmd" "$platform_filter")

    # Handle unsupported platforms
    if [[ "$cmd" == UNSUPPORTED:* ]]; then
      printf '  → %s (%s)\n' "$name" "$description"
      printf '  ⚠ %s\n\n' "${cmd#UNSUPPORTED: }" >&2
      continue
    fi

    # Skip empty commands
    [[ -z "$cmd" ]] && continue

    printf '  → %s (%s)\n' "$name" "$description"
    printf '    %s\n' "$cmd"

    if (cd "$target" && eval "$cmd" < /dev/null); then
      printf '  ✓ %s installed\n\n' "$name"
    else
      printf '  ⚠ %s installation failed (non-fatal)\n\n' "$name" >&2
    fi
  done < <(printf '%s\n' "$components")

  printf '✓ Installation complete\n'
  case "$platform_filter" in
    opencode)
      printf '  Skills installed to .opencode/skills/\n' ;;
    pi)
      printf '  Skills installed to .pi/skills/\n' ;;
    codex)
      printf '  Skills installed to .codex/skills/\n' ;;
    copilot)
      printf '  Skills installed via gh copilot -- plugin install\n' ;;
    claude)
      printf '  Skills installed to .claude/skills/\n' ;;
    *)
      printf '  npx skills manages .agents/skills/ and platform symlinks automatically.\n' ;;
  esac
}

# ---------------------------------------------------------------------------
# Remove command - local and global
# ---------------------------------------------------------------------------

# Global skill directories to check/remove from
declare -a GLOBAL_SKILL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.claude/commands"
  "$HOME/.pi/skills"
  "$HOME/.opencode/skills"
  "$HOME/.opencode/command"
  "$HOME/.config/opencode/skills"
  "$HOME/.config/opencode/command"
  "$HOME/.codex/skills"
  "$HOME/.gemini/commands"
  "$HOME/.github/copilot/skills"
)

# Remove skill from global directories
remove_global_skill() {
  local skill_name="$1"
  local removed=1  # 1 = false, 0 = true

  for dir in "${GLOBAL_SKILL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      # Find matching items and process without subshell
      while IFS= read -r -d '' item; do
        local basename_item
        basename_item=$(basename "$item")
        if [[ "$basename_item" =~ ^${skill_name}$ ]] || [[ "$basename_item" =~ ^${skill_name}- ]]; then
          rm -rf "$item"
          printf '    ✓ Removed from %s: %s\n' "$dir" "$basename_item"
          removed=0
        fi
      done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
    fi
  done

  return $removed
}

# Remove npm global package
remove_npm_global() {
  local pkg_pattern="$1"
  
  # Check if it's an npm package (starts with @ or looks like a package name)
  if [[ "$pkg_pattern" == @* ]] || [[ "$pkg_pattern" == *"-"* ]] || [[ "$pkg_pattern" == *"_"* ]]; then
    # Try to find matching npm global packages
    local npm_pkgs
    npm_pkgs=$(npm list -g --depth=0 2>/dev/null | grep -E "^├─|^└─|^├──|^└──" | sed 's/^[├└─│ ]*//' | grep -i "$pkg_pattern" | sed 's/@[^@]*$//' || true)
    
    if [[ -n "$npm_pkgs" ]]; then
      echo "$npm_pkgs" | while read pkg; do
        if [[ -n "$pkg" ]]; then
          npm uninstall -g "$pkg" 2>/dev/null && printf '    ✓ Removed npm global: %s\n' "$pkg" || true
        fi
      done
      return 0
    fi
  fi
  return 1
}

cmd_remove() {
  local target=""
  local skill_filter=""
  local remove_all=""
  local platform_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      --skill) skill_filter="$2"; shift 2 ;;
      --platform) platform_filter="$2"; shift 2 ;;
      --all) remove_all=1; shift ;;
      -*)
        printf 'Error: unknown flag %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
      *)
        if [[ -z "$skill_filter" ]]; then
          skill_filter="$1"
        else
          skill_filter="$skill_filter,$1"
        fi
        shift ;;
    esac
  done

  skill_filter=$(normalize_skill_filter "$skill_filter")

  if [[ -z "$target" ]]; then
    target="."
  fi

  mkdir -p "$target"
  target="$(cd "$target" && pwd)"

  # --all: nuke everything via npx skills
  if [[ -n "$remove_all" ]]; then
    printf 'Removing ALL skills from %s\n' "$target"
    if (cd "$target" && npx skills remove --all --yes < /dev/null); then
      printf '✓ All local skills removed\n'
    else
      printf '  ⚠ bulk local removal failed (non-fatal)\n' >&2
    fi
    
    # Also remove from global directories
    printf 'Removing global skills...\n'
    for dir in "${GLOBAL_SKILL_DIRS[@]}"; do
      if [[ -d "$dir" ]]; then
        rm -rf "$dir"/*
        printf '  ✓ Cleared %s\n' "$dir"
      fi
    done
    return
  fi

  if [[ -z "$skill_filter" ]]; then
    printf 'Error: remove requires a SKILL name (or --all)\n' >&2
    usage >&2
    exit 1
  fi

  printf 'Removing skills from %s\n' "$target"

  local IFS=','
  for name in $skill_filter; do
    [[ -z "$name" ]] && continue

    printf '\n→ %s\n' "$name"
    
    # 1. Remove from local target directory
    local remove_cmd=""
    remove_cmd=$(awk -F'\t' -v n="$name" '$1==n && NF>=9 && $9!="" && $9!="-" {print $9; exit}' "$CATALOG")

    # Derive from install command if no explicit remove command
    if [[ -z "$remove_cmd" ]]; then
      local install_cmd
      install_cmd=$(awk -F'\t' -v n="$name" '$1==n {print $7; exit}' "$CATALOG")
      if [[ "$install_cmd" == "npx skills add"* ]]; then
        remove_cmd="npx skills remove $name --yes"
      elif [[ "$install_cmd" == "npm install -g"* ]]; then
        local pkg="${install_cmd#npm install -g }"
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        remove_cmd="npm uninstall -g $pkg"
      elif [[ "$install_cmd" == "npm install "* ]]; then
        local pkg="${install_cmd#npm install }"
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        remove_cmd="npm uninstall $pkg"
      elif [[ "$install_cmd" == "pi install npm:"* ]]; then
        local pkg="${install_cmd#pi install }"
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        remove_cmd="pi remove $pkg"
      fi
    fi

    # Check if we're targeting Copilot platform
    if [[ "$platform_filter" == "copilot" ]]; then
      if command -v copilot &> /dev/null; then
        remove_cmd="copilot -- plugin uninstall $name"
      else
        remove_cmd="gh copilot -- plugin uninstall $name"
      fi
    fi

    # Fallback: try npx skills remove for anything not in catalog
    if [[ -z "$remove_cmd" ]]; then
      remove_cmd="npx skills remove $name --yes"
    fi

    # Execute local removal
    printf '  Local: %s\n' "$remove_cmd"
    if (cd "$target" && eval "$remove_cmd" < /dev/null 2>&1); then
      printf '    ✓ Removed from local project\n'
    else
      printf '    ℹ Not found in local project (or already removed)\n'
    fi

    # 2. Remove from global directories
    printf '  Global directories...\n'
    if remove_global_skill "$name"; then
      : # Items were removed (output already printed)
    else
      printf '    ℹ Not found in global directories\n'
    fi

    # 3. Also try npm global removal for matching packages
    printf '  NPM global packages...\n'
    if remove_npm_global "$name"; then
      : # Packages were removed (output already printed)
    else
      printf '    ℹ No matching npm global packages\n'
    fi
  done

  printf '\n✓ Removal complete\n'
}

# ---------------------------------------------------------------------------
# Installed command
# ---------------------------------------------------------------------------

cmd_installed() {
  local target="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  mkdir -p "$target"
  target="$(cd "$target" && pwd)"

  printf 'Installed skills in %s:\n\n' "$target"
  (cd "$target" && npx skills list) || printf '  (no skills found or npx skills not available)\n'
}

# ---------------------------------------------------------------------------
# Update command
# ---------------------------------------------------------------------------

cmd_update() {
  local target=""
  local skill_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      --skill) skill_filter="$2"; shift 2 ;;
      -*)
        printf 'Error: unknown flag %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
      *)
        if [[ -z "$skill_filter" ]]; then
          skill_filter="$1"
        else
          skill_filter="$skill_filter,$1"
        fi
        shift ;;
    esac
  done

  skill_filter=$(normalize_skill_filter "$skill_filter")

  if [[ -z "$target" ]]; then
    target="."
  fi

  mkdir -p "$target"
  target="$(cd "$target" && pwd)"

  printf 'Updating skills in %s\n' "$target"

  local cmd="npx skills update"
  if [[ -n "$skill_filter" ]]; then
    local skills="${skill_filter//,/ }"
    cmd="$cmd $skills"
  fi

  if (cd "$target" && eval "$cmd"); then
    printf '✓ Update complete\n'
  else
    printf '  ⚠ update failed (non-fatal)\n' >&2
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
  cp "$ROOT/install.sh" "$output/"
  cp "$ROOT/install.ps1" "$output/"

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

KNOWN_COMMANDS="list list-categories list-platforms search top install export remove installed update"

# If first argument is a flag (starts with --), default to install command
if [[ "${1:-}" == --* ]]; then
  set -- install "$@"
# If first argument is not a known command, treat remaining positional args as skill names
elif [[ -n "${1:-}" ]] && ! echo "$KNOWN_COMMANDS" | grep -qw "$1"; then
  skills="$1"
  shift
  while [[ $# -gt 0 ]] && [[ "$1" != --* ]]; do
    skills="$skills,$1"
    shift
  done
  set -- install --skill "$skills" "$@"
fi

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
  remove)
    shift
    cmd_remove "$@"
    ;;
  installed)
    shift
    cmd_installed "$@"
    ;;
  update)
    shift
    cmd_update "$@"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
