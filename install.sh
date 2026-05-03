#!/usr/bin/env bash
set -euo pipefail

# Portable AI Skillkit — One-shot installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOURNAME/skills/main/install.sh | bash -s -- --target ~/repo
#   ./install.sh --target ~/repo
#   ./install.sh --target ~/repo --source internal --category workflow

REPO_URL="${SKILLKIT_REPO:-https://github.com/kolisachint/skills.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running from cloned repo, use local scripts. Otherwise clone temp copy.
if [[ -f "$SCRIPT_DIR/scripts/skillkit.sh" ]]; then
  SKILLKIT_SCRIPT="$SCRIPT_DIR/scripts/skillkit.sh"
else
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  printf '→ Cloning Portable AI Skillkit...\n'
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1
  SKILLKIT_SCRIPT="$TEMP_DIR/scripts/skillkit.sh"
fi

# Forward all arguments to the real installer
exec bash "$SKILLKIT_SCRIPT" install "$@"
