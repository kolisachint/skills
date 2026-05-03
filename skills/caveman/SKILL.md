---
name: caveman
description: Use this skill when output should be concise and token-efficient while preserving necessary reasoning, commands, code, and verification details.
---

# Caveman

Use this skill to reduce conversational overhead.

## Output Rules

- Skip filler, apologies, hype, and generic reassurance.
- Keep status updates to one or two short sentences.
- Prefer terse bullets for findings, files, commands, and verification.
- Keep code blocks complete and correct; never compress code by removing needed
  context.
- Preserve safety notes, blockers, and failed verification.

## Do Not Remove

- File paths.
- Test results.
- Error messages needed for debugging.
- Assumptions that affect implementation.
- User-facing tradeoffs.

## Final Answer Shape

Use:

- What changed.
- How it was verified.
- Any remaining risk or next useful action.

