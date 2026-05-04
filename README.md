# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Quick Start

### One-liner (no clone)

```bash
# macOS / Linux — install a specific skill directly into current directory
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- caveman

# Or install multiple skills
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- caveman,grill-me

# With explicit target
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- --target ~/repo --skill caveman
```

**Windows:**
```powershell
# Install a specific skill directly into current directory
irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 | iex -caveman

# Or with explicit target
irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 | iex -target C:\code\repo -skill caveman
```

### Git clone + install

```bash
# 1. Clone
git clone https://github.com/kolisachint/skills.git && cd skills

# 2. Install a specific skill (defaults to current directory)
./install.sh caveman

# 3. Or install multiple skills
./install.sh caveman grill-me

# 4. Or install by category
./install.sh --target ~/repo --category workflow

# 5. Or install everything in the catalog
./install.sh --target ~/repo
```

**Windows:**
```powershell
git clone https://github.com/kolisachint/skills.git; cd skills
.\install.ps1 caveman
.\install.ps1 caveman, grill-me
.\install.ps1 --target C:\code\repo --category workflow
.\install.ps1 --target C:\code\repo
```

### Bootstrap from Favorites

Curate your most-used components in `favorites.tsv`, then batch-install:

```bash
# macOS / Linux — install everything tagged "daily-driver" or "critical"
./install.sh --target ~/repo --from favorites.tsv --tag daily-driver,critical

# macOS / Linux — via Make
make bootstrap-ai TARGET=~/repo

# Windows — install everything tagged "daily-driver" or "critical"
.\install.ps1 --target C:\code\repo --from favorites.tsv --tag daily-driver,critical
```

---

## Discover & Search

```bash
# macOS / Linux
./install.sh list
./install.sh list-categories
./install.sh list-platforms
./install.sh search review
./install.sh search codex
./install.sh search debug
./install.sh top        # default top 10
./install.sh top 5      # top 5 only

# Windows
.\install.ps1 list
.\install.ps1 list-categories
.\install.ps1 list-platforms
.\install.ps1 search review
.\install.ps1 search codex
.\install.ps1 search debug
.\install.ps1 top
.\install.ps1 top 5
```

## Manage Skills

```bash
# macOS / Linux
./install.sh installed                  # list what's installed (local project)
./install.sh remove caveman             # remove from local + global
./install.sh remove caveman grill-me    # remove multiple
./install.sh remove --all               # remove ALL skills (local + global)
./install.sh update                     # update all skills
./install.sh update caveman             # update one skill

# Windows
.\install.ps1 installed
.\install.ps1 remove caveman
.\install.ps1 remove caveman, grill-me
.\install.ps1 remove --all
.\install.ps1 update
.\install.ps1 update caveman
```

### List All Installed Skills

Use the standalone `list-skills.sh` script to see all user-installed skills (hides system packages):

```bash
# Clone and run locally
git clone https://github.com/kolisachint/skills.git && cd skills
./list-skills.sh

# Or download and run directly
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/list-skills.sh | bash
```

**Shows:**
- Local project skills (`.claude/skills/`, `.pi/skills/`, etc.)
- Global user skills (`~/.claude/skills/`, `~/.pi/skills/`, etc.)
- User-installed npm packages (excludes npm, corepack, agent CLIs)
- Available CLI tools

**Hides system packages:** npm, corepack, @mariozechner/pi-coding-agent, @openai/codex, .system files

### Remove Command (Local + Global)

The remove command now cleans up skills from **both** your local project AND global user directories:

```bash
# Remove from everywhere
./install.sh remove caveman

# Output shows all locations:
# → caveman
#   Local: npx skills remove caveman --yes
#     ✓ Removed from local project
#   Global directories...
#     ✓ Removed from ~/.claude/skills: caveman
#     ✓ Removed from ~/.claude/skills: caveman-help
#     ✓ Removed from ~/.claude/skills: caveman-stats
#   NPM global packages...
#     ℹ No matching npm global packages
#
# ✓ Removal complete
```

**Global directories checked:**
- `~/.claude/skills/` and `~/.claude/commands/`
- `~/.pi/skills/`
- `~/.opencode/skills/` and `~/.opencode/command/`
- `~/.config/opencode/skills/` and `~/.config/opencode/command/`
- `~/.codex/skills/`
- `~/.gemini/commands/`
- `~/.github/copilot/skills/`

**Remove all skills everywhere:**
```bash
./install.sh remove --all
```

## Curated Components

### ⚡ Workflows

| Name | Platform | Description |
|------|----------|-------------|
| **superpowers** | all | Complete TDD and methodology framework *(90K★)* |

### 🧠 Skills

| Name | Platform | Description |
|------|----------|-------------|
| **agent-skills** | all | Production engineering from Google's culture *(20K+★)* |

### 🎯 Commands

| Name | Platform | Description |
|------|----------|-------------|
| **caveman** | all | Ultra-compressed communication *(52K★)* |
| **grill-me** | all | One-question-at-a-time interrogation *(31K★)* |
| **plannotator** | all | Visual plan and diff review *(5K★)* |

