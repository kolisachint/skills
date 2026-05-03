---
name: claude-research
description: Deep research prompt template for Claude projects. Use when investigating unfamiliar codebases, APIs, or technologies.
platforms: claude
agent_target: claude
---

# Claude Research Prompt

Use this prompt structure when starting a deep research task in Claude.

## Prompt Template

```
I need to understand [TOPIC]. Please research the following:

1. What is [TOPIC] and what problem does it solve?
2. What are the 3 most common ways to use it?
3. What are the main tradeoffs between those approaches?
4. What are the top 3 pitfalls or misconceptions?
5. Provide a minimal working example that demonstrates the core concept.

Constraints:
- Cite specific file names, function names, or documentation URLs when possible.
- If you are uncertain, say so rather than hallucinating.
- Keep the total response under 2000 words.
```

## When to Use

- Onboarding to a new codebase or framework.
- Evaluating a third-party library or API.
- Debugging an unfamiliar error or system behavior.
- Preparing a design decision document.

## Follow-Up Patterns

After the initial research, narrow the scope:

- "Now trace how [X] is used in this specific codebase."
- "Compare approach A vs approach B for our constraints."
- "What tests should I add to verify my understanding?"
