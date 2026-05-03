# Control-First Stack

The minimalist control-first stack uses one terminal harness, one shared
instruction layer, optional visual review, optional local inference, and light
cost observability.

| Component | Role | Why you need it | Source | Install |
|---|---|---|---|---|
| Pi Coding Agent | Core terminal harness | Lightweight, customizable execution through read, write, edit, and bash tools. | `pi-coding-agent` (bundled) | Included |
| LM Studio / Ollama | Local API inference server | Reduces cost for bounded low-risk API/model calls through local OpenAI-compatible endpoints. | `local-inference` (bundled) | Included |
| Grill-Me | Requirement interrogation | Forces one clarifying question at a time before planning when requirements are unclear. | [mattpocock/skills](https://github.com/mattpocock/skills) | `npx skills add mattpocock/skills --skill grill-me` |
| Plannotator | Visual plan and code review | Lets you review plans or diffs and request changes before execution. | [backnotprop/plannotator](https://github.com/backnotprop/plannotator) | `curl -s https://plannotator.ai/install.sh \| sh` |
| Caveman | Output token compression | Removes filler and keeps responses terse without damaging code blocks or verification. | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `npx skills add JuliusBrussee/caveman` |
| CodeBurn | Cost and token observability | Helps identify context and token waste by session or project. | [AgentSeal/CodeBurn](https://github.com/AgentSeal/CodeBurn) | `npm install -g codeburn` |
| Context Audit | Context hygiene review | Detects stale instructions and context bloat. | [sanjeed5/ctxaudit](https://github.com/sanjeed5/ctxaudit) | `npm install -g ctxaudit` |

## Default Flow

1. Clarify with `grill-me` only when ambiguity is risky.
2. Plan and implement with `control-first`.
3. Review large plans or diffs with `plannotator`.
4. Compress routine output with `caveman`.
5. Route cheap bounded tasks through `local-inference` when configured.
6. Review cost and token waste with `codeburn` weekly.
7. Audit context hygiene with `context-audit` monthly.

## Installing External Components

To install all external components at once:

```bash
./scripts/install-external.sh
```

To install specific components:

```bash
./scripts/install-external.sh --skills caveman,grill-me
```

## Philosophy

The core stack (`control-first`, `pi-coding-agent`, `local-inference`) is
maintained in this repository as it represents unique workflow frameworks.

Specialized tools (`grill-me`, `plannotator`, `caveman`, `codeburn`, `context-audit`)
are sourced from their actively maintained external repositories to ensure you
always have the latest features, bug fixes, and community improvements.
