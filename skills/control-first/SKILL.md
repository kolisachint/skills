---
name: control-first
description: Use this skill for the default control-first coding workflow: clarify uncertainty, make a small plan, edit narrowly, verify with tests, and summarize only what matters.
---

# Control-First Workflow

Use this as the default workflow for coding-agent work.

## Modes

Pick the smallest mode that fits the task:

- `clarify`: requirements are ambiguous or risky.
- `plan`: cross-file, architectural, destructive, or user-facing changes.
- `implement`: requirements are clear and the change is bounded.
- `review`: user asks for review, audit, risk, or feedback.
- `debug`: tests, CI, runtime behavior, or logs are failing.

## Workflow

1. Restate the task in one sentence if it reduces ambiguity.
2. Ask one clarifying question only if proceeding would be risky.
3. Inspect existing patterns before editing.
4. Make the smallest change that solves the task.
5. Run focused verification.
6. Report changed files and verification result.

## Guardrails

- Do not rewrite unrelated code.
- Do not introduce a new framework or abstraction unless it removes real
  complexity.
- Work with existing user changes instead of reverting them.
- Prefer targeted tests over broad expensive runs unless risk justifies them.
- Keep final answers short and specific.

