#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Syncing universal SDLC suite from: ${REPO_ROOT}"

# 1. Google Antigravity
if command -v agy &>/dev/null; then
  echo "🔹 [Google Antigravity] Registering plugin via agy CLI..."
  agy plugin install "${REPO_ROOT}"
else
  echo "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
fi

# 2. Anthropic Claude Code
echo "🔹 [Claude Code] Setting up global user environment (~/.claude)..."
mkdir -p "${HOME}/.claude"
ln -sf "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.claude/CLAUDE.md"
ln -sfn "${REPO_ROOT}/skills" "${HOME}/.claude/skills"
echo "   ✔ Linked ~/.claude/CLAUDE.md -> rules/AGENTS.md"
echo "   ✔ Linked ~/.claude/skills -> skills/"

# 3. GitHub Copilot
echo "🔹 [GitHub Copilot] Setting up global user environment (~/.copilot)..."
mkdir -p "${HOME}/.copilot"
ln -sf "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.copilot/copilot-instructions.md"
ln -sfn "${REPO_ROOT}/skills" "${HOME}/.copilot/skills"
echo "   ✔ Linked ~/.copilot/copilot-instructions.md -> rules/AGENTS.md"
echo "   ✔ Linked ~/.copilot/skills -> skills/"

echo ""
echo "🎉 All global platforms (Antigravity, Claude Code, GitHub Copilot) are now wired to: ${REPO_ROOT}"
