#!/usr/bin/env bash
# List user-installed skills across all agent platforms (hides system packages)

set -euo pipefail

# Patterns to exclude (system/critical packages)
EXCLUDE_PATTERNS="^\.|runtime|system|corepack|^npm$|^@mariozechner/pi-coding-agent$|^@openai/codex$"

# Parse arguments
FORMAT="default"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--format default|readme]"
      echo ""
      echo "Options:"
      echo "  --format default    Standard output (default)"
      echo "  --format readme     Markdown table format for README"
      echo "  --help, -h          Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage"
      exit 1
      ;;
  esac
done

# Collect all skills into arrays
declare -a ALL_SKILLS=()
declare -a ALL_PLATFORMS=()
declare -a ALL_CATEGORIES=()

collect_skills() {
  local platform="$1"
  local dir="$2"
  local category="${3:-skill}"
  
  if [ -d "$dir" ]; then
    find "$dir" -maxdepth 1 -mindepth 1 -exec basename {} \; 2>/dev/null | grep -v -E "$EXCLUDE_PATTERNS" | while read skill; do
      echo "$skill|$platform|$category"
    done
  fi
}

# Collect from all locations
{
  # Local directories
  for agent_dir in .agents .claude .pi .opencode .codex .github/copilot; do
    skills_dir="$agent_dir/skills"
    platform="${agent_dir#.}"  # Remove leading dot
    [ "$platform" = "agents" ] && platform="all"
    [ "$platform" = "github/copilot" ] && platform="copilot"
    collect_skills "$platform" "$skills_dir" "skill" 2>/dev/null || true
  done
  
  # Global directories
  collect_skills "Claude" "$HOME/.claude/skills" "skill" 2>/dev/null || true
  collect_skills "Claude" "$HOME/.claude/commands" "command" 2>/dev/null || true
  collect_skills "Pi" "$HOME/.pi/skills" "skill" 2>/dev/null || true
  collect_skills "OpenCode" "$HOME/.opencode/skills" "skill" 2>/dev/null || true
  collect_skills "OpenCode" "$HOME/.config/opencode/skills" "skill" 2>/dev/null || true
  collect_skills "OpenCode" "$HOME/.opencode/command" "command" 2>/dev/null || true
  collect_skills "OpenCode" "$HOME/.config/opencode/command" "command" 2>/dev/null || true
  collect_skills "Codex" "$HOME/.codex/skills" "skill" 2>/dev/null || true
  collect_skills "Gemini" "$HOME/.gemini/commands" "command" 2>/dev/null || true
  collect_skills "Copilot" "$HOME/.github/copilot/skills" "skill" 2>/dev/null || true
} | sort -u > /tmp/skills_list.txt

