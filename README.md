# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Install in One Line

### macOS / Linux (curl — no clone needed)

```bash
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- --target ~/repo
```

Or with filters:
```bash
# Internal skills only (no external CLI tools)
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- --target ~/repo --source internal

# Only workflow components for Codex
curl -fsSL https://raw.githubusercontent.com/kolisachint/skills/main/install.sh | bash -s -- --target ~/repo --category workflow --agent-target codex
```

### Windows (PowerShell — no clone needed)

```powershell
irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 | iex
```

### Or clone and run

```bash
git clone https://github.com/kolisachint/skills.git /tmp/skills
bash /tmp/skills/install.sh --target ~/repo
```

---

## Quick Start (already cloned)

### Install everything

```bash
# macOS / Linux
./install.sh --target ~/repo

# Windows
.\install.ps1 --target C:\code\repo
```

### Install with filters

```bash
# Only internal components (fast, no external deps)
./install.sh --target ~/repo --source internal

# Only workflow components
./install.sh --target ~/repo --category workflow

# Only Pi-compatible components
./install.sh --target ~/repo --platform pi

# Only Codex-targeted agents/workflows
./install.sh --target ~/repo --agent-target codex

# Combined: internal workflows for Codex
./install.sh --target ~/repo --source internal --category workflow --platform codex
```

### Discover what's available

```bash
# List all components grouped by category & source
./scripts/skillkit.sh list

# List categories only
./scripts/skillkit.sh list-categories

# List platforms and their component counts
./scripts/skillkit.sh list-platforms

# Search by keyword (name, description, category, agent target)
./scripts/skillkit.sh search review
./scripts/skillkit.sh search codex
./scripts/skillkit.sh search debug

# Top-N starred external components
./scripts/skillkit.sh top        # default top 10
./scripts/skillkit.sh top 5      # top 5 only
```

## Curated Components

### ⚡ Workflows

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **control-first** | internal | all | Default workflow: clarify, plan, patch, test, review |
| **codex-reviewer** | internal | codex | Codex-specific code review subagent workflow |
| **superpowers** | external | all | Complete TDD and methodology framework *(90K★)* |

### 🧠 Skills

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **local-inference** | internal | all | Route tasks through local inference servers |
| **agent-skills** | external | all | Production engineering from Google's culture *(20K+★)* |

### 💬 Prompts

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **claude-research** | internal | claude | Deep research prompt template for Claude |

### 🎯 Commands

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **opencode-debug** | internal | opencode | Debug command with structured logging |
| **caveman** | external | all | Ultra-compressed communication *(52K★)* |
| **grill-me** | external | all | One-question-at-a-time interrogation *(31K★)* |
| **plannotator** | external | all | Visual plan and diff review *(5K★)* |

### 🔧 Tools

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **codeburn** | external | all | Interactive TUI for token/cost observability *(4.6K★)* |
| **context-audit** | external | all | Context bloat and instruction drift monitoring |

### 🤖 Agents

| Name | Source | Platform | Description |
|------|--------|----------|-------------|
| **pi-coding-agent** | internal | pi | Pi as the thin terminal harness |
| **copilot-pr-agent** | internal | copilot | Copilot custom PR review agent |

---

## Installation Dimensions

Every installation can be filtered across four dimensions:

1. **Source** — `internal` (from this repo) or `external` (third-party)
2. **Category** — `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
3. **Platform** — `opencode`, `pi`, `copilot`, `codex`, `claude`
4. **Agent Target** — `all` or a specific agent/platform name

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

## Component Catalog

All components are defined in `catalog.tsv` — a single tab-separated file that
serves as the source of truth. Each component has:

- **Name** — identifier
- **Category** — `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
- **Source** — `internal` (maintained here) or `external` (from GitHub)
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
| `skills/` | Internal component definitions |
| `scripts/skillkit.sh` | Unified CLI for macOS/Linux |
| `scripts/skillkit.ps1` | Unified CLI for Windows |
