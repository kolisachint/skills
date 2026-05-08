# Portable AI Skillkit

Curated components for coding agents. One catalog. All platforms. Zero friction.

## Quick Start

No clone required — run directly via curl/PowerShell:

| Action | macOS / Linux | Windows (PowerShell) |
|--------|--------------|---------------------|
| **List** installed skills | `curl -fsSL github.com/kolisachint/skills/raw/main/list_skill \| bash` | `irm github.com/kolisachint/skills/raw/main/list_skill \| iex` |
| **Install** a skill | `curl -fsSL github.com/kolisachint/skills/raw/main/install_skill \| bash -s -- caveman` | `irm github.com/kolisachint/skills/raw/main/install_skill \| iex -skill caveman` |
| **Uninstall** a skill | `curl -fsSL github.com/kolisachint/skills/raw/main/uninstall_skill \| bash -s -- caveman` | `irm github.com/kolisachint/skills/raw/main/uninstall_skill \| iex -skill caveman` |
| **Verify** installation | `curl -fsSL github.com/kolisachint/skills/raw/main/verify \| bash -s -- plannotator` | `irm github.com/kolisachint/skills/raw/main/verify.ps1 \| iex -skill plannotator` |

**Install multiple at once:**
```bash
# Productivity pack (macOS/Linux)
curl -fsSL github.com/kolisachint/skills/raw/main/install_skill \
  | bash -s -- --skill plannotator,grill-me,caveman,codeburn

# Core skills (Windows)
irm github.com/kolisachint/skills/raw/main/install_skill \
  | iex -skill superpowers,agent-skills,caveman,grill-me
```

---

## Local Setup (Recommended)

Clone once to `~/github/skills`, run from anywhere:

```bash
git clone https://github.com/kolisachint/skills.git ~/github/skills

# Optional: add to PATH
export PATH="$HOME/github/skills:$PATH"

# Now run from any directory
install_skill caveman
install_skill --skill plannotator,grill-me,caveman,codeburn
list_skill
uninstall_skill caveman
```

All scripts automatically fall back to `~/github/skills/catalog.tsv` when run outside the repo directory.

---

## Commands Reference

### install_skill

```bash
# From catalog
install_skill caveman

# From GitHub directly
install_skill --direct owner/repo

# Platform-specific
install_skill --platform copilot --direct obra/superpowers

# Install category
install_skill --category workflow

# Batch install (comma-separated)
install_skill --skill superpowers,agent-skills,caveman,grill-me

# From favorites file
install_skill --from favorites.tsv --tag daily-driver
```

### uninstall_skill

```bash
# Remove single skill
uninstall_skill caveman

# Remove multiple
uninstall_skill caveman grill-me

# Remove everything everywhere
uninstall_skill --all

# Platform-specific removal
uninstall_skill --platform copilot caveman
```

**Sample output:**
```
→ caveman
  Local: npx skills remove caveman --yes
    ✓ Removed from local project
  Global directories...
    ✓ Removed from ~/.claude/skills: caveman
    ✓ Removed from ~/.claude/skills: caveman-help
  NPM global packages...
    ℹ No matching npm global packages

✓ Removal complete
```

### list_skill

```bash
# Human readable
list_skill

# Generate README table
list_skill --format readme
```

### verify

```bash
# Verify specific skill
verify plannotator

# Verify with platform
verify plannotator --platform pi

# Verify all known skills
verify --all

# Verify CLI tool
verify --cli plannotator --verbose
```

### add

```bash
# Quick add with GitHub repo
add my-skill --github owner/repo --category skill

# With npm package
add my-tool --npm my-package --category tool --stars 1K

# Interactive mode
add my-skill
```

---

## Curated Components

| Category | Skills | Description |
|----------|--------|-------------|
| **⚡ Workflows** | superpowers *(90K★)* | Complete TDD and methodology framework |
| **🧠 Skills** | agent-skills *(20K★)* | Production engineering from Google's culture |
| **🎯 Commands** | caveman *(52K★)*<br>grill-me *(31K★)*<br>plannotator *(5K★)* | Ultra-compressed communication<br>One-question-at-a-time interrogation<br>Visual plan and diff review |
| **🔧 Tools** | codeburn *(4.6K★)* | Interactive TUI for token/cost observability |

---

## Platform Compatibility

Commands are automatically transformed for your target platform:

| Platform | Transform | Status |
|----------|-----------|--------|
| **OpenCode** | `npx skills add repo` → `npx skills add repo -a opencode -g -y` | ✅ Supported |
| **Pi** | `npx skills add repo` → `pi install https://github.com/repo` | ✅ Supported |
| **Claude** | `npx skills add repo` → `npx skills add repo --yes` | ✅ Supported |
| **Codex** | `npx skills add repo` → `codex skills add <skill-name>` | ✅ Supported |
| **Copilot** | `npx skills add repo` → `gh copilot -- plugin install repo` | ✅ Requires [gh CLI](https://cli.github.com/) |

---

## Favorites

Create `favorites.tsv` for your personal shortlist:

```tsv
name	category	platforms	tags	source
superpowers	workflow	all	daily-driver	external
agent-skills	skill	all	daily-driver	external
caveman	command	all	daily-driver	external
```

**Tags:** `daily-driver`, `occasional`, `critical`

```bash
# Install all favorites
install_skill --from favorites.tsv

# Install only daily-driver tagged
install_skill --from favorites.tsv --tag daily-driver
```

---

## How It Works

This repo is a thin wrapper around `npx skills`:

- `npx skills add <repo>` → installs to `.agents/skills/` + platform symlinks
- `npm install <pkg>` → installs to `node_modules/`, auto-copied to `.agents/skills/`

Everything stays repo-local. Delete the repo = skills are gone.

**Catalog format:** `catalog.tsv` — single TSV file with name, category, platform, install command, etc.

**Documentation:**
- [docs/CATALOG_FORMAT.md](docs/CATALOG_FORMAT.md) — TSV format and transforms
- [docs/SKILL_SOURCES.md](docs/SKILL_SOURCES.md) — Installation commands from READMEs
- [docs/REFERENCES.md](docs/REFERENCES.md) — Platform documentation links

---

## Philosophy

This is a **curated distribution**, not a collection. See [PHILOSOPHY.md](PHILOSOPHY.md).

Core beliefs:
1. **Humans remain in control** — AI amplifies judgment
2. **Explicit is better than implicit** — No magic
3. **Context is scarce** — Every component earns its place
4. **Vendor agnosticism** — Works across all platforms
5. **Progressive disclosure** — Start simple
6. **Agent specificity** — Generic defaults, precise overrides

---

## Files

| File | Purpose |
|------|---------|
| `install_skill` / `install_skill.ps1` | Install skills |
| `uninstall_skill` / `uninstall_skill.ps1` | Uninstall skills |
| `list_skill` / `list_skill.ps1` | List installed skills |
| `add` / `add.ps1` | Add skill to catalog |
| `verify` / `verify.ps1` | Verify installations |
| `catalog.tsv` | Single source of truth |
| `favorites.tsv` | Personal shortlist |
| `Makefile` | Quick targets |
| `tests/run.sh` | Test suite |
| `PHILOSOPHY.md` | Design principles |
