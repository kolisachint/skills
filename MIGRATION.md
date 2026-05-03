# Migration Guide

## v2.0: Multi-Dimensional Catalog

### What Changed

The catalog and installer have been expanded from two dimensions to four:

| Dimension | Old Values | New Values |
|-----------|-----------|------------|
| **Source** | `bundled`, `external` | `internal`, `external` |
| **Category** | `workflow`, `command`, `tool`, `agent` | `skill`, `prompt`, `command`, `tool`, `agent`, `workflow` |
| **Platform** | — | `all`, `opencode`, `pi`, `copilot`, `codex`, `claude` |
| **Agent Target** | — | `all`, or specific agent name |

### Why This Change?

The previous system treated all local components as "bundled" and all third-party as "external", with only four coarse categories. The new system supports:

1. **Finer-grained categories**: `skill` (reusable knowledge), `prompt` (templates), `command` (interactive modes), `tool` (utilities), `agent` (harnesses), `workflow` (processes)
2. **Platform routing**: Components can declare which platforms they support. The installer copies them to the right directories (`.pi/skills/`, `.codex/skills/`, `.github/copilot-skills/`, etc.)
3. **Agent-specific workflows**: A component can target a specific agent (e.g., a Codex subagent workflow or a Copilot custom agent) and the installer routes it appropriately

### Catalog Schema Migration

Old format (8 columns):
```
name | category | source | description | install_command | stars
```

New format (8 columns):
```
name | category | source | platforms | agent_target | description | install_command | stars
```

**To migrate existing entries:**
1. Rename `bundled` → `internal` in the source column
2. Add `platforms` column after `source` (use `all` for existing entries)
3. Add `agent_target` column after `platforms` (use `all` for existing entries)

### CLI Changes

| Old Command | New Command |
|-------------|-------------|
| `skillkit.sh install --target ~/repo --source bundled` | `skillkit.sh install --target ~/repo --source internal` |
| `skillkit.sh install --target ~/repo --source external` | `skillkit.sh install --target ~/repo --source external` |
| `skillkit.sh install --target ~/repo --category workflow` | `skillkit.sh install --target ~/repo --category workflow` |
| — | `skillkit.sh install --target ~/repo --platform pi` |
| — | `skillkit.sh install --target ~/repo --agent-target codex` |
| — | `skillkit.sh list-platforms` |

### Directory Structure Changes

**Old install layout:**
```
.ai/skillkit/skills/*.md
.ai/skillkit/AGENTS.md
```

**New install layout:**
```
.ai/skillkit/skills/*.md
.ai/skillkit/prompts/*.md
.ai/skillkit/commands/*.md
.ai/skillkit/agents/*.md
.ai/skillkit/workflows/*.md
.ai/skillkit/AGENTS.md
.pi/skills/*.md
.codex/skills/*.md
.github/copilot-skills/*.md
.claude/skills/*.md
.opencode/skills/*.md
```

### What You Need to Do

1. **Update your catalog references**: If you have custom catalogs or scripts referencing `catalog.tsv`, update them to use the new column order.
2. **Update your commands**: Replace `--source bundled` with `--source internal` in any scripts or documentation.
3. **Re-install in existing projects**: Run the installer again in projects to get the new platform-specific directory layout:
   ```bash
   ./scripts/skillkit.sh install --target ~/repo
   ```

### Backward Compatibility

- The `skills/` directory still uses `SKILL.md` as the default filename.
- New categories (`prompt`, `command`) use `PROMPT.md` and `COMMAND.md` respectively.
- Existing `AGENTS.md` files with `BEGIN AI SKILLKIT` / `END AI SKILLKIT` markers will be updated correctly.

---

## v1.1: External Skills Migration

Starting with v1.1, five skills were moved from bundled local copies to external dependencies:

| Skill | Old Location | New Source | Install Command |
|-------|--------------|------------|-----------------|
| `caveman` | `skills/caveman/` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `npx skills add JuliusBrussee/caveman` |
| `grill-me` | `skills/grill-me/` | [mattpocock/skills](https://github.com/mattpocock/skills) | `npx skills add mattpocock/skills --skill grill-me` |
| `codeburn` | `skills/codeburn/` | [AgentSeal/CodeBurn](https://github.com/AgentSeal/CodeBurn) | `npm install -g codeburn` |
| `plannotator` | `skills/plannotator/` | [backnotprop/plannotator](https://github.com/backnotprop/plannotator) | `curl -s https://plannotator.ai/install.sh | sh` |
| `context-audit` | `skills/context-audit/` | [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit) | `npm install -g ctxaudit` |

### What Stayed Local

Three core skills remain internal:

- **`control-first`**: The default workflow framework
- **`pi-coding-agent`**: Pi harness documentation
- **`local-inference`**: Curated best practices guide
