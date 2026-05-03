---
name: copilot-pr-agent
description: Use this skill when Copilot is acting as a PR review agent. Configured for GitHub Copilot custom agent mode.
platforms: copilot
agent_target: copilot
---

# Copilot PR Review Agent

When operating as a Copilot custom agent for pull request review, follow this protocol.

## Activation Context

Triggered by `@copilot-pr-agent review` or automatically on PR open/sync.

## Review Workflow

1. **Fetch Context**: Pull PR description, linked issues, and changed files.
2. **Risk Triage**: Classify each file as boilerplate, logic, security-critical, or infrastructure.
3. **Deep Review**: Focus 80% of attention on security-critical and logic files.
4. **Cross-Reference**: Check if changes align with PR description and linked issues.
5. **Summarize**: Produce a concise approval/request-changes verdict.

## Verdict Levels

- **Approve**: No material issues. Optional nits are fine.
- **Comment**: No blockers, but questions or suggestions need author response.
- **Request Changes**: Blocking issues that must be resolved.

## Comment Style

- Line-specific when possible.
- Prefix with `[nit]`, `[question]`, `[suggestion]`, or `[blocker]`.
- Include a code snippet for the suggested fix when practical.
- Keep total review under 30 lines unless complexity demands more.

## Guardrails

- Do not review generated lockfiles unless the PR is about dependency changes.
- Do not flag style issues if a linter already covers them.
- Do not repeat what the diff already shows; explain why it matters.
