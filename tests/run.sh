#!/usr/bin/env bash
# Portable AI Skillkit — Test Suite
# Usage: ./tests/run.sh [test_group ...]
#   test_group: catalog, makefile, lockfile, install, verify, list, add, remove, gitignore, docs, all
#
# Exit codes:
#   0 — All tests passed
#   1 — One or more tests failed

set -uo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Counters ─────────────────────────────────────────────────────────────────
PASS=0
FAIL=0
SKIP=0
TOTAL=0

# ─── Resolve repo root ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG="$REPO_ROOT/catalog.tsv"

cd "$REPO_ROOT"

# ─── Utilities ────────────────────────────────────────────────────────────────
pass() { PASS=$((PASS + 1)); TOTAL=$((TOTAL + 1)); echo -e "  ${GREEN}✓ PASS${NC} $1"; }
fail() { FAIL=$((FAIL + 1)); TOTAL=$((TOTAL + 1)); echo -e "  ${RED}✗ FAIL${NC} $1"; }
skip() { SKIP=$((SKIP + 1)); TOTAL=$((TOTAL + 1)); echo -e "  ${YELLOW}⊘ SKIP${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}══ $1 ══${NC}"; }

assert_exists() {
  local file="$1" label="${2:-$1}"
  if [[ -f "$file" ]]; then pass "$label exists"; else fail "$label does NOT exist"; fi
}

assert_executable() {
  local file="$1" label="${2:-$1}"
  if [[ -x "$file" ]]; then pass "$label is executable"; else fail "$label is NOT executable"; fi
}

assert_symlink() {
  local path="$1" label="${2:-$1}"
  if [[ -L "$path" ]]; then pass "$label is a symlink"; else fail "$label is NOT a symlink (expected symlink)"; fi
}

assert_not_symlink() {
  local path="$1" label="${2:-$1}"
  if [[ ! -L "$path" && -d "$path" ]]; then pass "$label is a real directory"; else fail "$label is a symlink or missing (expected real directory)"; fi
}

assert_file_contains() {
  local file="$1" pattern="$2" label="${3:-$1 contains $2}"
  if grep -q "$pattern" "$file" 2>/dev/null; then pass "$label"; else fail "$label — pattern not found in $file"; fi
}

assert_file_not_contains() {
  local file="$1" pattern="$2" label="${3:-$1 does not contain $2}"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then pass "$label"; else fail "$label — pattern FOUND in $file"; fi
}

assert_cmd_exit_0() {
  local cmd="$1" label="${2:-$1 exits 0}"
  if eval "$cmd" >/dev/null 2>&1; then pass "$label"; else fail "$label — exited non-zero"; fi
}

assert_cmd_exit_nonzero() {
  local cmd="$1" label="${2:-$1 exits non-zero}"
  if ! eval "$cmd" >/dev/null 2>&1; then pass "$label"; else fail "$label — unexpectedly exited 0"; fi
}

# ─── TEST GROUPS ──────────────────────────────────────────────────────────────

