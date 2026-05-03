# Why These Tools?

## Comparison with Alternatives

This document explains why we selected specific tools for the skillkit and what alternatives we considered and rejected. This is the companion to [PHILOSOPHY.md](../PHILOSOPHY.md)—where that document explains our values, this one shows how those values translated into specific choices.

---

## Workflow Frameworks

### Selected: `control-first` (bundled)

**What it does:** Defines the core human-in-the-loop workflow: clarify → plan → patch → test → review

**Why it stays local:**
- Too central to outsource—this defines how we think about AI collaboration
- Needs to evolve with our understanding, not wait for upstream
- Platform-specific nuances require tight integration

### Alternative Considered: obra/superpowers (90K stars)

**Why we added it as external instead:**
- Superpowers is excellent—20+ skills covering TDD, debugging, planning, brainstorming
- It's a complete methodology, not just a workflow
- Different philosophy: assumes subagent availability, more comprehensive
- Our control-first is the "vanilla JS" to their "React"—lower level, more explicit

**Verdict:** Both have value. We include superpowers as external for users who want comprehensive methodology, while keeping control-first local for those who want minimal, explicit workflow.

### Rejected: everything-claude-code (172K stars)

**Why:** Kitchen sink approach. 48 agents, 183 skills, 79 commands. Too much magic, too many interdependencies. Violates our "explicit over implicit" principle. You're forced to wade through cruft to find gems.

**Verdict:** Pass. Curation matters more than comprehensiveness.

---

## Terminal Harness

### Selected: `pi-coding-agent` (bundled)

**What it does:** Documents Pi as a thin terminal harness—just four tools, explicit control

**Why it stays local:**
- Pi is unique—it's documentation of how to use a specific tool correctly
- An external package would always be slightly wrong, slightly behind
- We can iterate fast as Pi evolves

### Alternative Considered: Bernstein (31 agents)

**Why we rejected it:**
- Impressive technical achievement—31 agent support, MCP server mode, git worktree isolation
- But adds orchestration complexity we don't need
- Our philosophy: simpler and explicit over comprehensive but complex
- If you want 31 agents, use Bernstein. If you want Pi documented correctly, use our skill.

**Verdict:** Reject. Bernstein solves a different problem (multi-agent orchestration) than we want to solve (correct Pi usage).

---

## TDD/Testing Skills

### Selected: `superpowers` (external) for comprehensive TDD

**What it does:** RED-GREEN-REFACTOR methodology, systematic debugging, test generation

**Why we included it:**
- Most mature TDD framework available
- 90K stars = battle-tested by many developers
- Explicit phases align with our philosophy

### Alternative Considered: glebis/tdd

**What it does:** Multi-agent TDD orchestration—separate Test Writer and Implementer agents

**Why we didn't include it:**
- Clever architecture, but assumes multi-agent setup
- Our users may not have subagent support
- Adds complexity for marginal benefit

**Verdict:** Interesting but too specific. Mentioned in research but not included.

---

## Requirement Interrogation

### Selected: `grill-me` (external, 31K stars)

**What it does:** One-question-at-a-time requirement clarification

**Why this one:**
- Forces discipline without being rigid
- Viral adoption suggests it solves a real problem
- Human remains in control—the skill asks, you decide

### Alternatives Considered:

**Various prompt frameworks** - Most are just templates. grill-me is an interactive process.

**chatty** - Good but less structured than grill-me

**Verdict:** grill-me hits the sweet spot of structure without rigidity.

---

## Token Optimization

### Selected: `caveman` (external, 52K stars)

**What it does:** Ultra-compressed communication mode—75% token reduction

**Why this one:**
- Simple, effective, no magic
- Addresses real cost problem directly
- 52K stars = community validated

### Alternatives Considered:

**Various compression libraries** - Most are too complex or require infrastructure

**Manual prompt engineering** - Works but not systematic

**Verdict:** caveman is the right abstraction level for our users.

---

## Cost Observability

### Selected: `codeburn` (external, 4.6K stars)

**What it does:** Interactive TUI dashboard for token/cost tracking

**Why this one:**
- Small enough to understand (4.6K lines), reliable enough to trust
- Does one thing well without trying to be a platform
- Addresses our "context is scarce" principle directly

### Alternatives Considered:

**Various cloud dashboards** - Require infrastructure, lock-in

**Manual logging** - Too easy to skip

**Verdict:** codeburn hits the sweet spot of useful without overkill.