if [ "$FORMAT" = "readme" ]; then
  # Markdown table output
  echo "## My Installed Skills"
  echo ""
  echo "| Skill | Platform | Type |"
  echo "|-------|----------|------|"
  
  if [ -s /tmp/skills_list.txt ]; then
    while IFS='|' read -r skill platform category; do
      # Capitalize first letter of category
      category_display=$(echo "$category" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')
      echo "| $skill | $platform | $category_display |"
    done < /tmp/skills_list.txt
  else
    echo "| (none) | - | - |"
  fi
  echo ""
  echo "*Generated with [Portable AI Skillkit](https://github.com/kolisachint/skills)*"
  
else
  # Default formatted output
  echo "=== LOCAL PROJECT SKILLS ==="
  echo "Directory: $(pwd)"
  echo ""
  
  local_found=false
  for agent_dir in .agents .claude .pi .opencode .codex .github/copilot; do
    skills_dir="$agent_dir/skills"
    if [ -d "$skills_dir" ]; then
      skills=$(find "$skills_dir" -maxdepth 1 -mindepth 1 \( -type l -o -type d \) -exec basename {} \; 2>/dev/null | grep -v -E "$EXCLUDE_PATTERNS" || true)
      if [ -n "$skills" ]; then
        local_found=true
        local_count=$(echo "$skills" | wc -l | tr -d ' ')
        echo "📁 $skills_dir/ ($local_count skills)"
        echo "$skills" | while read skill; do
          echo "   • $skill"
        done
        echo ""
      fi
    fi
  done
  
  if [ "$local_found" = false ]; then
    echo "   (no local skills found)"
    echo ""
  fi
  
  echo ""
  echo "=== GLOBAL USER SKILLS ==="
  echo ""
  
  global_found=false
  
  check_global_dir() {
    local name="$1"
    local dir="$2"
    if [ -d "$dir" ]; then
      local items
      items=$(find "$dir" -maxdepth 1 -mindepth 1 -exec basename {} \; 2>/dev/null | grep -v -E "$EXCLUDE_PATTERNS" || true)
      if [ -n "$items" ]; then
        local count
        count=$(echo "$items" | wc -l | tr -d ' ')
        echo "📁 $name: $dir/ ($count skills)"
        echo "$items" | head -20 | while read item; do
          echo "   • $item"
        done
        if [ "$count" -gt 20 ]; then
          echo "   ... and $((count - 20)) more"
        fi
        echo ""
        return 0
      fi
    fi
    return 1
  }
  
  if check_global_dir "Claude" "$HOME/.claude/skills"; then global_found=true; fi
  if check_global_dir "Claude Commands" "$HOME/.claude/commands"; then global_found=true; fi
  if check_global_dir "Pi" "$HOME/.pi/skills"; then global_found=true; fi
  if check_global_dir "OpenCode" "$HOME/.opencode/skills"; then global_found=true; fi
  if check_global_dir "OpenCode" "$HOME/.config/opencode/skills"; then global_found=true; fi
  if check_global_dir "OpenCode Commands" "$HOME/.opencode/command"; then global_found=true; fi
  if check_global_dir "OpenCode Commands" "$HOME/.config/opencode/command"; then global_found=true; fi
  if check_global_dir "Codex" "$HOME/.codex/skills"; then global_found=true; fi
  if check_global_dir "Gemini" "$HOME/.gemini/commands"; then global_found=true; fi
  if check_global_dir "Copilot" "$HOME/.github/copilot/skills"; then global_found=true; fi
  
  if [ "$global_found" = false ]; then
    echo "   (no global skills found)"
    echo ""
  fi
  
  echo ""
  echo "=== USER INSTALLED NPM PACKAGES ==="
  echo ""
  if command -v npm &> /dev/null; then
    npm_pkgs=$(npm list -g --depth=0 2>/dev/null | grep -E "^├─|^└─|^├──|^└──" | sed 's/^[├└─│ ]*//' | grep -v -E "^corepack|^npm@|^@mariozechner/pi-coding-agent|^@openai/codex" || true)
    if [ -n "$npm_pkgs" ]; then
      echo "$npm_pkgs"
    else
      echo "   (no user-installed npm packages)"
    fi
  else
    echo "   npm not found"
  fi
  
  echo ""
  echo "=== CLI TOOLS ==="
  echo ""
  for cmd in claude codex pi opencode codeburn; do
    if command -v "$cmd" &> /dev/null; then
      location=$(command -v "$cmd" 2>/dev/null)
      echo "✓ $cmd: $location"
    fi
  done
  
  echo ""
  echo "=== SUMMARY ==="
  echo ""
  echo "Excluded system packages:"
  echo "   • npm, corepack (node system)"
  echo "   • @mariozechner/pi-coding-agent (pi CLI itself)"
  echo "   • @openai/codex (codex CLI itself)"
  echo "   • .*, *-runtime, .system (system files)"
  echo ""
  echo "Commands:"
  echo "   Install:    ./install.sh <skill-name>"
  echo "   Remove:     ./install.sh remove <skill-name>"
  echo "   List all:   npx skills list -g"
  echo "   README fmt: $0 --format readme"
fi

rm -f /tmp/skills_list.txt
