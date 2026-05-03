# Catalog & Favorites Format

This document describes the TSV file formats used by the Portable AI Skillkit.

---

## `catalog.tsv`

Single source of truth for all skills, prompts, commands, tools, agents, and workflows.

### Columns

| Column | Description |
|--------|-------------|
| `name` | Unique component identifier (kebab-case) |
| `category` | `skill`, `prompt`, `command`, `tool`, `agent`, `workflow` |
| `source` | `external` — from actively maintained third-party repos |
| `platforms` | Comma-separated: `all`, `opencode`, `pi`, `copilot`, `codex`, `claude` |
| `agent_target` | `all` or a specific agent/platform name |
| `description` | Concise operational description |
| `install_command` | Shell command to install the component |
| `stars` | GitHub star count (e.g. `90K`, `5K`, `4.6K`) |

### Platform-specific install commands

When `--platform pi` is passed to `install.sh`/`install.ps1`, npm install commands for packages containing `pi-extension` in their name are automatically transformed to `pi install npm:<pkg>` so Pi can discover and load the extension.

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
./install.sh --target ~/repo --from favorites.tsv --tag daily-driver
./install.sh --target ~/repo --from favorites.tsv --tag daily-driver,critical
```
