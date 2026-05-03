# Context Audit

## Role

Context hygiene and instruction drift review.

## External Source

This component is sourced from the actively maintained external repository:
- **Repository**: [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit)
- **Install**: `npm install -g ctxaudit`

## Alternative Tools

- **[littlebearapps/contextdocs](https://github.com/littlebearapps/contextdocs)** - AGENTS-first context management with health scoring
- **[atolat/ctxguard](https://github.com/atolat/ctxguard)** - Context budget and rot monitor

## Why It Exists

Use Context Audit when your agents start acting inconsistently, rereading too
much, obeying stale rules, or wasting context on duplicated setup text.

## Features (External Version)

The ctxaudit tool provides:
- Scans all agent config files (SKILL.md, rules, instruction files)
- Token counting per file and category
- Startup vs full context analysis
- User-level and project-level scanning
- Machine-readable output for CI integration

## Skillkit Mapping

- Install: `./scripts/install-external.sh --skills context-audit`
- Related tools: `codeburn`, `control-first`

## Notes

Run this before adding more rules. Often the fix is deleting or merging
instructions, not adding another layer.
The external version at sanjeed5/ctxaudit provides automated scanning and
detailed context analysis beyond simple guidelines.
