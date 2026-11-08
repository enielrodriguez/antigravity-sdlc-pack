---
name: sdlc-release-mgmt
description: Use when preparing a release, bumping version numbers according to SemVer, updating the changelog, creating git tags, or drafting GitHub releases.
---

# Release, SemVer & Changelog Management Workflow

Follow this standardized workflow to manage releases, calculate semantic version bumps, update changelogs, and publish GitHub releases.

---

## Phase 1: Working Tree Check & Commit Triage
1. Verify the working tree is clean before starting a release:
   ```bash
   git status --porcelain
   ```
   *(If uncommitted changes exist, stop and ask the user whether to stash or commit them first).*
2. Locate the latest release tag:
   ```bash
   git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
   ```
3. Inspect all commits since that tag:
   ```bash
   git log <latest-tag>..HEAD --oneline
   ```
4. Parse commits according to Conventional Commits:
   - `feat!:` or `BREAKING CHANGE:` $\rightarrow$ Breaking change
   - `feat:` $\rightarrow$ New feature
   - `fix:` / `perf:` $\rightarrow$ Bug fix or performance enhancement
   - `docs:`, `chore:`, `refactor:`, `test:` $\rightarrow$ Maintenance (typically excluded from public release highlights)

---

## Phase 2: Semantic Version (SemVer) Calculation
Apply SemVer 2.0 (`MAJOR.MINOR.PATCH`):
- **MAJOR bump** (`X+1.0.0`): Any breaking API change or `feat!:`.
- **MINOR bump** (`X.Y+1.0`): Backwards-compatible new features (`feat:`).
- **PATCH bump** (`X.Y.Z+1`): Backwards-compatible bug fixes or performance improvements (`fix:`, `perf:`).

Confirm the target version with the user before proceeding.

---

## Phase 3: Changelog Generation & Version Manifest Update
1. Update or create `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format:
   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD
   ### Added
   - List new features...
   ### Fixed
   - List bug fixes...
   ### Changed / Breaking Changes
   - List breaking modifications...
   ```
2. Update version manifests in the project if applicable (e.g., `package.json`, `Cargo.toml`, `pyproject.toml`, `plugin.json`, or `version.txt`).

---

## Phase 4: Git Tagging & GitHub Release Creation

> [!IMPORTANT]
> **Explicit Confirmation Gate**: Present the proposed `CHANGELOG.md` diff and target tag `vX.Y.Z` to the user. Wait for explicit confirmation before committing, tagging, pushing, or publishing the GitHub release.

1. Stage and commit **only** the release files (never use `git commit -a`, which stages unrelated files and misses newly created untracked files):
   ```bash
   git add CHANGELOG.md <modified-manifest-files>
   git commit -m "chore(release): bump version to vX.Y.Z"
   ```
2. Create an annotated Git tag:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```
3. Push commit and tag to remote:
   ```bash
   git push origin HEAD --follow-tags
   ```
4. Publish the official GitHub Release using `gh` CLI with the current version's release notes:
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "<extracted-changelog-section-for-vX.Y.Z>"
   ```
5. Return the published release URL to the user.
