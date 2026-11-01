---
name: sdlc-spec-discovery
description: Use when the user has a business idea, new product concept, feature request, or wants to refine requirements and architecture before starting implementation.
---

# Product Discovery & System Specification Workflow

Follow this structured 4-phase gate before writing any implementation code. Do not jump straight to code generation.

---

## Phase 1: Problem Definition & Scope Boundaries
Interactively clarify and document:
1. **Core Problem Statement**: What exact pain point or inefficiency does this solve?
2. **Target User Persona**: Who is the primary operator? What is their technical level and environment?
3. **Core Value Metric (JTBD)**: What is the single most critical outcome that defines success?
4. **Anti-Goals (Strict Out-of-Scope)**: What features, platforms, or edge cases are explicitly deferred past v1.0?

*Note: Use interactive questioning or the `/grill-me` workflow to probe edge cases, performance constraints, and trade-offs before proceeding.*

---

## Phase 2: User Journeys & Acceptance Criteria
Map the happy path and critical failure paths:
1. **Critical Path Flow**: Step-by-step user journey from initiation to value delivery.
2. **Acceptance Criteria (BDD / Gherkin format)**:
   Define testable specifications for every primary user action:
   ```gherkin
   Scenario: [Action description]
     Given [pre-conditions or initial state]
     When [triggering event or user action]
     Then [expected deterministic result]
   ```
3. **Error Handling & Degradation**: How does the system behave when network, auth, or input validation fails?

---

## Phase 3: System Architecture & Domain Modeling
Produce clear visual architectures using Mermaid syntax:
1. **Domain Model**: Entity-relationship diagram (`erDiagram`) showing core entities, attributes, and cardinality.
2. **Execution Flow**: Sequence diagram (`sequenceDiagram`) showing data flow between client, API, database, and external services.
3. **Non-Functional Requirements**:
   - Latency tolerances and throughput expectations.
   - Persistence and storage boundaries.
   - Authentication, authorization, and secret handling.

---

## Phase 4: Artifact Generation (`SPEC.md` / `PRD.md`)
1. Synthesize all findings into a structured markdown artifact:
   - Summary and Problem Statement
   - Scope & Anti-Goals
   - Architecture & Data Models (Mermaid diagrams)
   - User Stories & Acceptance Criteria
   - Technical Stack Recommendations & Trade-offs
2. Present the document to the user for formal sign-off.
3. Once approved, recommend switching to `/plan` to decompose the specification into phased engineering tasks.
