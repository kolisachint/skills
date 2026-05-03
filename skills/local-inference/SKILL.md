---
name: local-inference
description: Use this skill to decide when to route coding-agent tasks through local inference servers like Ollama or LM Studio and when to use stronger remote models.
---

# Local Inference

Use local models for cheap, bounded work. Do not force hard reasoning through a
weak model just to save tokens.

## Good Local Tasks

- Summarizing logs.
- Drafting simple tests.
- Renaming or mechanical edits.
- Explaining code after relevant files are already selected.
- Generating first-pass documentation.

## Use Stronger Models For

- Architecture changes.
- Security-sensitive code.
- Debugging subtle failures.
- Large refactors.
- Ambiguous product requirements.
- Code review where missing a bug is expensive.

## Endpoint Pattern

Prefer OpenAI-compatible local endpoints when the agent supports them:

```text
http://localhost:1234/v1
http://localhost:11434/v1
```

Keep model routing explicit in project or user-level config. Do not hide model
changes inside prompts.