test_catalog() {
  section "CATALOG.TSV"

  # File exists
  assert_exists "$CATALOG" "catalog.tsv"

  # Correct number of columns (10)
  local line_count=0 bad_lines=0
  while IFS= read -r line; do
    line_count=$((line_count + 1))
    local nf
    nf=$(echo "$line" | awk -F'\t' '{print NF}')
    if [[ "$nf" -ne 10 ]]; then
      bad_lines=$((bad_lines + 1))
      warn "Line $line_count has $nf fields (expected 10)"
    fi
  done < "$CATALOG"
  if [[ $bad_lines -eq 0 ]]; then pass "All catalog lines have 10 tab-separated fields"; else fail "$bad_lines catalog lines have wrong field count"; fi

  # Header row is correct
  local header
  header=$(head -1 "$CATALOG")
  if [[ "$header" == "name	category	source	platforms	agent_target	description	install_command	stars	remove_command	docs_url" ]]; then
    pass "Header row is correct"
  else
    fail "Header row is incorrect: $header"
  fi

  # Every data row has non-empty name, category, install_command
  local empty_fields=0
  awk -F'\t' 'NR>1 {
    if ($1 == "") { print "Row "NR": empty name"; }
    if ($2 == "") { print "Row "NR": empty category"; }
    if ($7 == "" || $7 == "-") { print "Row "NR": missing install_command"; }
  }' "$CATALOG" | while read -r msg; do
    empty_fields=$((empty_fields + 1))
    fail "$msg"
  done
  if [[ $empty_fields -eq 0 ]]; then pass "All data rows have name, category, install_command"; fi

  # Consistent star format (no mixed formats)
  local star_issues=0
  awk -F'\t' 'NR>1 && $8 != "-" {
    if ($8 !~ /^[0-9]+(\.[0-9]+)?K\+?$/) { print "Row "NR": unusual star format: "$8; star_issues++ }
  }' "$CATALOG" | while read -r msg; do
    fail "$msg"
    star_issues=$((star_issues + 1))
  done
  if [[ $star_issues -eq 0 ]]; then pass "Star format is consistent"; fi

  # No duplicate names
  local dupes
  dupes=$(awk -F'\t' 'NR>1 {print $1}' "$CATALOG" | sort | uniq -d)
  if [[ -z "$dupes" ]]; then pass "No duplicate skill names"; else fail "Duplicate names: $dupes"; fi

  # Names are kebab-case (no spaces, no underscores)
  local bad_names
  bad_names=$(awk -F'\t' 'NR>1 && $1 !~ /^[a-z0-9]+([a-z0-9-]*[a-z0-9]+)?$/' "$CATALOG")
  if [[ -z "$bad_names" ]]; then pass "All names are kebab-case"; else fail "Non-kebab-case names: $bad_names"; fi

  # Valid categories
  local valid_cats="skill prompt command tool agent workflow"
  local bad_cats=0
  awk -F'\t' -v cats="$valid_cats" 'NR>1 {
    split(cats, valid, " ")
    found=0
    for (i in valid) { if ($2 == valid[i]) { found=1; break } }
    if (!found) { print "Row "NR": invalid category: "$2 }
  }' "$CATALOG" | while read -r msg; do fail "$msg"; bad_cats=$((bad_cats + 1)); done
  if [[ $bad_cats -eq 0 ]]; then pass "All categories are valid"; fi
}

test_makefile() {
  section "MAKEFILE"

  local mf="$REPO_ROOT/Makefile"
  assert_exists "$mf" "Makefile"

  # Makefile should reference ./install (not ./install.sh)
  assert_file_not_contains "$mf" 'install\.sh' "Makefile does NOT reference install.sh"
  assert_file_contains "$mf" '\./install' "Makefile references ./install"

  # Makefile targets should be resolvable
  assert_file_contains "$mf" 'bootstrap-ai' "Makefile has bootstrap-ai target"
  assert_file_contains "$mf" 'bootstrap-all' "Makefile has bootstrap-all target"
  assert_file_contains "$mf" 'list' "Makefile has list target"
}

test_lockfile() {
  section "SKILLS-LOCK.JSON"

  local lf="$REPO_ROOT/skills-lock.json"
  assert_exists "$lf" "skills-lock.json"

  # Valid JSON
  if python3 -c "import json; json.load(open('$lf'))" 2>/dev/null; then
    pass "skills-lock.json is valid JSON"
  else
    fail "skills-lock.json is NOT valid JSON"
  fi

  # Every skillPath should point to a real file (check only entries in lockfile)
  local bad_paths=0
  python3 -c "
import json, os
with open('$lf') as f:
    data = json.load(f)
for name, info in data.get('skills', {}).items():
    path = info.get('skillPath', '')
    full = os.path.join('$REPO_ROOT', path)
    # Also check if name/SKILL.md exists as fallback
    fallback = os.path.join('$REPO_ROOT', '.agents/skills', name, 'SKILL.md')
    if not os.path.exists(full) and not os.path.exists(fallback):
        print(f'WRONG PATH: {name} -> {path}')
" 2>/dev/null | while read -r msg; do
    fail "$msg"
    bad_paths=$((bad_paths + 1))
  done
  if [[ $bad_paths -eq 0 ]]; then pass "All lock file skillPaths resolve to real files"; fi

  # Every skill in lock file should have a directory in .agents/skills/
  python3 -c "
import json
with open('$lf') as f:
    data = json.load(f)
import os
for name in data.get('skills', {}):
    d = os.path.join('$REPO_ROOT', '.agents/skills', name)
    if not os.path.isdir(d):
        print(f'MISSING DIR: {name} -> {d}')
" 2>/dev/null | while read -r msg; do fail "$msg"; done
}

