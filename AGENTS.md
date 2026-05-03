# Portable AI Skillkit Repo

This repository is the source package for portable coding-agent skills.

When editing it:

- Keep `skills/*/SKILL.md`, `skills/*/PROMPT.md`, and `skills/*/COMMAND.md` as the
  source of truth for each component. Category determines which filename is used:
  - `skill`, `workflow`, `agent`, `tool` → `SKILL.md`
  - `prompt` → `PROMPT.md`
  - `command` → `COMMAND.md`
- Keep components concise and operational. Put only agent-useful instructions in
  the skill body.
- Use frontmatter (`--- name: ... description: ... platforms: ... agent_target: ... ---`)
  to declare platform compatibility and agent targeting.
- Preserve installer behavior that avoids overwriting user project files outside
  the managed `AI SKILLKIT` blocks.
- Prefer shell scripts with no third-party dependencies for portability.
- Test installer changes against a temporary directory before reporting success.
- Maintain parity between `scripts/skillkit.sh` and `scripts/skillkit.ps1`.

## Component Dimensions

Every component in `catalog.tsv` is classified across four dimensions:

1. **Source**: `internal` (maintained here) or `external` (third-party)
2. **Category**: `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
3. **Platform**: `all`, `opencode`, `pi`, `copilot`, `codex`, `claude`
4. **Agent Target**: `all` or a specific agent/platform name

## Internal vs External

- **Internal**: Markdown files live in `skills/<name>/`. The installer copies them
  to platform-specific directories and generates indices.
- **External**: Install commands in `catalog.tsv` run at install time (e.g.
  `npx skills add`, `npm install -g`).

## Platform Directories

When installing, internal components are routed to:

| Platform | Skill Directory | Agent Config Directory |
|----------|----------------|----------------------|
| Shared | `.ai/skillkit/` | — |
| Pi | `.pi/skills/` | `.pi/agents/` |
| OpenCode | `.opencode/skills/` | `.opencode/agents/` |
| Copilot | `.github/copilot-skills/` | `.github/copilot-agents/` |
| Codex | `.codex/skills/` | `.codex/agents/` |
| Claude | `.claude/skills/` | `.claude/agents/` |

Agent-specific workflows (where `agent_target` != `all`) may include `agent.*`
config files in their `skills/<name>/` directory. These are copied to the
platform's agent config directory during installation.

## External Documentation

Platform-specific documentation links are maintained in `docs/REFERENCES.md`.
Update this file when adding new platform documentation or changing skill
authoring conventions.
