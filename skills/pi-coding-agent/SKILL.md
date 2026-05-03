---
name: pi-coding-agent
description: Use this skill when working with Pi Coding Agent as the control-first terminal harness, including project setup, skill routing, model routing, and minimal tool usage.
---

# Pi Coding Agent

Use Pi as the lightweight terminal harness when the user wants direct control
over read, write, edit, and shell operations.

## Role

Pi is the execution shell, not the source of truth. Shared instructions come
from `AGENTS.md` and `.ai/skillkit/AGENTS.md`; Pi-specific copies live under
`.pi/skills/`.

## Setup Pattern

- Install project skills into `.pi/skills/<skill>/SKILL.md`.
- Route cheap model calls to a local OpenAI-compatible endpoint only when the
  task is bounded.
- Keep hard reasoning, architecture, and review on a stronger model.
- Prefer explicit commands over hidden automation.

## Daily Use

1. Start in `grill-me` only if requirements are unclear.
2. Move to `control-first` for planning and implementation.
3. Use `plannotator` for large plans or diffs.
4. Use `caveman` for terse output after scope is understood.
5. Use `codeburn` during weekly cost review, not during every edit.