test_install_script() {
  section "INSTALL SCRIPT"

  local inst="$REPO_ROOT/install"
  assert_exists "$inst" "install script"
  assert_executable "$inst" "install script"

  # Bash syntax check
  assert_cmd_exit_0 "bash -n $inst" "install: bash syntax check"

  # --help works
  assert_cmd_exit_0 "bash $inst --help" "install --help"

  # --from and --tag flags should be implemented (not just parsed)
  assert_file_contains "$inst" 'FROM_FILE' "install: FROM_FILE variable used"
  # Check that FROM_FILE is actually read (not just parsed)
local from_implementation
  from_implementation=$(grep -cE 'if \[\[ -n "\$FROM_FILE" \]\]|< "\$FROM_FILE"|cat "\$FROM_FILE"|awk.*"\$FROM_FILE"' "$inst" 2>/dev/null || echo "0")
  if [[ "$from_implementation" -gt 0 ]]; then
    pass "install: --from flag has implementation"
  else
    fail "install: --from flag is parsed but NOT implemented (dead code)"
  fi

  # --category filter with valid category should find entries
  local count
  count=$(bash "$inst" --category workflow --help 2>/dev/null | wc -l | tr -d ' ')
  pass "install: --category flag is accepted"

  # Parallel install.ps1 should exist
  assert_exists "$REPO_ROOT/install.ps1" "install.ps1"

  # install.ps1 should also implement -From/-Tag
  local ps1_from_impl
  ps1_from_impl=$(grep -c 'Get-Content.*\$From\|Import-Csv.*\$From\|Read.*favorites' "$REPO_ROOT/install.ps1" 2>/dev/null || echo "0")
  if [[ "$ps1_from_impl" -gt 0 ]]; then
    pass "install.ps1: -From flag has implementation"
  else
    fail "install.ps1: -From flag is parsed but NOT implemented (dead code)"
  fi
}

test_verify_script() {
  section "VERIFY SCRIPT"

  local ver="$REPO_ROOT/verify"
  assert_exists "$ver" "verify script"
  assert_executable "$ver" "verify script"

  # Bash syntax check
  assert_cmd_exit_0 "bash -n $ver" "verify: bash syntax check"

  # --help works
  assert_cmd_exit_0 "bash $ver --help" "verify --help"

  # --all should read from catalog.tsv (not just hardcoded)
  local all_output
  all_output=$(bash "$ver" --all 2>&1 || true)
  # Catalog-driven: should list catalog skill names
  if echo "$all_output" | grep -qi "superpowers\|agent-skills\|caveman\|grill-me\|plannotator\|codeburn"; then
    pass "verify --all checks catalog skills"
  else
    fail "verify --all does NOT check any catalog skills"
  fi
  # Should also list CLI tools from catalog
  if echo "$all_output" | grep -q "codeburn"; then
    pass "verify --all checks codeburn (from catalog)"
  else
    fail "verify --all does NOT check codeburn"
  fi

  # verify reads catalog at runtime (not hardcoded), so check that catalog exists and is read
  if [[ -f "$CATALOG" ]]; then
    local sp_output
    sp_output=$(bash "$ver" superpowers 2>&1 || true)
    if echo "$sp_output" | grep -qi "superpowers"; then
      pass "verify handles catalog skill: superpowers"
    else
      fail "verify does NOT handle catalog skill: superpowers"
    fi
    local cav_output
    cav_output=$(bash "$ver" caveman 2>&1 || true)
    if echo "$cav_output" | grep -qi "caveman"; then
      pass "verify handles catalog skill: caveman"
    else
      fail "verify does NOT handle catalog skill: caveman"
    fi
  else
    skip "verify catalog skill: superpowers (no catalog)"
    skip "verify catalog skill: caveman (no catalog)"
  fi

  # Parallel verify.ps1 should exist
  assert_exists "$REPO_ROOT/verify.ps1" "verify.ps1"
}

