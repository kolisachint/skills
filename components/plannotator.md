# Plannotator

## Role

Visual plan and code review.

## External Source

This component is sourced from the actively maintained external repository:
- **Repository**: [backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- **Stars**: ~5K
- **Install**: `curl -s https://plannotator.ai/install.sh | sh`

## Why It Exists

Use Plannotator when plans or diffs need visual annotation, approval, or
collaborative review before execution.

## Features (External Version)

The external version provides:
- Visual plan review UI in browser
- Plan diff between versions
- Code review with inline annotations
- `/plannotator-review`, `/plannotator-annotate` commands
- Claude/Codex/Pi/Opencode/Gemini plugins
- Private sharing via URL compression
- Obsidian integration
- AI review agents (Codex + Claude)

## Skillkit Mapping

- Install: `./scripts/install-external.sh --skills plannotator`
- Fallback: Markdown plan and approval checkpoint

## Notes

Keep this optional. A visual review loop is helpful for risky work but too heavy
for every small change.
The external version at backnotprop/plannotator provides a full-featured
visual review interface beyond simple markdown guidelines.
