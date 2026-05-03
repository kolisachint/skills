# Portable AI Skillkit

Portable setup for sharing the same coding-agent skills across Codex, Claude Code,
opencode, GitHub Copilot coding agent, and Pi-style project folders.

The goal is to keep one source of truth in this repo, then install either all
skills or selected skills into any project.

## Quick Start

### macOS Terminal

Install every skill and every supported adapter into another repo:

```sh
./scripts/install.sh --target /path/to/project
```

Install only selected skills:

```sh
./scripts/install.sh --target /path/to/project --skills grill-me,caveman
```

Install only selected agent adapters:

```sh
./scripts/install.sh --target /path/to/project --agents codex,claude,opencode
```

List available skills:

```sh
./scripts/skillkit.sh list
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

Install every skill and every supported adapter into another repo:

```powershell
.\scripts\install.ps1 --target C:\code\project
```

Install only selected skills:

```powershell
.\scripts\install.ps1 --target C:\code\project --skills grill-me,caveman
```

Install only selected agent adapters:

```powershell
.\scripts\install.ps1 --target C:\code\project --agents codex,claude,opencode
```

List available skills and stack components:

```powershell
.\scripts\skillkit.ps1 list
.\scripts\skillkit.ps1 list-components
```

Export a portable bundle:

```powershell
.\scripts\export.ps1 --output dist\portable-ai-skillkit
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

## Included Skills

- `pi-coding-agent`: Pi as the thin terminal harness
- `control-first`: default workflow for clarify, plan, patch, test, review
- `grill-me`: one-question-at-a-time requirement interrogation
- `caveman`: terse output discipline without harming code quality
- `plannotator`: plan and diff review workflow for visual/annotated review
- `codeburn`: token and cost observability habits
- `context-audit`: context bloat, stale instruction, and drift review
- `local-inference`: when and how to use Ollama/LM Studio safely

## Control-First Stack Components

| Component | Role | Skillkit mapping |
|---|---|---|
| Pi Coding Agent | Core terminal harness | `pi-coding-agent`, `.pi/skills/*` |
| LM Studio / Ollama | Local inference server | `local-inference` |
| Grill-Me | Requirement interrogation | `grill-me` |
| Plannotator | Visual plan and diff review | `plannotator` |
| Caveman | Output token compression | `caveman` |
| CodeBurn | Cost and token observability | `codeburn` |
| Context Audit | Context hygiene and instruction drift review | `context-audit` |

These are portable workflow skills, not vendored third-party packages. If a
specific external tool is installed in a target repo, the relevant skill tells
the coding agent how to use it. If the tool is absent, the agent falls back to
the same workflow in plain text.
