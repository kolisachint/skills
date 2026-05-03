# Portable AI Skillkit Repo

This repository is a curated catalog of portable coding-agent skills from
actively maintained third-party sources. It is a thin wrapper around `npx skills`.

When editing it:

- Keep `catalog.tsv` as the single source of truth.
- Keep component descriptions concise and operational.
- Use frontmatter to declare platform compatibility and agent targeting.
- Prefer shell scripts with no third-party dependencies for portability.
- Test installer changes against a temporary directory before reporting success.
- Maintain parity between `skillkit.sh` and `skillkit.ps1`.

## Component Dimensions

Every component in `catalog.tsv` is classified across four dimensions:

1. **Category**: `skill`, `prompt`, `command`, `tool`, `agent`, `workflow`
2. **Platform**: `all`, `opencode`, `pi`, `copilot`, `codex`, `claude`
3. **Agent Target**: `all` or a specific agent/platform name
4. **Install Command**: how the component is installed (e.g. `npx skills add`)

## How It Works

`skillkit.sh install` reads `catalog.tsv`, filters by your criteria, and runs
each component's install command in the target directory. `npx skills` handles
the rest — creating `.agents/skills/` and symlinking to platform directories.

## External Documentation

Platform-specific documentation links are maintained in `docs/REFERENCES.md`.
Update this file when adding new platform documentation or changing skill
authoring conventions.
