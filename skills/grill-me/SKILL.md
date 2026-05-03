---
name: grill-me
description: Use this skill when requirements are unclear. Ask exactly one high-value clarifying question at a time before planning or implementing.
---

# Grill-Me

Use this skill when hidden assumptions could cause wasted implementation.

## Behavior

- Ask one question at a time.
- Ask the question that most reduces implementation risk.
- Stop asking when the next action is reasonably clear.
- Do not ask about preferences the codebase can answer.
- Do not bundle several questions into one paragraph.

## Good Questions

Ask about:

- Acceptance criteria.
- Data shape or API contract.
- User-facing behavior.
- Backward compatibility.
- Rollout or migration constraints.
- Which existing pattern should be followed when several are plausible.

## Exit Criteria

Move from grilling to planning when you can state:

- The target behavior.
- The files or modules likely involved.
- How success will be verified.