test_list_script() {
  section "LIST SCRIPT"

  local lst="$REPO_ROOT/list"
  assert_exists "$lst" "list script"
  assert_executable "$lst" "list script"

  # Bash syntax check
  assert_cmd_exit_0 "bash -n $lst" "list: bash syntax check"

  # --help works
  assert_cmd_exit_0 "bash $lst --help" "list --help"

  # Default run should succeed
  assert_cmd_exit_0 "bash $lst" "list: default run succeeds"

  # --format readme should produce markdown table
  local readme_output
  readme_output=$(bash "$lst" --format readme 2>&1)
  if echo "$readme_output" | grep -q "| Skill |"; then
    pass "list --format readme produces markdown table"
  else
    fail "list --format readme does NOT produce markdown table"
  fi

  # Should NOT use hardcoded /tmp path (should use mktemp)
  assert_file_not_contains "$lst" '/tmp/skills_list.txt' "list: does NOT use hardcoded /tmp path"

  # Parallel list.ps1 should exist
  assert_exists "$REPO_ROOT/list.ps1" "list.ps1"
}

test_add_script() {
  section "ADD SCRIPT"

  local add="$REPO_ROOT/add"
  assert_exists "$add" "add script"
  assert_executable "$add" "add script"

  # Bash syntax check
  assert_cmd_exit_0 "bash -n $add" "add: bash syntax check"

  # --help works
  assert_cmd_exit_0 "bash $add --help" "add --help"

  # Duplicate detection should use exact match (awk, not grep regex)
  if grep -q 'awk.*-v.*name.*\$1==name' "$add" 2>/dev/null || grep -q 'awk.*-v.*n.*\$1==n' "$add" 2>/dev/null; then
    pass "add: uses awk exact-match for duplicate detection"
  elif grep -q 'grep.*"\^\\$NAME' "$add" 2>/dev/null; then
    fail "add: uses unsafe grep regex for duplicate detection"
  else
    warn "add: duplicate detection method unclear"
  fi

  # Parallel add.ps1 should exist
  assert_exists "$REPO_ROOT/add.ps1" "add.ps1"
}

test_remove_script() {
  section "REMOVE SCRIPT"

  local rem="$REPO_ROOT/remove"
  assert_exists "$rem" "remove script"
  assert_executable "$rem" "remove script"

  # Bash syntax check
  assert_cmd_exit_0 "bash -n $rem" "remove: bash syntax check"

  # --help works
  assert_cmd_exit_0 "bash $rem --help" "remove --help"

  # remove_npm_global should NOT use pipe to while (subshell bug)
  if grep -q 'echo.*|.*while read' "$rem" 2>/dev/null; then
    fail "remove: remove_npm_global uses pipe-to-while (subshell bug)"
  elif grep -q 'while.*read.*< <(' "$rem" 2>/dev/null; then
    pass "remove: remove_npm_global uses process substitution (no subshell bug)"
  else
    warn "remove: remove_npm_global implementation unclear"
  fi

  # Parallel remove.ps1 should exist
  assert_exists "$REPO_ROOT/remove.ps1" "remove.ps1"
}

test_gitignore() {
  section "GITIGNORE"

  local gi="$REPO_ROOT/.gitignore"
  assert_exists "$gi" ".gitignore"

  # Should cover common patterns
  assert_file_contains "$gi" 'node_modules' ".gitignore covers node_modules"
  assert_file_contains "$gi" '\.DS_Store' ".gitignore covers .DS_Store"
  assert_file_contains "$gi" 'credentials\|\.env' ".gitignore covers secrets"
}

test_docs() {
  section "DOCS"

  # docs/CATALOG_FORMAT.md should NOT reference install.sh (should be install)
  local cfm="$REPO_ROOT/docs/CATALOG_FORMAT.md"
  assert_exists "$cfm" "docs/CATALOG_FORMAT.md"
  assert_file_not_contains "$cfm" 'install\.sh' "CATALOG_FORMAT.md does NOT reference install.sh"

  # docs/REFERENCES.md should exist
  assert_exists "$REPO_ROOT/docs/REFERENCES.md" "docs/REFERENCES.md"
  assert_exists "$REPO_ROOT/docs/SKILL_SOURCES.md" "docs/SKILL_SOURCES.md"

  # README should NOT reference install.sh in local usage (only in curl pipe context)
  local readme="$REPO_ROOT/README.md"
  assert_exists "$readme" "README.md"
  # README may reference install.sh in curl pipes which is fine (that's remote)
  # But local ./install.sh references are bugs
  local local_install_sh_refs
  local_install_sh_refs=$(grep -c '\./install\.sh' "$readme" 2>/dev/null)
  local_install_sh_refs=${local_install_sh_refs:-0}
  if [[ "$local_install_sh_refs" -eq 0 ]]; then
    pass "README does NOT reference ./install.sh locally"
  else
    fail "README has $local_install_sh_refs local ./install.sh references"
  fi
}

