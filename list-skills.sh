#!/usr/bin/env bash
# List user-installed skills across all agent platforms (hides system packages)

set -euo pipefail

# Patterns to exclude (system/critical packages)
EXCLUDE_PATTERNS="^\.|runtime|system|corepack|^npm$|^@mariozechner/pi-coding-agent$|^@openai/codex$"

echo "=== LOCAL PROJECT SKILLS ==="
echo "Directory: $(pwd)"
echo ""

local_found=false
local_count=0

# Check local agent directories
for agent_dir in .agents .claude .pi .opencode .codex .github/copilot; do
  skills_dir="$agent_dir/skills"
  if [ -d "$skills_dir" ]; then
    # Get skills excluding system patterns
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

# Check each global location individually
check_global_dir() {
  local name="$1"
  local dir="$2"
  if [ -d "$dir" ]; then
    # Get items excluding system patterns
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

# Claude
if check_global_dir "Claude" "$HOME/.claude/skills"; then global_found=true; fi
if check_global_dir "Claude Commands" "$HOME/.claude/commands"; then global_found=true; fi

# Pi
if check_global_dir "Pi" "$HOME/.pi/skills"; then global_found=true; fi

# OpenCode
if check_global_dir "OpenCode" "$HOME/.opencode/skills"; then global_found=true; fi
if check_global_dir "OpenCode" "$HOME/.config/opencode/skills"; then global_found=true; fi
if check_global_dir "OpenCode Commands" "$HOME/.opencode/command"; then global_found=true; fi
if check_global_dir "OpenCode Commands" "$HOME/.config/opencode/command"; then global_found=true; fi

# Codex
if check_global_dir "Codex" "$HOME/.codex/skills"; then global_found=true; fi

# Gemini
if check_global_dir "Gemini" "$HOME/.gemini/commands"; then global_found=true; fi

# Copilot
if check_global_dir "Copilot" "$HOME/.github/copilot/skills"; then global_found=true; fi

if [ "$global_found" = false ]; then
  echo "   (no global skills found)"
  echo ""
fi

echo ""
echo "=== USER INSTALLED NPM PACKAGES ==="
echo ""
if command -v npm &> /dev/null; then
  # Get npm global packages, excluding system ones
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
