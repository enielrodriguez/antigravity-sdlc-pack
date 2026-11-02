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

Deploys the universal SDLC suite (rules and skills) to global AI coding tools.
Uses clean managed copies to ensure deterministic updates, branch safety,
and zero filesystem privilege issues.

Options:
  -a, --all          Force deployment to all platforms regardless of detection
      --antigravity  Deploy to Google Antigravity only
      --claude       Deploy to Anthropic Claude Code only
      --copilot      Deploy to GitHub Copilot only
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

# If no specific target flag was supplied and --all was not passed, use fast auto-detection
if [ "$SPECIFIC_TARGET" = false ] && [ "$FORCE_ALL" = false ]; then
  # 1. Antigravity: binary or dot-dir
  if command -v agy &>/dev/null || [ -d "${HOME}/.gemini" ]; then
    TARGET_AGY=true
  fi

  # 2. Claude Code: binary or dot-dir
  if command -v claude &>/dev/null || [ -d "${HOME}/.claude" ]; then
    TARGET_CLAUDE=true
  fi

  # 3. GitHub Copilot: unified dot-dir or copilot binary
  if [ -d "${HOME}/.copilot" ] || command -v copilot &>/dev/null; then
    TARGET_COPILOT=true
  fi
elif [ "$FORCE_ALL" = true ]; then
  TARGET_AGY=true
  TARGET_CLAUDE=true
  TARGET_COPILOT=true
fi

echo "🚀 Deploying universal SDLC suite from: ${REPO_ROOT}"
echo ""

# ---------------------------------------------------------------------------
# 1. Google Antigravity
# ---------------------------------------------------------------------------
if [ "$TARGET_AGY" = true ]; then
  if command -v agy &>/dev/null; then
    echo "🔹 [Google Antigravity] Installing/Updating plugin package..."
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
  echo "🔹 [Claude Code] Deploying suite to ~/.claude..."
  mkdir -p "${HOME}/.claude"
  
  # Deploy rules
  [ -L "${HOME}/.claude/CLAUDE.md" ] && rm -f "${HOME}/.claude/CLAUDE.md"
  cp -f "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.claude/CLAUDE.md"
  
  # Deploy skills (clean target to prevent stale orphans on update)
  [ -L "${HOME}/.claude/skills" ] && rm -f "${HOME}/.claude/skills"
  mkdir -p "${HOME}/.claude/skills"
  rm -rf "${HOME}/.claude/skills"/*
  cp -rf "${REPO_ROOT}/skills/"* "${HOME}/.claude/skills/"
  
  echo "   ✔ Deployed ~/.claude/CLAUDE.md"
  echo "   ✔ Deployed ~/.claude/skills/ (8 skills)"
else
  echo "⏭️  [Claude Code] Not detected on this machine. Skipping (use --all or --claude to force)."
fi

# ---------------------------------------------------------------------------
# 3. GitHub Copilot
# ---------------------------------------------------------------------------
if [ "$TARGET_COPILOT" = true ]; then
  echo "🔹 [GitHub Copilot] Deploying suite to ~/.copilot..."
  mkdir -p "${HOME}/.copilot"
  
  # Deploy rules
  [ -L "${HOME}/.copilot/copilot-instructions.md" ] && rm -f "${HOME}/.copilot/copilot-instructions.md"
  cp -f "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.copilot/copilot-instructions.md"
  
  # Deploy skills (clean target to prevent stale orphans on update)
  [ -L "${HOME}/.copilot/skills" ] && rm -f "${HOME}/.copilot/skills"
  mkdir -p "${HOME}/.copilot/skills"
  rm -rf "${HOME}/.copilot/skills"/*
  cp -rf "${REPO_ROOT}/skills/"* "${HOME}/.copilot/skills/"
  
  echo "   ✔ Deployed ~/.copilot/copilot-instructions.md"
  echo "   ✔ Deployed ~/.copilot/skills/ (8 skills)"
else
  echo "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use --all or --copilot to force)."
fi

echo ""
echo "✨ Global deployment finished."