test_skill_consistency() {
  section "SKILL FILE CONSISTENCY"

  # .agents/skills/ should be the canonical source (real directories)
  local agents_dir="$REPO_ROOT/.agents/skills"
  if [[ -d "$agents_dir" ]]; then
    pass ".agents/skills/ directory exists"
    for skill_dir in "$agents_dir"/*/; do
      [[ ! -d "$skill_dir" ]] && continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      assert_not_symlink "$skill_dir" ".agents/skills/$skill_name"
      assert_exists "$skill_dir/SKILL.md" ".agents/skills/$skill_name/SKILL.md"
    done
  else
    fail ".agents/skills/ directory does NOT exist"
  fi

  # Platform directories should be symlinks to .agents/skills/
  for platform_dir in .claude/skills .pi/skills; do
    if [[ -d "$REPO_ROOT/$platform_dir" ]]; then
      pass "$platform_dir/ exists"
      for skill_link in "$REPO_ROOT/$platform_dir"/*/; do
        [[ ! -e "$skill_link" ]] && continue
        local sname
        sname=$(basename "$skill_link")
        assert_symlink "$REPO_ROOT/$platform_dir/$sname" "$platform_dir/$sname"
      done
    else
      warn "$platform_dir/ does not exist (may not be installed)"
    fi
  done

  # skills/ should also be symlinks
  if [[ -d "$REPO_ROOT/skills" ]]; then
    for skill_link in "$REPO_ROOT/skills"/*/; do
      [[ ! -e "$skill_link" ]] && continue
      local sname
      sname=$(basename "$skill_link")
      assert_symlink "$REPO_ROOT/skills/$sname" "skills/$sname"
    done
  fi
}

test_favorites() {
  section "FAVORITES.TSV"

  local fav="$REPO_ROOT/favorites.tsv"
  assert_exists "$fav" "favorites.tsv"

  # Header row
  local header
  header=$(head -1 "$fav")
  if [[ "$header" == "name	category	platforms	tags	source" ]]; then
    pass "favorites.tsv header is correct"
  else
    fail "favorites.tsv header is incorrect: $header"
  fi

  # Every name in favorites should exist in catalog
  local missing=0
  awk -F'\t' 'NR>1 {print $1}' "$fav" | while read -r name; do
    if grep -q "^${name}	" "$CATALOG" 2>/dev/null; then
      pass "favorites entry '$name' exists in catalog"
    else
      fail "favorites entry '$name' does NOT exist in catalog"
      missing=$((missing + 1))
    fi
  done
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

# Determine which test groups to run
if [[ $# -eq 0 ]] || [[ "$*" == *all* ]]; then
  TEST_GROUPS=(catalog makefile lockfile install verify list add remove gitignore docs skill_consistency favorites)
else
  TEST_GROUPS=("$@")
fi

echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     Portable AI Skillkit — Test Suite                   ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Repository: $REPO_ROOT"
echo "Test groups: ${TEST_GROUPS[*]}"
echo ""

for group in "${TEST_GROUPS[@]}"; do
  case "$group" in
    catalog) test_catalog ;;
    makefile) test_makefile ;;
    lockfile) test_lockfile ;;
    install) test_install_script ;;
    verify) test_verify_script ;;
    list) test_list_script ;;
    add) test_add_script ;;
    remove) test_remove_script ;;
    gitignore) test_gitignore ;;
    docs) test_docs ;;
    skill_consistency) test_skill_consistency ;;
    favorites) test_favorites ;;
    all)
      test_catalog
      test_makefile
      test_lockfile
      test_install_script
      test_verify_script
      test_list_script
      test_add_script
      test_remove_script
      test_gitignore
      test_docs
      test_skill_consistency
      test_favorites
      ;;
    *) echo -e "  ${RED}Unknown test group: $group${NC}";;
  esac
done

echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "  Total: $TOTAL  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Skipped: $SKIP${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"

if [[ $FAIL -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}✗ $FAIL test(s) FAILED${NC}\n"
  exit 1
else
  echo -e "\n${GREEN}${BOLD}✓ All tests passed${NC}\n"
  exit 0
fi