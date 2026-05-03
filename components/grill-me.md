# Grill-Me

## Role

Requirement interrogation.

## External Source

This component is sourced from the actively maintained external repository:
- **Repository**: [mattpocock/skills](https://github.com/mattpocock/skills)
- **Stars**: ~31K
- **Install**: `npx skills add mattpocock/skills --skill grill-me`

## Why It Exists

Use Grill-Me to prevent rushed implementation when hidden assumptions would
cause rework.

## Features (External Version)

The external version provides:
- Decision-tree traversal with dependency resolution
- Recommendation-first answers (AI recommends answers for obvious cases)
- Codebase-first approach (explores codebase when possible)
- `/grill-with-docs` with ADR integration
- `/setup-matt-pocock-skills` for full ecosystem
- Auto-activation when user says "grill me", "stress-test", "get grilled"

## Skillkit Mapping

- Install: `./scripts/install-external.sh --skills grill-me`
- Behavior: ask exactly one high-value clarifying question at a time

## Notes

Use it for ambiguous tasks. Skip it for obvious mechanical edits.
The external version at mattpocock/skills is actively maintained and has
achieved viral adoption in the AI coding community.
