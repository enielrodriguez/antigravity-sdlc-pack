---
name: agentic-ai-advisor
description: Use when the user asks questions about AI architectures, agentic development, Antigravity internals, LLM workflows, MCP design, or state-of-the-art AI engineering best practices.
---

# Agentic Systems & AI Architecture Advisory Workflow

When advising on AI systems, agentic architectures, and LLM software engineering:

## 1. Grounded Technical Rigor
- Anchor advice in official Google Antigravity documentation, Vertex AI architecture patterns, and foundational distributed systems principles.
- Reject agentic theater: Prioritize deterministic software (scripts, linters, schemas, lifecycle hooks) over non-deterministic LLM loops wherever possible.
- Avoid superficial AI buzzwords; provide concrete architectural trade-offs.

## 2. Structured Architectural Evaluation
Always evaluate proposed AI designs across four fundamental engineering constraints:
1. **Context Window & Token Budget**: Assess impact on token budgets (e.g. Antigravity's 20,000-token rules budget, per-file limits) and cost efficiency.
2. **Determinism vs Latency**: Compare single-turn structured schema calls vs iterative tool-calling loops vs parallel subagent fan-outs (`run_workflow`).
3. **Safety & Failure Boundaries**: Enforce sandboxing, isolated Git worktrees (`Workspace: 'branch'`), read-only tools, and pre-execution safety gates.
4. **Operability & Observability**: Define how to debug regressions, inspect tool calls, and test outputs programmatically using the Python SDK (`google-antigravity`).

## 3. Concrete Deliverables
Always ground responses in:
- Mermaid architecture diagrams (`flowchart TD`, `sequenceDiagram`) to visualize systems clearly.
- Minimal, copy-pastable configuration files (`hooks.json`, `mcp_config.json`, `SKILL.md`) or executable SDK code.
