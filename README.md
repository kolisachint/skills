# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Quick Start

### Option 1: Download then Run (Recommended)

Save the installer to disk first so it can locate its helper scripts correctly.

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh -o install.sh
chmod +x install.sh
./install.sh --target ~/repo
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 -OutFile install.ps1
.\install.ps1 --target C:\code\repo
```

**With filters:**
```bash
# macOS / Linux — only workflow components for Codex
./install.sh --target ~/repo --category workflow --agent-target codex

# Windows — only workflow components for Codex
.\install.ps1 --target C:\code\repo --category workflow --agent-target codex
```

### Option 2: Bootstrap from Favorites

Curate your most-used components in `favorites.tsv`, then batch-install:

```bash
# macOS / Linux — install everything tagged "daily-driver" or "critical"
./scripts/skillkit.sh install --target ~/repo --from favorites.tsv --tag daily-driver,critical

# macOS / Linux — install all favorites (no tag filter)
./scripts/skillkit.sh install --target ~/repo --from favorites.tsv

# macOS / Linux — via Make
make bootstrap-ai TARGET=~/repo

# Windows — install everything tagged "daily-driver" or "critical"
.\scripts\skillkit.ps1 install --target C:\code\repo --from favorites.tsv --tag daily-driver,critical

# Windows — install all favorites (no tag filter)
.\scripts\skillkit.ps1 install --target C:\code\repo --from favorites.tsv
```

### Option 3: Manual Install (one at a time)

**1. Clone**
```bash
git clone https://github.com/kolisachint/skills.git && cd skills
```

**2. Install a specific component by name**
```bash
# macOS / Linux
./scripts/skillkit.sh install --target ~/repo --skill caveman

# Windows
.\scripts\skillkit.ps1 install --target C:\code\repo --skill caveman
```

**3. Install multiple components by name**
```bash
# macOS / Linux
./scripts/skillkit.sh install --target ~/repo --skill caveman,grill-me

# Windows
.\scripts\skillkit.ps1 install --target C:\code\repo --skill caveman,grill-me
```

**4. Install with filters**
```bash
# macOS / Linux
./scripts/skillkit.sh install --target ~/repo --category workflow
./scripts/skillkit.sh install --target ~/repo --platform pi
./scripts/skillkit.sh install --target ~/repo --agent-target codex

# Windows
.\scripts\skillkit.ps1 install --target C:\code\repo --category workflow
.\scripts\skillkit.ps1 install --target C:\code\repo --platform pi
.\scripts\skillkit.ps1 install --target C:\code\repo --agent-target codex
```

**5. Install everything**
```bash
# macOS / Linux
./scripts/skillkit.sh install --target ~/repo

# Windows
.\scripts\skillkit.ps1 install --target C:\code\repo
```

---

## Discover & Search

```bash
# macOS / Linux
./scripts/skillkit.sh list
./scripts/skillkit.sh list-categories
./scripts/skillkit.sh list-platforms
./scripts/skillkit.sh search review
./scripts/skillkit.sh search codex
./scripts/skillkit.sh search debug
./scripts/skillkit.sh top        # default top 10
./scripts/skillkit.sh top 5      # top 5 only

# Windows
.\scripts\skillkit.ps1 list
.\scripts\skillkit.ps1 list-categories
.\scripts\skillkit.ps1 list-platforms
.\scripts\skillkit.ps1 search review
.\scripts\skillkit.ps1 search codex
.\scripts\skillkit.ps1 search debug
.\scripts\skillkit.ps1 top
.\scripts\skillkit.ps1 top 5
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
| **context-audit** | all | Context bloat and instruction drift monitoring |

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

This skillkit is **repo-local by default**. It installs everything that can
live inside your target directory. Only repo-safe tools
(e.g. `npx skills add` which creates `.agents/skills/` locally) are included.

External skills that require global or user-level installation (e.g.
`npm install -g`, `curl | sh` that writes to home directories) are
automatically skipped with a warning. Only repo-safe external skills
(e.g. `npx skills add` which creates `.agents/skills/` locally) are included.

Everything lives inside your target directory. If you delete the repo, the
skills are gone. No files are written to `~/.claude`, `~/.config`, or other
home directory paths.

When platform directories already exist in the target, the installer
auto-detects them. Use `--platform` to force installation to a specific
platform even if its directory doesn't exist yet.

---

## What Gets Installed

### Shared (all installations)

- `.ai/skillkit/skills/*.md` — Skill definitions
- `.ai/skillkit/prompts/*.md` — Prompt templates
- `.ai/skillkit/commands/*.md` — Command definitions
- `.ai/skillkit/agents/*.md` — Agent definitions
- `.ai/skillkit/workflows/*.md` — Workflow definitions
- `.ai/skillkit/AGENTS.md` — Shared instruction index

### Platform-Specific (when detected or forced)

| Platform | Skills | Agent Configs | Index |
|----------|--------|---------------|-------|
| **Pi** | `.pi/skills/*.md` | `.pi/agents/*` | `.pi/AGENTS.md` |
| **OpenCode** | `.opencode/skills/*.md` | `.opencode/agents/*` | `.opencode/AGENTS.md` |
| **Copilot** | `.github/copilot-skills/*.md` | `.github/copilot-agents/*` | `.github/copilot-instructions.md` |
| **Codex** | `.codex/skills/*.md` | `.codex/agents/*` | `.codex/AGENTS.md` |
| **Claude** | `.claude/skills/*.md` | `.claude/agents/*` | `.claude/AGENTS.md` |

Existing instruction files are preserved. The installer updates only managed
blocks marked with `BEGIN AI SKILLKIT` and `END AI SKILLKIT`.

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
| `scripts/skillkit.sh` | Unified CLI for macOS/Linux |
| `scripts/skillkit.ps1` | Unified CLI for Windows |
