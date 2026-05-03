#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT/catalog.tsv"
MARK_BEGIN="<!-- BEGIN AI SKILLKIT -->"
MARK_END="<!-- END AI SKILLKIT -->"

usage() {
  cat <<'EOF'
Portable AI Skillkit

Commands:
  skillkit.sh list                          Show all components grouped by category
  skillkit.sh list-categories               Show available categories
  skillkit.sh install --target PATH         Install all components (bundled + external)
  skillkit.sh install --target PATH --source bundled     Install only bundled components
  skillkit.sh install --target PATH --source external    Install only external components
  skillkit.sh install --target PATH --category workflow  Install only workflow components
  skillkit.sh export --output PATH          Export portable bundle

Categories:
  workflow, command, tool, agent

Examples:
  ./scripts/skillkit.sh list
  ./scripts/skillkit.sh install --target ~/repo
  ./scripts/skillkit.sh install --target ~/repo --source bundled
  ./scripts/skillkit.sh install --target ~/repo --category workflow
  ./scripts/skillkit.sh export --output ./dist
EOF
}

# Parse catalog.tsv and output fields
# Usage: catalog_get <field_number> [filter_conditions]
# Fields: 1=name, 2=category, 3=source, 4=description, 5=install_command, 6=stars
catalog_get() {
  local field="$1"
  shift
  awk -F'\t' -v field="$field" '
    /^#/ {next}
    $1=="name" {next}
    NF>=4 { print $field }
  ' "$CATALOG" | sort -u
}

# Get all unique categories
catalog_categories() {
  catalog_get 2
}

# List components grouped by category
cmd_list() {
  printf '\n📦 Portable AI Skillkit - Curated Components\n\n'
  
  local category
  while IFS= read -r category; do
    [[ -z "$category" ]] && continue
    
    case "$category" in
      workflow) printf '⚡ Workflows (how you structure work)\n' ;;
      command)  printf '🎯 Commands (interactive modes)\n' ;;
      tool)     printf '🔧 Tools (monitoring & analysis)\n' ;;
      agent)    printf '🤖 Agents (execution harnesses)\n' ;;
      *)        printf '%s\n' "$category" ;;
    esac
    
    awk -F'\t' -v cat="$category" '
      /^#/ {next}
      $1=="name" {next}
      $2==cat {
        source=""
        if ($3=="bundled") source=" [bundled]"
        else if ($3=="external") source=" [external]"
        
        stars=""
        if ($6!="" && $6!="-") stars=" ("$6"★)"
        
        printf "  %-20s %s%s%s\n", $1, $4, source, stars
      }
    ' "$CATALOG"
    printf '\n'
  done < <(catalog_categories)
  
  printf 'Install everything: ./scripts/skillkit.sh install --target ~/repo\n'
  printf 'Install by category: ./scripts/skillkit.sh install --target ~/repo --category workflow\n'
  printf 'Install by source:   ./scripts/skillkit.sh install --target ~/repo --source bundled\n\n'
}

# List categories only
cmd_list_categories() {
  printf '\nAvailable Categories:\n\n'
  local category
  while IFS= read -r category; do
    [[ -z "$category" ]] && continue
    local count
    count=$(awk -F'\t' -v cat="$category" '!/^#/ && $1!="name" && $2==cat {count++} END {print count+0}' "$CATALOG")
    printf '  %-12s (%d components)\n' "$category" "$count"
  done < <(catalog_categories)
  printf '\n'
}

# Get filtered components from catalog
# Usage: catalog_filter [--source bundled|external] [--category cat]
catalog_filter() {
  local source_filter=""
  local category_filter=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source) source_filter="$2"; shift 2 ;;
      --category) category_filter="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  
  awk -F'\t' -v src="$source_filter" -v cat="$category_filter" '
    /^#/ {next}
    $1=="name" {next}
    (src=="" || $3==src) && (cat=="" || $2==cat) {
      print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6
    }
  ' "$CATALOG"
}

