---
name: context-audit
description: Use this skill to audit an AI coding session or repository setup for context bloat, stale instructions, duplicated rules, oversized prompts, and missing source-of-truth guidance.
---

# Context Audit

Use this skill when the user feels the agent is wasting context, forgetting
rules, reading too much, or behaving differently across tools.

## Audit Targets

Check for:

- Duplicated instructions across `AGENTS.md`, `CLAUDE.md`, `.github/`, `.codex/`,
  `.opencode/`, and `.pi/`.
- Long instructions that should become a concise shared rule.
- Agent-specific files that drift from `.ai/skillkit/AGENTS.md`.
- Skills that repeat generic coding advice instead of task-specific behavior.
- Prompts that paste full files, full logs, or unrelated history.
- Missing verification instructions.
- Unclear model routing between local and remote models.

## Workflow

1. Inventory instruction files and installed skills.
2. Identify duplication, drift, stale rules, and oversized context.
3. Recommend the smallest consolidation path.
4. Preserve project-specific rules that are still useful.
5. Move durable shared behavior into `.ai/skillkit/AGENTS.md` or a focused
   skill.

## Output Shape

Use concise sections:

- `Keep`: rules or files that are doing useful work.
- `Merge`: duplicated instructions that should share one source.
- `Delete`: stale or harmful instructions.
- `Add`: missing guidance that would reduce repeated prompting.
- `Risk`: anything that could break agent behavior if changed blindly.

Do not rewrite instruction files unless the user asks for cleanup or install
repair.

