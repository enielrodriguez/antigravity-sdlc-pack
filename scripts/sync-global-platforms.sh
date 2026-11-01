#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Mode flags
FORCE_ALL=false
TARGET_AGY=false
TARGET_CLAUDE=false
TARGET_COPILOT=false
SPECIFIC_TARGET=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Syncs universal SDLC rules and skills from this repository to global AI coding tools.
By default, it automatically detects which tools are installed on your system.

Options:
  -a, --all          Force configuration for all platforms regardless of detection
      --antigravity  Configure Google Antigravity only
      --claude       Configure Anthropic Claude Code only
      --copilot      Configure GitHub Copilot only
  -h, --help         Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--all)
      FORCE_ALL=true
      shift
      ;;
    --antigravity)
      TARGET_AGY=true
      SPECIFIC_TARGET=true
      shift
      ;;
    --claude)
      TARGET_CLAUDE=true
      SPECIFIC_TARGET=true
      shift
      ;;
    --copilot)
      TARGET_COPILOT=true
      SPECIFIC_TARGET=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

# If no specific target flag was supplied and --all was not passed, use auto-detection
if [ "$SPECIFIC_TARGET" = false ] && [ "$FORCE_ALL" = false ]; then
  # 1. Detect Google Antigravity
  if command -v agy &>/dev/null || [ -d "${HOME}/.gemini" ]; then
    TARGET_AGY=true
  fi

  # 2. Detect Claude Code
  if command -v claude &>/dev/null || [ -d "${HOME}/.claude" ]; then
    TARGET_CLAUDE=true
  fi

  # 3. Detect GitHub Copilot (binary, existing dot-dir, gh extension, or VS Code extension)
  if command -v copilot &>/dev/null || \
     [ -d "${HOME}/.copilot" ] || \
     (command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -qi copilot) || \
     (command -v code &>/dev/null && code --list-extensions 2>/dev/null | grep -qi "github.copilot"); then
    TARGET_COPILOT=true
  fi
elif [ "$FORCE_ALL" = true ]; then
  TARGET_AGY=true
  TARGET_CLAUDE=true
  TARGET_COPILOT=true
fi

echo "🚀 Syncing universal SDLC suite from: ${REPO_ROOT}"
echo ""

# ---------------------------------------------------------------------------
# 1. Google Antigravity
# ---------------------------------------------------------------------------
if [ "$TARGET_AGY" = true ]; then
  if command -v agy &>/dev/null; then
    echo "🔹 [Google Antigravity] Registering plugin via agy CLI..."
    agy plugin install "${REPO_ROOT}"
  else
    echo "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
  fi
else
  echo "⏭️  [Google Antigravity] Not detected. Skipping (use --all to force)."
fi

# ---------------------------------------------------------------------------
# 2. Anthropic Claude Code
# ---------------------------------------------------------------------------
if [ "$TARGET_CLAUDE" = true ]; then
  echo "🔹 [Claude Code] Setting up global user environment (~/.claude)..."
  mkdir -p "${HOME}/.claude"
  ln -sf "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.claude/CLAUDE.md"
  ln -sfn "${REPO_ROOT}/skills" "${HOME}/.claude/skills"
  echo "   ✔ Linked ~/.claude/CLAUDE.md -> rules/AGENTS.md"
  echo "   ✔ Linked ~/.claude/skills -> skills/"
else
  echo "⏭️  [Claude Code] Not detected on this machine. Skipping (use --all or --claude to force)."
fi

# ---------------------------------------------------------------------------
# 3. GitHub Copilot
# ---------------------------------------------------------------------------
if [ "$TARGET_COPILOT" = true ]; then
  echo "🔹 [GitHub Copilot] Setting up global user environment (~/.copilot)..."
  mkdir -p "${HOME}/.copilot"
  ln -sf "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.copilot/copilot-instructions.md"
  ln -sfn "${REPO_ROOT}/skills" "${HOME}/.copilot/skills"
  echo "   ✔ Linked ~/.copilot/copilot-instructions.md -> rules/AGENTS.md"
  echo "   ✔ Linked ~/.copilot/skills -> skills/"
else
  echo "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use --all or --copilot to force)."
fi

echo ""
echo "✨ Global synchronization finished."