# Install components
cmd_install() {
  local target=""
  local source_filter=""
  local category_filter=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target="$2"; shift 2 ;;
      --source) source_filter="$2"; shift 2 ;;
      --category) category_filter="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  
  if [[ -z "$target" ]]; then
    printf 'Error: --target is required\n' >&2
    usage >&2
    exit 1
  fi
  
  target="$(cd "$target" && pwd)"
  mkdir -p "$target"
  
  printf 'Installing Portable AI Skillkit to %s\n' "$target"
  
  # Get filtered components
  local components
  components=$(catalog_filter --source "$source_filter" --category "$category_filter")
  
  if [[ -z "$components" ]]; then
    printf 'No components match the filter (source=%s, category=%s)\n' "$source_filter" "$category_filter"
    exit 0
  fi
  
  # Count what we're installing
  local bundled_count external_count
  bundled_count=$(printf '%s\n' "$components" | awk -F'\t' '$3=="bundled" {count++} END {print count+0}')
  external_count=$(printf '%s\n' "$components" | awk -F'\t' '$3=="external" {count++} END {print count+0}')
  
  printf '  Bundled: %d\n' "$bundled_count"
  printf '  External: %d\n\n' "$external_count"
  
  # Install bundled components (copy skill files)
  if [[ "$bundled_count" -gt 0 ]]; then
    printf '→ Installing bundled components...\n'
    local name category description
    while IFS=$'\t' read -r name category _ description _ _; do
      [[ -z "$name" ]] && continue
      if [[ -f "$ROOT/skills/$name/SKILL.md" ]]; then
        mkdir -p "$target/.ai/skillkit/skills"
        cp "$ROOT/skills/$name/SKILL.md" "$target/.ai/skillkit/skills/$name.md"
        printf '  ✓ %s - %s\n' "$name" "$description"
      fi
    done < <(printf '%s\n' "$components" | awk -F'\t' '$3=="bundled"')
  fi
  
  # Install external components (run install commands)
  if [[ "$external_count" -gt 0 ]]; then
    printf '\n→ Installing external components...\n'
    local name category description install_cmd
    while IFS=$'\t' read -r name category _ description install_cmd _; do
      [[ -z "$name" ]] && continue
      if [[ -n "$install_cmd" && "$install_cmd" != "-" ]]; then
        printf '  → %s (%s)\n' "$name" "$description"
        printf '    Running: %s\n' "$install_cmd"
        if eval "$install_cmd"; then
          printf '  ✓ %s installed\n' "$name"
        else
          printf '  ⚠ %s installation failed (non-fatal)\n' "$name" >&2
        fi
      fi
    done < <(printf '%s\n' "$components" | awk -F'\t' '$3=="external"')
  fi
  
  # Create shared index
  write_shared_index "$target" "$components"
  
  printf '\n✓ Installation complete\n'
  printf '  Skills installed in: %s/.ai/skillkit/\n' "$target"
}

# Write shared AGENTS.md index
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
    while IFS=$'\t' read -r name category source description _ _; do
      [[ -z "$name" ]] && continue
      if [[ "$category" != "$prev_cat" ]]; then
        case "$category" in
          workflow) printf '### ⚡ Workflows\n' ;;
          command)  printf '### 🎯 Commands\n' ;;
          tool)     printf '### 🔧 Tools\n' ;;
          agent)    printf '### 🤖 Agents\n' ;;
          *)        printf '### %s\n' "$category" ;;
        esac
        prev_cat="$category"
      fi
      
      local src_tag=""
      [[ "$source" == "external" ]] && src_tag=" [external]"
      printf -- '- `%s`%s: %s\n' "$name" "$src_tag" "$description"
    done < <(printf '%s\n' "$components" | sort -t$'\t' -k2,2 -k1,1)
    
    printf '\n## Usage\n\n'
    printf 'Components are organized by category.\n'
    printf 'For normal coding work, default to workflow components when available.\n'
  } > "$index"
}

# Export portable bundle
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
  
  # Copy catalog and skills
  cp "$CATALOG" "$output/catalog.tsv"
  
  if [[ -d "$ROOT/skills" ]]; then
    cp -r "$ROOT/skills" "$output/"
  fi
  
  # Copy scripts
  mkdir -p "$output/scripts"
  cp "$ROOT/scripts/skillkit.sh" "$output/scripts/"
  cp "$ROOT/scripts/skillkit.ps1" "$output/scripts/"
  
  # Copy docs
  for doc in README.md AGENTS.md PHILOSOPHY.md MIGRATION.md; do
    if [[ -f "$ROOT/$doc" ]]; then
      cp "$ROOT/$doc" "$output/"
    fi
  done
  
  printf '✓ Exported to %s\n' "$output"
}

# Main command dispatcher
case "${1:-}" in
  list)
    shift
    cmd_list "$@"
    ;;
  list-categories)
    shift
    cmd_list_categories "$@"
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
