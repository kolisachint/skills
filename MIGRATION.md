# Migration Guide: External Skills

## What Changed

Starting with this version, five skills have been moved from bundled local copies
to external dependencies sourced from their actively maintained GitHub repositories:

| Skill | Old Location | New Source | Install Command |
|-------|--------------|------------|-----------------|
| `caveman` | `skills/caveman/` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `npx skills add JuliusBrussee/caveman` |
| `grill-me` | `skills/grill-me/` | [mattpocock/skills](https://github.com/mattpocock/skills) | `npx skills add mattpocock/skills --skill grill-me` |
| `codeburn` | `skills/codeburn/` | [AgentSeal/CodeBurn](https://github.com/AgentSeal/CodeBurn) | `npm install -g codeburn` |
| `plannotator` | `skills/plannotator/` | [backnotprop/plannotator](https://github.com/backnotprop/plannotator) | `curl -s https://plannotator.ai/install.sh \| sh` |
| `context-audit` | `skills/context-audit/` | [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit) | `npm install -g ctxaudit` |

## Why This Change?

These five skills have thriving open-source ecosystems with:
- **Active development** with regular updates and bug fixes
- **CLI tools and integrations** beyond simple markdown files
- **Auto-installers** for 30+ different AI coding agents
- **Community contributions** from hundreds of developers

By sourcing them externally:
1. You always get the latest features and fixes
2. We eliminate the maintenance burden of keeping copies in sync
3. The core skillkit stays focused on its unique value proposition
4. You get full-featured tools instead of simplified guidelines

## What You Need to Do

### If You Were Using These Skills

Install the external versions:

```bash
# macOS/Linux
./scripts/install-external.sh

# Windows PowerShell
.\scripts\install-external.ps1
```

Or install specific skills:

```bash
./scripts/install-external.sh --skills caveman,grill-me
```

### If You Have Existing Projects

Your existing projects with the old bundled skills will continue to work, but
to get the latest features, install the external versions in those projects:

```bash
cd /path/to/your/project
/path/to/skillkit/scripts/install-external.sh
```

## What Stayed the Same

Three core skills remain bundled in this repository:

- **`control-first`**: The default workflow framework (unique to this project)
- **`pi-coding-agent`**: Pi harness documentation (not replaceable)
- **`local-inference`**: Curated best practices guide (aggregate of scattered info)

## What You Gain

### Caveman (JuliusBrussee/caveman)
- 5 intensity levels (lite, full, ultra, wenyan-*)
- `/caveman` command for mode switching
- `/caveman-commit` for terse commits
- `/caveman-review` for one-line PR comments
- `/caveman:compress` for memory file compression
- Auto-activation hooks for Claude/Codex/Gemini

### Grill-Me (mattpocock/skills)
- Decision-tree traversal with dependency resolution
- Recommendation-first answers
- Codebase-first approach
- `/grill-with-docs` with ADR integration
- `/setup-matt-pocock-skills` ecosystem

### CodeBurn (AgentSeal/CodeBurn)
- Interactive TUI dashboard
- 13-category task classification
- One-shot success rate tracking
- Multi-provider support (Claude/Codex/Cursor/Pi/Opencode)
- CSV/JSON export
- Native macOS menubar app

### Plannotator (backnotprop/plannotator)
- Visual plan review UI in browser
- Plan diff between versions
- Code review with inline annotations
- Claude/Codex/Pi/Opencode/Gemini plugins
- Private sharing via URL compression
- Obsidian integration

### Context Audit (sanjeed5/ctxaudit)
- Automated scanning of agent config files
- Token counting per file and category
- Startup vs full context analysis
- Machine-readable output for CI integration

## Troubleshooting

### "command not found: npx"

Install Node.js from [nodejs.org](https://nodejs.org) first.

### "permission denied" on install-external.sh

Make it executable:
```bash
chmod +x ./scripts/install-external.sh
```

### curl not available on Windows

Use PowerShell instead:
```powershell
.\scripts\install-external.ps1
```

### External install fails behind corporate proxy

Install manually using the commands listed in the README.md.

## Questions?

See the component documentation in `components/` for each external tool:
- `components/caveman.md`
- `components/grill-me.md`
- `components/codeburn.md`
- `components/plannotator.md`
- `components/context-audit.md`
