# Portable AI Skillkit

Curated components for coding agents, organized by how you use them.

## Quick Start

### macOS

```bash
# Install everything
./scripts/skillkit.sh install --target ~/repo

# Or install by category
./scripts/skillkit.sh install --target ~/repo --category workflow
./scripts/skillkit.sh install --target ~/repo --source bundled
```

### Windows

```powershell
# Install everything
.\scripts\skillkit.ps1 install --target C:\code\repo

# Or install by category
.\scripts\skillkit.ps1 install --target C:\code\repo --category workflow
.\scripts\skillkit.ps1 install --target C:\code\repo --source bundled
```

### See What's Available

```bash
# List all components grouped by category
./scripts/skillkit.sh list

# List categories only
./scripts/skillkit.sh list-categories
```

## Curated Components

### ⚡ Workflows (how you structure work)

1. **control-first** — Default workflow: clarify, plan, patch, test, review *(bundled)*
2. **superpowers** — Complete TDD and methodology framework *(external, 90K★)*
3. **agent-skills** — Production engineering from Google's culture *(external, 20K+★)*

### 🎯 Commands (interactive modes)

1. **caveman** — Ultra-compressed communication, 75% token reduction *(external, 52K★)*
2. **grill-me** — One-question-at-a-time requirement interrogation *(external, 31K★)*
3. **plannotator** — Visual plan and diff review *(external, 5K★)*

### 🔧 Tools (monitoring & analysis)

1. **codeburn** — Interactive TUI dashboard for token/cost observability *(external, 4.6K★)*
2. **context-audit** — Context bloat detection and instruction drift monitoring *(external)*
3. **local-inference** — Route tasks through local inference servers *(bundled)*

### 🤖 Agents (execution harnesses)

1. **pi-coding-agent** — Pi as the thin terminal harness for coding agents *(bundled)*

---

## Installation Guide

### Install Everything

Installs all bundled and external components:

**macOS:**
```bash
./scripts/skillkit.sh install --target ~/repo
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 install --target C:\code\repo
```

### Install by Category

Install only workflow components:

**macOS:**
```bash
./scripts/skillkit.sh install --target ~/repo --category workflow
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 install --target C:\code\repo --category workflow
```

Available categories: `workflow`, `command`, `tool`, `agent`

### Install by Source

Install only bundled (local) components:

**macOS:**
```bash
./scripts/skillkit.sh install --target ~/repo --source bundled
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 install --target C:\code\repo --source bundled
```

Install only external components:

**macOS:**
```bash
./scripts/skillkit.sh install --target ~/repo --source external
```

**Windows:**
```powershell
.\scripts\skillkit.ps1 install --target C:\code\repo --source external
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

When you run the install command, these files are created in your target project:

- `.ai/skillkit/skills/*.md` — Skill definitions
- `.ai/skillkit/AGENTS.md` — Shared instruction index
- `AGENTS.md` — Project adapter for agents that read `AGENTS.md`
- `CLAUDE.md` — Claude Code adapter
- `.github/copilot-instructions.md` — GitHub Copilot adapter
- `.opencode/AGENTS.md` — opencode adapter
- `.codex/skills/*/SKILL.md` — Codex native skill folders
- `.pi/skills/*/SKILL.md` — Pi-style skill folders

Existing instruction files are preserved. The installer updates only a managed
block marked with `BEGIN AI SKILLKIT` and `END AI SKILLKIT`.

---

## Component Catalog

All components are defined in `catalog.tsv` — a single tab-separated file that
serves as the source of truth. Each component has:

- **Name** — identifier
- **Category** — workflow, command, tool, or agent
- **Source** — bundled (maintained here) or external (from GitHub)
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
4. **Vendor agnosticism** — Works across platforms
5. **Progressive disclosure** — Start simple, add complexity only when needed

---

## Files

| File | Purpose |
|------|---------|
| `catalog.tsv` | Single source of truth for all components |
| `PHILOSOPHY.md` | Curator's manifesto and design principles |
| `docs/WHY_THESE_TOOLS.md` | Comparison with alternatives |
| `MIGRATION.md` | Upgrade guide from previous versions |
| `skills/` | Bundled skill definitions (3 skills) |
| `scripts/skillkit.sh` | Unified CLI for macOS/Linux |
| `scripts/skillkit.ps1` | Unified CLI for Windows |
