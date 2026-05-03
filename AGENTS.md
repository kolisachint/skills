# Portable AI Skillkit Repo

This repository is a curated catalog of portable coding-agent skills from
actively maintained third-party sources.

When editing it:

- Keep `catalog.tsv` as the single source of truth.
- Keep component descriptions concise and operational.
- Use frontmatter (`--- name: ... description: ... platforms: ... agent_target: ... ---`)
  to declare platform compatibility and agent targeting.
- Preserve installer behavior that avoids overwriting user project files outside
  the managed `AI SKILLKIT` blocks.
- Prefer shell scripts with no third-party dependencies for portability.
- Test installer changes against a temporary directory before reporting success.
- Maintain parity between `scripts/skillkit.sh` and `scripts/skillkit.ps1`.

## Component Dimensions

Every component in `catalog.tsv` is classified across four dimensions:

1. **Source**: `external` (third-party)
2. **Category**: `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
3. **Platform**: `all`, `opencode`, `pi`, `copilot`, `codex`, `claude`
4. **Agent Target**: `all` or a specific agent/platform name

## External Components

Install commands in `catalog.tsv` run at install time (e.g.
`npx skills add`, `npm install -g`).

## Platform Directories

When installing, components are routed to:

| Platform | Skill Directory | Agent Config Directory |
|----------|----------------|----------------------|
| Shared | `.ai/skillkit/` | — |
| Pi | `.pi/skills/` | `.pi/agents/` |
| OpenCode | `.opencode/skills/` | `.opencode/agents/` |
| Copilot | `.github/copilot-skills/` | `.github/copilot-agents/` |
| Codex | `.codex/skills/` | `.codex/agents/` |
| Claude | `.claude/skills/` | `.claude/agents/` |

## External Documentation

Platform-specific documentation links are maintained in `docs/REFERENCES.md`.
Update this file when adding new platform documentation or changing skill
authoring conventions.
