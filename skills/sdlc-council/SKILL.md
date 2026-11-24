---
name: sdlc-council
description: Use when facing high-stakes architectural decisions, contentious trade-offs, complex refactors, or when the user asks to convene a council, multi-agent debate, or adversarial second opinion.
---

# Multi-Agent Engineering Council Workflow

Run a structured, adversarial multi-perspective deliberation to eliminate blind spots, anchoring bias, and sycophancy before committing to high-impact engineering decisions.

---

## Pre-Flight: Anti-Theater Gate
Convene a council **only** for decisions with meaningful blast radius, irreversibility, or competing trade-offs (e.g., architecture patterns, build-vs-buy, database/infra selection, major refactors, or high-risk security/design reviews).
- Do **not** convene a council for trivial bug fixes, syntax questions, or straightforward single-file edits—answer directly.

---

## Execution Mode Selection
Choose the execution mode based on runtime capabilities:
- **Mode A — Parallel Subagent Council (Preferred)**: When subagent spawning is available (e.g., Antigravity `invoke_subagent` with read-only `research` subagents, or Claude Code parallel `Agent`/`Task` subagents), dispatch all panelists **concurrently in a single turn** so initial positions are strictly independent. Subagents must remain **read-only**; council deliberation never mutates repository files.
- **Mode B — Isolated Multi-Lens Fallback**: When subagent tools are unavailable, execute Phases 1–3 sequentially in strictly separated sections, completing every panelist's argument before performing cross-examination or synthesis.

---

## Phase 1: Framing & Independent Position Drafting
1. Frame the exact **Decision Question**, non-negotiable constraints (SLA, budget, timeline, stack), and the concrete files/diffs in scope.
2. Dispatch **3 core panelists** simultaneously (add a 4th domain specialist—such as *Security/Compliance* or *Data/Infra*—only when directly warranted):
   - **The Architect** (*Systems & Longevity*): Evaluates module boundaries, data consistency, scalability, operability, and long-term evolvability.
   - **The Pragmatist** (*Simplicity & Delivery*): Enforces YAGNI, challenges speculative abstractions, and weighs cognitive load, maintenance cost, and time-to-value.
   - **The Skeptic / Red Team** (*Failure Modes & Risk*): Actively tries to break the proposal—hunting for hidden coupling, race conditions, rollback/migration traps, security flaws, and vendor lock-in.
3. Require every panelist to return a tight memo (≤ 200 words):
   - **Position**: Clear, unambiguous recommendation (no hedging).
   - **Evidence**: Concrete codebase files, symbols, or constraints backing the stance.
   - **Top 2 Risks**: Highest-impact failure modes of this approach or its alternative.
   - **Dealbreaker**: Single falsifiable condition under which this option should be rejected.

---

## Phase 2: Blind Cross-Examination (Anonymous Peer Review)
1. Strip role titles and anonymize Phase 1 memos as **Proposal A**, **Proposal B**, and **Proposal C**.
2. Run **1 cross-examination round** (parallel subagents in Mode A; explicit critique pass in Mode B) instructing each panelist to:
   - Identify the strongest valid argument in a competing proposal that they initially missed.
   - Expose unverified assumptions, weak reasoning, or missing failure modes in the other proposals.
   - Declare **Hold** or **Revise** on their original position based on the evidence surfaced.
3. Cap deliberation at **1 cross-examination round** by default to prevent token bloat and circular debate.

---

## Phase 3: Chairman Synthesis & Council Verdict
Act as **Chairman** to reconcile the debate without diluting real disagreements into vague *"it depends"* compromises. Deliver the verdict in GitHub Markdown:

```markdown
## Council Verdict

### 1. Executive Verdict
- **Recommended Path**: [Clear decision]
- **Confidence**: [High | Medium | Low — Spike Required]
- **Why**: [Decisive justification tied directly to constraints and evidence]

### 2. Points of Consensus
- [Findings independently confirmed across panelists]

### 3. Trade-off Matrix
| Dimension | Option A | Option B |
| :--- | :--- | :--- |
| Complexity / YAGNI | ... | ... |
| Scalability / Longevity | ... | ... |
| Failure / Rollback Risk | ... | ... |

### 4. Minority Report (Strongest Dissent)
> Preserve the sharpest counter-argument from the Skeptic or dissenting panelist verbatim so the user sees the real residual risk.

### 5. Pre-Conditions & Guardrails
- [Concrete mitigation, test, or time-boxed spike required before full rollout]
```

---

## Phase 4: Handoff
1. Present the **Council Verdict** to the user for decision sign-off.
2. Offer the appropriate next step:
   - Codify the accepted decision into a permanent ADR using `sdlc-adr` (`docs/adr/NNNN-*.md`).
   - Transition to `/plan` to decompose the chosen path into phased implementation tasks.