### 🔧 Tools

| Name | Platform | Description |
|------|----------|-------------|
| **codeburn** | all | Interactive TUI for token/cost observability *(4.6K★)* |

---

## Installation Dimensions

Every installation can be filtered across five dimensions:

1. **Category** — `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
2. **Platform** — `opencode`, `pi`, `copilot`, `codex`, `claude`
3. **Agent Target** — `all` or a specific agent/platform name
4. **Skill** — specific component name(s), comma-separated for multiple
5. **Scope** — `local` (default) or `all`

Plus two favorites dimensions:

6. **From** — a `favorites.tsv` file (`--from favorites.tsv`)
7. **Tag** — filter favorites by tag (`--tag daily-driver,critical`)

### Repo-Local by Default

This skillkit is **repo-local by default**. It only catalogs tools that install
inside your target directory (e.g. `npx skills add`, `npm install`).
Global-only tools are excluded.

Use `--platform` to filter the catalog by platform compatibility. The actual
platform directories (`.pi/`, `.claude/`, etc.) are managed by `npx skills`.

### Platform Compatibility

Commands are automatically transformed for your target platform:

| Platform | Command Transform | Status |
|----------|------------------|--------|
| **OpenCode** | `npx skills add repo` → `npx skills add repo -a opencode -g -y` | ✅ Fully supported |
| **Pi** | `npx skills add repo` → `pi install https://github.com/repo` | ✅ Fully supported |
| **Claude** | `npx skills add repo` → `npx skills add repo --yes` | ✅ Fully supported |
| **Codex** | `npx skills add repo` → `codex skills add <skill-name>` | ✅ Supported (transformed) |
| **Copilot** | Not supported via CLI | ⚠️ See [docs/REFERENCES.md](docs/REFERENCES.md) |

**Example:**
```bash
# Install superpowers workflow for OpenCode
./install.sh --target ~/repo --platform opencode --skill superpowers

# Install for Pi (transforms to pi install)
./install.sh --target ~/repo --platform pi --skill superpowers

# Copilot requires manual setup
./install.sh --target ~/repo --platform copilot --skill superpowers
# → ⚠️ UNSUPPORTED: Copilot doesn't support npx skills installation.
```

---

## What Gets Installed

This repo is a thin wrapper around `npx skills`. Each component's install
command runs directly in your target directory:

- `npx skills add <repo>` — installs to `.agents/skills/` and creates
  platform-specific symlinks (`.pi/skills/`, `.claude/skills/`, etc.)
- `npm install <pkg>` — installs to `node_modules/`; skills are copied to
  `.agents/skills/` automatically

Everything stays inside your target directory. If you delete the repo, the
skills are gone. No files are written to `~/.claude`, `~/.config`, or other
home directory paths.

---

## Curating Favorites

Use `favorites.tsv` to maintain your personal shortlist:

```tsv
name	category	platforms	tags	source
superpowers	workflow	all	daily-driver	external
agent-skills	skill	all	daily-driver	external
```

**Tags:**
- `daily-driver` — install on every project
- `occasional` — rare but important
- `critical` — required for specific project types (e.g., `frontend-critical`)

**Guideline:** Scrutinize before adding. Models evolve fast — only keep components that provide durable value beyond what base models can do.

## Component Catalog

All components are defined in `catalog.tsv` — a single tab-separated file that
serves as the source of truth. Each component has:

- **Name** — identifier
- **Category** — `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
- **Source** — `external` (from GitHub or npm)
- **Platforms** — `all` or comma-separated platform list
- **Agent Target** — `all` or specific agent/platform name
- **Description** — what it does
- **Install command** — how to install external components
- **Stars** — GitHub star count (for external components)

---

## Philosophy

This is a **curated distribution**, not a collection. See [PHILOSOPHY.md](PHILOSOPHY.md)
for the complete manifesto on why we made specific choices.

Core beliefs:
1. **Humans remain in control** — AI amplifies judgment, doesn't replace it
2. **Explicit is better than implicit** — No magic, no hidden behavior
3. **Context is scarce** — Every component must earn its place
4. **Vendor agnosticism** — Works across platforms (OpenCode, Pi, Copilot, Codex, Claude)
5. **Progressive disclosure** — Start simple, add complexity only when needed
6. **Agent specificity** — Generic defaults with precise overrides for specific agents

---

## Files

| File | Purpose |
|------|---------|
| `install.sh` | One-shot installer (can be curled) |
| `install.ps1` | One-shot installer for Windows |
| `catalog.tsv` | Single source of truth for all components |
| `PHILOSOPHY.md` | Curator's manifesto and design principles |
| `docs/WHY_THESE_TOOLS.md` | Comparison with alternatives |
| `docs/REFERENCES.md` | Platform documentation links |
| `MIGRATION.md` | Upgrade guide from previous versions |
| `favorites.tsv` | Personal shortlist for batch install |
| `install.sh` | Unified CLI for macOS/Linux |
| `install.ps1` | Unified CLI for Windows |
