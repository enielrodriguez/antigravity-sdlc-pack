---
name: sdlc-adr
description: Use when making or documenting significant architectural, technology, or design decisions (Architecture Decision Records - ADRs).
---

# Architecture Decision Record (ADR) Workflow

Capture and document significant architectural decisions to preserve historical context for engineering teams and AI agents.

---

## Phase 1: Context & Decision Trigger
Trigger this workflow when making non-trivial technical choices:
- Introducing a new database, message broker, or external service.
- Choosing an architectural pattern (e.g., Event-Driven vs REST vs gRPC).
- Changing state management, authentication strategy, or core libraries.
- Establishing backward-compatibility or deprecation strategies.

---

## Phase 2: ADR Indexing & File Location
1. Ensure the ADR storage directory exists:
   - Primary: `docs/adr/` (or `doc/adr/` if existing in repository).
2. Determine the next sequential index number:
   - Inspect existing files (e.g., `0001-init.md`, `0002-auth.md`).
   - Format: `NNNN-<kebab-case-title>.md` (e.g., `docs/adr/0003-use-sqlite-for-local-cache.md`).

---

## Phase 3: Drafting the ADR Document
Use the industry-standard Michael Nygard format:

```markdown
# [NNNN]. [Short Title of Architectural Decision]

* **Status**: [Proposed | Accepted | Superseded by NNNN | Deprecated]
* **Date**: YYYY-MM-DD
* **Deciders**: [List authors / decision makers]
* **Consulted**: [List technical stakeholders]

## Context & Problem Statement
Describe the architectural challenge or requirement. What forces (technical, business, timeline) are driving this decision?

## Decision Drivers
- [Driver 1: e.g., Latency under 50ms]
- [Driver 2: e.g., Low memory footprint on developer machines]
- [Driver 3: e.g., Ease of local offline development]

## Considered Options
1. [Option 1: e.g., Redis]
2. [Option 2: e.g., SQLite with WAL mode]
3. [Option 3: e.g., In-memory cache with file persistence]

## Decision Outcome
Chosen option: "[Option 2: SQLite with WAL mode]", because [justification tied to decision drivers].

### Positive Consequences
- [Positive consequence 1]
- [Positive consequence 2]

### Negative Consequences & Trade-offs
- [Trade-off / drawback 1]
- [Mitigation strategy for drawback 1]

## Pros and Cons of the Options
### [Option 1]
- Good, because ...
- Bad, because ...

### [Option 2]
- Good, because ...
- Bad, because ...
```

---

## Phase 4: ADR Review & Index Update
1. Update `docs/adr/README.md` with the new ADR link and status table.
2. Present the ADR draft to the user for confirmation.
3. Commit the ADR to Git alongside any code implementing the decision.
