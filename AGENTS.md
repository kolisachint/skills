# Portable AI Skillkit Repo

This repository is the source package for portable coding-agent skills.

When editing it:

- Keep `skills/*/SKILL.md` as the source of truth for each skill.
- Keep skills concise and operational. Put only agent-useful instructions in
  the skill body.
- Preserve installer behavior that avoids overwriting user project files outside
  the managed `AI SKILLKIT` blocks.
- Prefer shell scripts with no third-party dependencies for portability.
- Test installer changes against a temporary directory before reporting success.

