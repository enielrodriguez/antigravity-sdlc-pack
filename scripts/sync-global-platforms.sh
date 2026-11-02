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
Features:
  - Non-destructive: Existing instructions are automatically backed up (.bak.<timestamp>)
  - Surgical: Only updates pack-owned skills; preserves your custom skills
  - Zero-drift & Branch-safe: Managed copy ensures all tools update deterministically

Options:
  -a, --all          Force deployment to all platforms regardless of detection
      --antigravity  Deploy to Google Antigravity only
      --claude       Deploy to Anthropic Claude Code only
      --copilot      Deploy to GitHub Copilot only
  -h, --help         Show this help message
EOF
}

# Helper: Deploy rules file safely with backup if destination differs
deploy_rule_file() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -f "$dest" ]; then
    if ! cmp -s "$src" "$dest"; then
      local timestamp
      timestamp=$(date +%Y%m%d_%H%M%S)
      local bak="${dest}.bak.${timestamp}"
      cp "$dest" "$bak"
      echo "   ⚠️  Existing ${label} differed from pack standards."
      echo "       Original safely backed up to: $(basename "$bak")"
    fi
  fi
  cp -f "$src" "$dest"
}

# Helper: Deploy skills surgically without wiping user's other skills
deploy_skills_surgically() {
  local src_dir="$1"
  local dest_dir="$2"

  if [ -L "$dest_dir" ]; then
    rm -f "$dest_dir"
  fi
  mkdir -p "$dest_dir"

  local count=0
  for skill_path in "${src_dir}"/*; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name=$(basename "$skill_path")
    rm -rf "${dest_dir}/${skill_name}"
    cp -rf "$skill_path" "${dest_dir}/"
    count=$((count + 1))
  done
  echo "   ✔ Surgically deployed ${count} SDLC skills (existing custom skills preserved)"
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
  deploy_rule_file "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.claude/CLAUDE.md" "~/.claude/CLAUDE.md"
  deploy_skills_surgically "${REPO_ROOT}/skills" "${HOME}/.claude/skills"
else
  echo "⏭️  [Claude Code] Not detected on this machine. Skipping (use --all or --claude to force)."
fi

# ---------------------------------------------------------------------------
# 3. GitHub Copilot
# ---------------------------------------------------------------------------
if [ "$TARGET_COPILOT" = true ]; then
  echo "🔹 [GitHub Copilot] Deploying suite to ~/.copilot..."
  mkdir -p "${HOME}/.copilot"
  deploy_rule_file "${REPO_ROOT}/rules/AGENTS.md" "${HOME}/.copilot/copilot-instructions.md" "~/.copilot/copilot-instructions.md"
  deploy_skills_surgically "${REPO_ROOT}/skills" "${HOME}/.copilot/skills"
else
  echo "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use --all or --copilot to force)."
fi

echo ""
echo "✨ Global deployment finished."
