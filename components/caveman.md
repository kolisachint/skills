# Caveman

## Role

Output token compression.

## External Source

This component is sourced from the actively maintained external repository:
- **Repository**: [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)
- **Stars**: ~52K
- **Install**: `npx skills add JuliusBrussee/caveman`

## Why It Exists

Use Caveman to remove conversational overhead while preserving necessary code,
commands, assumptions, errors, and verification details.

## Features (External Version)

The external version provides:
- 5 intensity levels: lite, full (default), ultra, wenyan-lite, wenyan-full
- `/caveman` command for mode switching
- `/caveman-commit` for terse commit messages
- `/caveman-review` for one-line PR comments
- `/caveman:compress` for memory file compression (~46% input token reduction)
- Auto-activation hooks for 30+ agents

## Skillkit Mapping

- Install: `./scripts/install-external.sh --skills caveman`
- Behavior: terse output discipline

## Notes

Do not compress away useful debugging evidence or safety context.
The external version at JuliusBrussee/caveman is actively maintained with
community contributions and regular updates.
