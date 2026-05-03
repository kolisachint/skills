---
name: plannotator
description: Use this skill for large or risky changes that benefit from a visible plan, diff review, annotation pass, or approval checkpoint before implementation.
---

# Plannotator

Use this skill when a plan or diff should be reviewed before code changes land.

## When To Use

- UI or product behavior changes.
- Multi-file refactors.
- Database migrations.
- Security-sensitive changes.
- Changes where the user wants to annotate a plan or diff.

## Workflow

1. Produce a short plan with files, risks, and verification.
2. Pause for review if the user requested approval before execution.
3. If a Plannotator-compatible tool is installed, open or export the plan/diff
   through that tool.
4. Apply user annotations as requirements.
5. Implement only the approved scope.

## Fallback

If no visual annotation tool is available, provide a Markdown plan and ask for
approval only when the user requested a checkpoint or the change is risky.

