# Portable AI Skillkit

Curated components for coding agents, organized by how you use them, where you use them, and who they're for.

## Quick Start

### macOS / Linux

```bash
# Install everything
./scripts/skillkit.sh install --target ~/repo

# Or install with precise filters
./scripts/skillkit.sh install --target ~/repo --source internal --category workflow
./scripts/skillkit.sh install --target ~/repo --platform pi
./scripts/skillkit.sh install --target ~/repo --agent-target codex
```

### Windows

```powershell
# Install everything
.\scripts\skillkit.ps1 install --target C:\code\repo

# Or install with precise filters
.\scripts\skillkit.ps1 install --target C:\code\repo --source internal --category workflow
.\scripts\skillkit.ps1 install --target C:\code\repo --platform pi
.\scripts\skillkit.ps1 install --target C:\code\repo --agent-target codex
```

### See What's Available

```bash
# List all components grouped by category & source
./scripts/skillkit.sh list

# List categories only
./scripts/skillkit.sh list-categories

# List platforms and their component counts
./scripts/skillkit.sh list-platforms

# Search by keyword (name, description, category, agent target)
./scripts/skillkit.sh search review

# Top starred external skills
./scripts/skillkit.sh top 5
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

## Installation Guide

### Dimensions

Every installation can be filtered across four dimensions:

1. **Source** — `internal` (from this repo) or `external` (third-party)
2. **Category** — `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
3. **Platform** — `opencode`, `pi`, `copilot`, `codex`, `claude`
4. **Agent Target** — `all` or a specific agent/platform name

### Install Everything

Installs all internal and external components:

**macOS:**
```bash
./scripts/skillkit.sh install --target ~/repo
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 install --target C:\code\repo
```

### Install by Source

Internal only (no external CLI tools installed):

```bash
./scripts/skillkit.sh install --target ~/repo --source internal
```

External only:

```bash
./scripts/skillkit.sh install --target ~/repo --source external
```

### Install by Category

```bash
./scripts/skillkit.sh install --target ~/repo --category workflow
./scripts/skillkit.sh install --target ~/repo --category agent
./scripts/skillkit.sh install --target ~/repo --category prompt
```

### Install by Platform

Install only components compatible with a specific platform:

```bash
./scripts/skillkit.sh install --target ~/repo --platform pi
./scripts/skillkit.sh install --target ~/repo --platform codex
./scripts/skillkit.sh install --target ~/repo --platform copilot
```

When platform directories already exist in the target, the installer
auto-detects them. Use `--platform` to force installation to a specific
platform even if its directory doesn't exist yet.

### Install by Agent Target

Install only agent-specific workflows:

```bash
./scripts/skillkit.sh install --target ~/repo --agent-target codex
./scripts/skillkit.sh install --target ~/repo --agent-target copilot
```

### Combine Filters

```bash
# Internal workflows only
./scripts/skillkit.sh install --target ~/repo --source internal --category workflow

# Codex-specific agents and workflows
./scripts/skillkit.sh install --target ~/repo --platform codex --agent-target codex

# Copilot agents only
./scripts/skillkit.sh install --target ~/repo --category agent --platform copilot
```

### Search & Discover

When you're not sure what's available or want to find the best-rated skills:

```bash
# Search by keyword (matches name, description, category, agent target)
./scripts/skillkit.sh search review
./scripts/skillkit.sh search codex
./scripts/skillkit.sh search debug

# Top-N starred external components
./scripts/skillkit.sh top        # default top 10
./scripts/skillkit.sh top 5      # top 5 only
```

### Export a Portable Bundle

**macOS:**
```bash
./scripts/skillkit.sh export --output ./dist
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 export --output .\dist
```

---

## What Gets Installed

When you run the install command, files are created in your target project:

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
| `catalog.tsv` | Single source of truth for all components |
| `PHILOSOPHY.md` | Curator's manifesto and design principles |
| `docs/WHY_THESE_TOOLS.md` | Comparison with alternatives |
| `MIGRATION.md` | Upgrade guide from previous versions |
| `skills/` | Internal component definitions |
| `scripts/skillkit.sh` | Unified CLI for macOS/Linux |
| `scripts/skillkit.ps1` | Unified CLI for Windows |