---

## Plan Review

### Selected: `plannotator` (external, 5K stars)

**What it does:** Visual plan and diff review with annotations

**Why this one:**
- Visual > text for complex plans
- Explicit approval gates align with our philosophy
- No surprises—see before you approve

### Alternatives Considered:

**Text-based review tools** - Work but harder to scan

**Full project management integrations** - Too heavy, violates "tools not platforms"

**Verdict:** plannotator is the right weight for agent workflows.

---

## Context Management

### Selected: `context-audit` (external)

**What it does:** Context bloat detection and instruction drift monitoring

**Why this one:**
- Foundational—you can't optimize what you can't see
- Addresses our "context is scarce" principle directly
- Necessary, not just nice-to-have

### Alternatives Considered:

**Various linting tools** - Catch syntax, not context hygiene

**Manual review** - Too easy to skip under pressure

**Verdict:** Essential. Included despite lower star count because it solves a critical problem.

---

## Production Engineering

### Selected: `agent-skills` (external, 20K+ stars)

**What it does:** Production-grade engineering skills from Google's culture

**Why we added it:**
- Security hardening, incremental implementation, context engineering
- Every skill has verification gates—nothing is "trust me, it's fine"
- Encodes real engineering rigor, not vibe coding

### Alternative Considered: vercel-labs/agent-skills (25K stars)

**Why we chose addyosmani over vercel-labs:**
- Both excellent, both production-grade
- addyosmani more focused on engineering fundamentals
- vercel-labs more focused on deployment/edge cases
- Our users need fundamentals more than edge cases

**Verdict:** Included addyosmani. Mentioned vercel-labs in research for users who need deployment-focused skills.

---

## What We Didn't Include (And Why)

### LangChain / AutoGen

**Promise:** Simplify AI development
**Reality:** Wrong abstractions, leaky complexity, solve problems you don't have
**Verdict:** Pass. Frameworks for building AI apps, not tools for using AI coding agents.

### CrewAI (50K stars)

**Promise:** Role-playing agent simulation
**Reality:** Fun for demos, overkill for daily coding
**Verdict:** Pass. Assumes autonomous agents—we prefer human-in-the-loop.

### MetaGPT

**Promise:** Multi-agent software company simulation
**Reality:** Too complex, too slow, too many moving parts
**Verdict:** Pass. Violates "explicit over implicit" and "tools not platforms."

### Everything from everything-claude-code

**Promise:** Complete ecosystem
**Reality:** 172K lines of kitchen sink—includes gems and cruft
**Verdict:** Pass. Curation beats comprehensiveness.

---

## Summary Table

| Category | Selected | Stars | Why Over Alternatives |
|----------|----------|-------|----------------------|
| **Workflow** | control-first (local) | — | Defines our philosophy, too central to outsource |
| **Workflow** | superpowers (external) | 90K | Most comprehensive, explicit phases |
| **Terminal** | pi-coding-agent (local) | — | Pi-specific documentation |
| **Interrogation** | grill-me (external) | 31K | Structure without rigidity |
| **Compression** | caveman (external) | 52K | Simple, effective, community validated |
| **Observability** | codeburn (external) | 4.6K | Small, focused, trustworthy |
| **Plan Review** | plannotator (external) | 5K | Visual > text, right weight |
| **Context** | context-audit (external) | — | Essential for optimization |
| **Production** | agent-skills (external) | 20K | Real engineering rigor |

---

## How to Choose for Your Project

**Start here (core):**
- control-first
- pi-coding-agent  
- context-audit

**Add based on your pain points:**
- Burning too many tokens? → caveman
- Requirements unclear? → grill-me
- Need TDD discipline? → superpowers
- Costs too high? → codeburn
- Plans need review? → plannotator
- Need production rigor? → agent-skills

**Skip if:**
- You want fully autonomous agents (not our philosophy)
- You need 31 different agent integrations (use Bernstein)
- You want kitchen sink comprehensiveness (use everything-claude-code)

---

## Contributing Comparisons

Found a tool you think should replace one of our selections? Open an issue with:
1. What tool you're proposing
2. What it does better than our current selection
3. How it aligns (or conflicts) with our philosophy from PHILOSOPHY.md
4. Specific tradeoffs compared to current tools

We welcome debate. Strong opinions, loosely held.

---

*Last updated: 2026-05-03*  
*Based on research of 20+ GitHub repositories and frameworks*
