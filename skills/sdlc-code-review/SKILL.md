---
name: sdlc-code-review
description: Use when asked to review code, audit changes, or critique a pull request or patch before merging.
---

# Automated Code Review Workflow

## 1. Scope & Diff Analysis
Inspect the full diff using `git diff HEAD~1` (or comparison target).
Review changes along five critical dimensions:
1. **Architecture & Boundaries**: Does this change violate layer separation or introduce cyclic dependencies?
2. **Reliability & Edge Cases**: Are nullability, network timeouts, error handling, and resource leaks handled?
3. **Security**: Are inputs validated/sanitized? Are secrets or sensitive data exposed in logs?
4. **Performance**: Are there unnecessary allocations, N+1 query patterns, or unindexed lookups?
5. **Test Completeness**: Are edge cases and failure paths tested?

## 2. Structured Review Output
Provide the findings in GitHub Markdown:
- **Summary**: Concise overview of the changes.
- **Critical Issues**: High-severity bugs, security risks, or breaking changes.
- **Suggestions / Optimizations**: Non-blocking improvements for readability or efficiency.
- **Verification Verdict**: Approve, Request Changes, or Comments.
