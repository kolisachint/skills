# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Quick Start

All commands work via **curl** (no clone needed) or locally after cloning.

---

### 1. List Installed Skills

See what skills you already have across all agents:

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/list | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/kolisachint/skills/main/list | iex
```

**Or clone and run locally:**
```bash
git clone https://github.com/kolisachint/skills.git && cd skills
./list
```

**Shows:** Local project skills, global user skills, npm packages, CLI tools  
**Hides:** System packages (npm, corepack, agent CLIs)

#### Generate README Table

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/list | bash -s -- --format readme

# Windows
irm https://raw.githubusercontent.com/kolisachint/skills/main/list | iex -format readme
```

---

### 2. Install Skills

Install from catalog or directly from GitHub:

**From catalog (macOS / Linux):**
```bash
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- caveman
```

**From catalog (Windows):**
```powershell
irm https://raw.githubusercontent.com/kolisachint/skills/main/install | iex -skill caveman
```

**Direct from GitHub (any repo):**
```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- --direct owner/repo

# Windows
irm https://raw.githubusercontent.com/kolisachint/skills/main/install | iex -direct owner/repo
```

**With platform-specific installation:**
```bash
# macOS / Linux — install for Copilot
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- --platform copilot --direct obra/superpowers

# Windows — install for Copilot
irm https://raw.githubusercontent.com/kolisachint/skills/main/install | iex -platform copilot -direct obra/superpowers
```

**Or clone locally:**
```bash
git clone https://github.com/kolisachint/skills.git && cd skills
./install caveman                          # from catalog
./install --direct owner/repo              # from GitHub
./install --platform pi --direct owner/repo # platform-specific
./install --category workflow              # install category
```

---

### 3. Remove Skills

Remove from **both** local project AND global directories:

**macOS / Linux:**
```bash
# Remove single skill
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/remove | bash -s -- caveman

# Remove multiple
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/remove | bash -s -- caveman grill-me

# Remove ALL skills everywhere
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/remove | bash -s -- --all
```

**Windows:**
```powershell
# Remove single skill
irm https://raw.githubusercontent.com/kolisachint/skills/main/remove | iex -skill caveman

# Remove ALL skills everywhere
irm https://raw.githubusercontent.com/kolisachint/skills/main/remove | iex -all
```

**Or clone locally:**
```bash
./remove caveman              # remove single
./remove caveman grill-me     # remove multiple
./remove --all                # remove everything
./remove --platform copilot caveman  # remove from specific platform
```

**Output shows all locations:**
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

---

### 4. Add Skill to Catalog

Add a new skill to `catalog.tsv`:

**macOS / Linux:**
```bash
# Quick add with GitHub repo
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/add | bash -s -- my-skill --github owner/repo --category skill

# With npm package
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/add | bash -s -- my-tool --npm my-package --category tool

# Interactive mode (prompts for fields)
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/add | bash -s -- my-skill
```

**Windows:**
```powershell
# Quick add with GitHub repo
irm https://raw.githubusercontent.com/kolisachint/skills/main/add | iex -name my-skill -github owner/repo -category skill
```

**Or clone locally (recommended for editing):**
```bash
git clone https://github.com/kolisachint/skills.git && cd skills
./add my-skill --github owner/repo --category skill
./add my-tool --npm my-package --category tool --stars 1K
./add my-skill  # interactive mode
```

---

### 5. Discover & Search

**Browse the catalog:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- list
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- search review
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install | bash -s -- top 5

# Windows
irm https://raw.githubusercontent.com/kolisachint/skills/main/install | iex -command list
irm https://raw.githubusercontent.com/kolisachint/skills/main/install | iex -command search -keyword review
```

**Or locally:**
```bash
./install list              # all components
./install list-categories   # by category
./install search review     # search
./install top 5             # top starred
```

---

## Curated Components

Current catalog: 6 components across 4 categories.

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
- `critical` — required for specific project types

**Batch install from favorites:**
```bash
./install --target ~/repo --from favorites.tsv --tag daily-driver
```

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
| **Copilot** | `npx skills add repo` → `gh copilot -- plugin install repo` | ✅ Supported (requires [gh CLI](https://cli.github.com/)) |

**Example:**
```bash
# Install superpowers workflow for OpenCode
./install --target ~/repo --platform opencode --skill superpowers

# Install for Pi (transforms to pi install)
./install --target ~/repo --platform pi --skill superpowers

# Install for Copilot (requires 'gh' CLI with Copilot extension)
./install --target ~/repo --platform copilot --skill superpowers
# → Transforms to: gh copilot -- plugin install obra/superpowers
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

**Documentation:**
- [docs/CATALOG_FORMAT.md](docs/CATALOG_FORMAT.md) — Format details and platform transforms
- [docs/SKILL_SOURCES.md](docs/SKILL_SOURCES.md) — Actual installation commands from READMEs
- [docs/REFERENCES.md](docs/REFERENCES.md) — Platform documentation links

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
| `install` | Install skills (Bash) |
| `remove` | Remove skills (Bash) |
| `list` | List installed skills (Bash) |
| `add` | Add skill to catalog (Bash) |
| `install.ps1` | Install skills (PowerShell) |
| `remove.ps1` | Remove skills (PowerShell) |
| `list.ps1` | List installed skills (PowerShell) |
| `add.ps1` | Add skill to catalog (PowerShell) |
| `catalog.tsv` | Single source of truth for all components |
| `favorites.tsv` | Personal shortlist for batch install |
| `AGENTS.md` | Project-specific agent instructions |
| `PHILOSOPHY.md` | Curator's manifesto and design principles |
| `docs/CATALOG_FORMAT.md` | TSV format and platform transform docs |
| `docs/SKILL_SOURCES.md` | Installation commands from READMEs |
| `docs/REFERENCES.md` | Platform documentation links |
