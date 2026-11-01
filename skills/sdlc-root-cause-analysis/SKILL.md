---
name: sdlc-root-cause-analysis
description: Use when troubleshooting tricky bugs, test failures, crashes, or regressions.
---

# Root Cause Analysis (RCA) Workflow

## 1. Minimal Reproduction
1. Formulate a minimal, deterministic reproduction script or failing test case.
2. Run the reproduction and capture stdout, stderr, and relevant stack traces.

## 2. Scientific Hypothesis Testing
1. Formulate at least two distinct hypotheses for why the failure occurs.
2. Gather diagnostic evidence using logs, targeted breakpoints, or minimal assertions.
3. Validate or invalidate each hypothesis with evidence before proposing code edits.

## 3. Surgical Fix & Verification
1. Implement the minimal fix addressing the root cause.
2. Re-run the reproduction test to verify it passes.
3. Re-run the entire test suite to guarantee zero regressions.
