# Portable AI Skillkit

Portable setup for sharing the same coding-agent skills across Codex, Claude Code,
opencode, GitHub Copilot coding agent, and Pi-style project folders.

The goal is to keep one source of truth in this repo for core workflow skills,
while leveraging actively maintained external tools for specialized capabilities.

## Quick Start

### macOS Terminal

Install every **core** skill and every supported adapter into another repo:

```sh
./scripts/install.sh --target /path/to/project
```

Install **external** skills from actively maintained GitHub repos:

```sh
./scripts/install-external.sh
```

Install only selected skills:

```sh
./scripts/install.sh --target /path/to/project --skills control-first,pi-coding-agent
```

Install only selected agent adapters:

```sh
./scripts/install.sh --target /path/to/project --agents codex,claude,opencode
```

List available skills:

```sh
./scripts/skillkit.sh list
```

List external skills available from GitHub:

```sh
./scripts/skillkit.sh list-external
```

List stack components:

```sh
./scripts/skillkit.sh list-components
```

Export a portable bundle:

```sh
./scripts/export.sh --output dist/portable-ai-skillkit
```

### Windows PowerShell 7

Install every **core** skill and every supported adapter into another repo:

```powershell
.\scripts\install.ps1 --target C:\code\project
```

Install **external** skills from actively maintained GitHub repos:

```powershell
.\scripts\install-external.ps1
```

Install only selected skills:

```powershell
.\scripts\install.ps1 --target C:\code\project --skills control-first,pi-coding-agent
```

List external skills:

```powershell
.\scripts\skillkit.ps1 list-external
```

## What Gets Installed

- `.ai/skillkit/skills/*.md`: portable Markdown skill copies
- `.ai/skillkit/AGENTS.md`: shared source-of-truth instruction index
- `.ai/skillkit/stacks/control-first.md`: the full control-first stack map
- `.ai/skillkit/components/*.md`: component-specific role and usage notes
- `AGENTS.md`: shared project adapter for agents that read `AGENTS.md`
- `CLAUDE.md`: Claude Code adapter importing the shared instructions
- `.github/copilot-instructions.md`: GitHub Copilot adapter
- `.opencode/AGENTS.md`: opencode adapter
- `.codex/skills/*/SKILL.md`: Codex native skill folders
- `.pi/skills/*/SKILL.md`: Pi-style skill folders

Existing instruction files are preserved. The installer updates only a managed
block marked with `BEGIN AI SKILLKIT` and `END AI SKILLKIT`.

## Core Skills (Bundled)

These skills are maintained in this repository:

- `control-first`: default workflow for clarify, plan, patch, test, review
- `pi-coding-agent`: Pi as the thin terminal harness
- `local-inference`: when and how to use Ollama/LM Studio safely

## External Skills (Install Separately)

These skills are sourced from actively maintained external repositories to ensure
you always have the latest features and bug fixes:

| Skill | Repository | Install Command | Description |
|-------|-----------|-----------------|-------------|
| `caveman` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `npx skills add JuliusBrussee/caveman` | Ultra-compressed communication mode - 75% token reduction |
| `grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills) | `npx skills add mattpocock/skills --skill grill-me` | One-question-at-a-time requirement interrogation |
| `codeburn` | [AgentSeal/CodeBurn](https://github.com/AgentSeal/CodeBurn) | `npm install -g codeburn` | Interactive TUI dashboard for token/cost observability |
| `plannotator` | [backnotprop/plannotator](https://github.com/backnotprop/plannotator) | `curl -s https://plannotator.ai/install.sh \| sh` | Visual plan and diff review with annotations |
| `context-audit` | [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit) | `npm install -g ctxaudit` | Context bloat detection and instruction drift monitoring |
| `superpowers` | [obra/superpowers](https://github.com/obra/superpowers) | `npx skills add obra/superpowers` | Complete TDD and development methodology framework (90K stars) |
| `agent-skills` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | `npx skills add addyosmani/agent-skills` | Production-grade engineering skills from Google's culture (20K+ stars) |

### Why External?

These seven skills have thriving open-source ecosystems with:
- Active development and community contributions
- CLI tools and integrations beyond simple markdown
- Auto-installers for 30+ agents
- Regular updates and bug fixes

By sourcing them externally, you get the full-featured versions without the
maintenance burden.

## Control-First Stack Components

| Component | Role | Source |
|---|---|---|
| Pi Coding Agent | Core terminal harness | `pi-coding-agent` (bundled) |
| LM Studio / Ollama | Local inference server | `local-inference` (bundled) |
| Grill-Me | Requirement interrogation | [mattpocock/skills](https://github.com/mattpocock/skills) |
| Plannotator | Visual plan and diff review | [backnotprop/plannotator](https://github.com/backnotprop/plannotator) |
| Caveman | Output token compression | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| CodeBurn | Cost and token observability | [AgentSeal/CodeBurn](https://github.com/AgentSeal/CodeBurn) |
| Context Audit | Context hygiene and instruction drift review | [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit) |
| Superpowers | Complete TDD and methodology framework | [obra/superpowers](https://github.com/obra/superpowers) |
| Agent-Skills | Production engineering from Google's culture | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| Control-First | Default workflow framework | `control-first` (bundled) |

## Migration from Previous Versions

If you were using the bundled versions of `caveman`, `grill-me`, `codeburn`,
`plannotator`, `context-audit`, `superpowers`, or `agent-skills`, run:

```sh
./scripts/install-external.sh
```

This will install the full-featured external versions that replace the
simplified bundled versions.

## Philosophy

This is a **curated distribution**, not a collection. See [PHILOSOPHY.md](PHILOSOPHY.md)
for the complete manifesto on why we made specific choices.

This repository maintains **core workflow frameworks** that are unique to this
project, while **importing specialized tools** from their canonical sources.
This approach:

1. Eliminates maintenance burden for skills with active external communities
2. Ensures users always have the latest features and bug fixes
3. Keeps the core skillkit focused on its unique value proposition
4. Reduces bundle size and installation time
5. Respects your intelligence—every choice is explained, nothing is hidden
