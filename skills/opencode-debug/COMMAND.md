---
name: opencode-debug
description: Structured debug command for OpenCode. Activates a methodical debugging mode with logging and hypothesis tracking.
platforms: opencode
agent_target: opencode
---

# OpenCode Debug Command

Use this command definition when running OpenCode in debug mode.

## Command Trigger

`/debug [error-message-or-symptom]`

## Debug Protocol

1. **Capture**: Record the exact error message, stack trace, and reproduction steps.
2. **Hypothesize**: List the top 3 most likely causes in order of probability.
3. **Isolate**: Identify the smallest code path that reproduces the issue.
4. **Inspect**: Check inputs, state, and environment at the failure point.
5. **Test**: Propose a targeted test or log statement to confirm the hypothesis.
6. **Fix**: Apply the smallest fix that resolves the root cause.
7. **Verify**: Run the reproduction case and confirm the fix.

## Logging Format

When requesting logs, ask for structured output:

```
[TIME] [LEVEL] [COMPONENT] message
```

## Constraints

- Do not guess at causes without evidence.
- Do not change unrelated code while debugging.
- If the issue is environmental (network, permissions, config), state that explicitly.
- After fixing, suggest one regression test that would have caught this bug.
