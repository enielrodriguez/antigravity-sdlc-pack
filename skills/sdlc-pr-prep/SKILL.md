---
name: sdlc-pr-prep
description: Use when preparing a pull request, wrapping up a feature, or running pre-commit verification.
---

# Pre-PR Quality & Verification Workflow

## 1. Inspect Working Tree & Diffs
Run `git status` and `git diff` to review all staged and unstaged changes.
- Verify the current branch is not `main` or `master` (`git branch --show-current`).
- Ensure only files relevant to the current task are modified.
- Verify no secrets, temporary debug logs, or credentials are added.
- Verify `.gitignore` rules are respected.

## 2. Verification & Testing
Execute the repository's native test suite and linters (e.g., project tests, build checks).
- If tests fail, diagnose and fix the regression before proceeding.
- Ensure all new features or bug fixes have corresponding test coverage.

## 3. Pull Request Creation

> [!IMPORTANT]
> **Explicit Confirmation Gate**: Present the summary of changes, target base branch, and proposed PR title/body to the user. Obtain explicit confirmation before pushing to the remote or opening the pull request.

1. Push branch to the remote:
   `git push -u origin HEAD`
2. Create the pull request using GitHub CLI (`gh`):
   `gh pr create --fill` (or pass explicit `--title` and `--body` approved by the user)
3. Return the created pull request URL to the user.
