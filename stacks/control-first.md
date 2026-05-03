# Control-First Stack

The minimalist control-first stack uses one terminal harness, one shared
instruction layer, optional visual review, optional local inference, and light
cost observability.

| Component | Role | Why you need it | Skillkit mapping |
|---|---|---|---|
| Pi Coding Agent | Core terminal harness | Lightweight, customizable execution through read, write, edit, and bash tools. | `pi-coding-agent`, `.pi/skills/*` |
| LM Studio / Ollama | Local API inference server | Reduces cost for bounded low-risk API/model calls through local OpenAI-compatible endpoints. | `local-inference` |
| Grill-Me | Requirement interrogation | Forces one clarifying question at a time before planning when requirements are unclear. | `grill-me` |
| Plannotator | Visual plan and code review | Lets you review plans or diffs and request changes before execution. | `plannotator` |
| Caveman | Output token compression | Removes filler and keeps responses terse without damaging code blocks or verification. | `caveman` |
| CodeBurn | Cost and token observability | Helps identify context and token waste by session or project. | `codeburn` |

## Default Flow

1. Clarify with `grill-me` only when ambiguity is risky.
2. Plan and implement with `control-first`.
3. Review large plans or diffs with `plannotator`.
4. Compress routine output with `caveman`.
5. Route cheap bounded tasks through `local-inference` when configured.
6. Review cost and token waste with `codeburn` weekly.

