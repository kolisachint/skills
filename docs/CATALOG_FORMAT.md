# Catalog & Favorites Format

This document describes the TSV file formats used by the Portable AI Skillkit.

---

## `catalog.tsv`

Single source of truth for all skills, prompts, commands, tools, agents, and workflows.

### Columns (in order)

| Column           | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| name             | Unique identifier (kebab-case, no spaces)                                   |
| category         | One of: skill, prompt, command, tool, agent, workflow                      |
| source           | 'external' (from third-party repo) or 'local'                               |
| platforms        | Comma-separated: all, opencode, pi, copilot, codex, claude                 |
| agent_target     | 'all' or a specific agent/platform name                                     |
| description      | Concise operational summary (max 100 chars)                                 |
| install_command  | Shell command to install the component (neutral form, e.g. npx skills add) |
| stars            | GitHub star count (e.g. 90K, 5K, 4.6K)                                     |
| remove_command   | Shell command to remove/uninstall the component                             |
| docs_url         | URL to official documentation (GitHub README or npm page)                   |

### Platform-specific install commands

The `install_command` in `catalog.tsv` uses neutral/base commands (typically `npx skills add` or `npm install`). When you pass `--platform <name>` to `install`, the command is automatically transformed for the target platform:

| Platform | Transform Behavior |
|----------|-------------------|
| `opencode` | Adds `-a opencode -g -y` flags to `npx skills add` commands |
| `pi` | Converts `npm install <pkg>` with `pi-extension` to `pi install npm:<pkg>`; Converts `npx skills add owner/repo` to `pi install https://github.com/owner/repo` |
| `codex` | Converts `npx skills add owner/repo` to `codex skills add <skill-name>` |
| `copilot` | Converts `npx skills add owner/repo` to `gh copilot -- plugin install owner/repo` |
| `claude` | No transform needed — uses `npx skills` as-is |

This means you can use the same catalog for all platforms. The installer adapts commands automatically.

### Post-install setup commands

Some skills require additional setup after installation:

| Skill | Setup Command | Purpose |
|-------|--------------|---------|
| grill-me | `/setup-matt-pocock-skills` | Configure issue tracker, labels, docs location |

These setup commands are documented in `docs/SKILL_SOURCES.md` alongside the official README instructions.

**Example:**
```bash
# Base command in catalog:
npx skills add obra/superpowers --yes

# With --platform opencode:
npx skills add obra/superpowers --yes -a opencode -g -y

# With --platform pi:
pi install https://github.com/obra/superpowers

# With --platform codex:
codex skills add superpowers

# With --platform copilot:
gh copilot -- plugin install obra/superpowers
```

---

## `favorites.tsv`

Personal index of frequently-used components.

### Columns

| Column | Description |
|--------|-------------|
| `name` | Component name (must exist in `catalog.tsv`) |
| `category` | `skill`, `prompt`, `command`, `tool`, `agent`, `workflow` |
| `platforms` | Comma-separated platform list |
| `tags` | Comma-separated tags for filtering |
| `source` | `external` or `local` |

### Tags

| Tag | Meaning |
|-----|---------|
| `daily-driver` | Install on every project |
| `occasional` | Rare but important |
| `critical` | Required for specific project types (e.g. `frontend-critical`) |

### Usage

```bash
./install --target ~/repo --from favorites.tsv --tag daily-driver
./install --target ~/repo --from favorites.tsv --tag daily-driver,critical
```
