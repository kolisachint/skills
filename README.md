# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Quick Start

### 1. See What's Already Installed

First, check what skills you already have across all your agents:

```bash
# macOS / Linux — see all user-installed skills (hides system packages)
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/list-skills.sh | bash
```

**Windows:**
```powershell
# Clone and run locally
irm https://raw.githubusercontent.com/kolisachint/skills/main/list-skills.ps1 | iex
```

**Shows:** Local project skills, global user skills, npm packages, CLI tools  
**Hides:** System packages (npm, corepack, agent CLIs)

---

### 2. Install from Catalog

```bash
# macOS / Linux — install a specific skill
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- caveman

# Or install multiple skills
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- caveman,grill-me

# Or clone and install locally
git clone https://github.com/kolisachint/skills.git && cd skills
./install.sh caveman              # one skill
./install.sh caveman grill-me     # multiple
./install.sh --category workflow  # by category
./install.sh --target ~/repo      # everything
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 | iex -caveman
```

---

### 3. Discover & Search

```bash
./install.sh list              # all components
./install.sh list-categories   # by category
./install.sh list-platforms    # by platform
./install.sh search review     # search
./install.sh top 5             # top starred
```

---

### 4. Remove Skills

Remove from **both** local project AND global directories:

```bash
# Remove a skill from everywhere
./install.sh remove caveman

# Remove multiple
./install.sh remove caveman grill-me

# Remove ALL skills everywhere
./install.sh remove --all
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

**Global directories checked:**
- `~/.claude/skills/` and `~/.claude/commands/`
- `~/.pi/skills/`
- `~/.opencode/skills/` and `~/.opencode/command/`
- `~/.config/opencode/skills/` and `~/.config/opencode/command/`
- `~/.codex/skills/`
- `~/.gemini/commands/`
- `~/.github/copilot/skills/`

---

### 5. Add New Skill to Catalog

To add a new skill to this catalog, edit `catalog.tsv`:

```bash
# Clone the repo
git clone https://github.com/kolisachint/skills.git && cd skills

# Edit the catalog
vim catalog.tsv  # or use your preferred editor
```

**Add a new row with these columns:**

```tsv
name	category	source	platforms	agent_target	description	install_command	stars	remove_command	docs_url
```

**Example entry:**
```tsv
my-skill	skill	external	all	all	My custom skill description	npx skills add owner/my-skill --yes	1K	npx skills remove my-skill --yes	https://github.com/owner/my-skill
```

**Field descriptions:**
| Field | Example | Notes |
|-------|---------|-------|
| `name` | `my-skill` | Unique identifier, kebab-case |
| `category` | `skill` | One of: skill, prompt, command, tool, agent, workflow |
| `source` | `external` | `external` for GitHub/npm, `local` for custom |
| `platforms` | `all` | Comma-separated: all, opencode, pi, copilot, codex, claude |
| `agent_target` | `all` | Which agent this targets |
| `description` | Short text | Max ~100 chars |
| `install_command` | `npx skills add...` | Neutral form; transforms per platform |
| `stars` | `1K` | GitHub star count (optional) |
| `remove_command` | `npx skills remove...` | How to uninstall |
| `docs_url` | `https://github.com/...` | Link to README |

**Then commit and push:**
```bash
git add catalog.tsv
git commit -m "Add my-skill to catalog"
git push origin
```

See `docs/CATALOG_FORMAT.md` for full details on platform transforms and format.

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
./install.sh --target ~/repo --from favorites.tsv --tag daily-driver

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
| `install.sh` | One-shot installer for macOS/Linux (can be curled) |
| `install.ps1` | One-shot installer for Windows |
| `list-skills.sh` | List all installed skills (local + global) |
| `catalog.tsv` | Single source of truth for all components |
| `favorites.tsv` | Personal shortlist for batch install |
| `AGENTS.md` | Project-specific agent instructions |
| `PHILOSOPHY.md` | Curator's manifesto and design principles |
| `docs/CATALOG_FORMAT.md` | TSV format and platform transform docs |
| `docs/SKILL_SOURCES.md` | Installation commands from READMEs |
| `docs/REFERENCES.md` | Platform documentation links |
