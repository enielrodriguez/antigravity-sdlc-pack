# PowerShell script for Windows environments
$RepoRoot = Split-Path -Parent $PSScriptRoot
Write-Host "🚀 Syncing universal SDLC suite from: $RepoRoot"

# 1. Google Antigravity
if (Get-Command agy -ErrorAction SilentlyContinue) {
    Write-Host "🔹 [Google Antigravity] Registering plugin via agy CLI..."
    agy plugin install "$RepoRoot"
} else {
    Write-Host "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
}

# 2. Anthropic Claude Code (%USERPROFILE%\.claude)
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
if (-not (Test-Path $ClaudeDir)) { New-Item -ItemType Directory -Path $ClaudeDir | Out-Null }
New-Item -ItemType SymbolicLink -Path (Join-Path $ClaudeDir "CLAUDE.md") -Target (Join-Path $RepoRoot "rules\AGENTS.md") -Force | Out-Null
New-Item -ItemType SymbolicLink -Path (Join-Path $ClaudeDir "skills") -Target (Join-Path $RepoRoot "skills") -Force | Out-Null
Write-Host "   ✔ Configured $ClaudeDir (CLAUDE.md and skills)"

# 3. GitHub Copilot (%USERPROFILE%\.copilot)
$CopilotDir = Join-Path $env:USERPROFILE ".copilot"
if (-not (Test-Path $CopilotDir)) { New-Item -ItemType Directory -Path $CopilotDir | Out-Null }
New-Item -ItemType SymbolicLink -Path (Join-Path $CopilotDir "copilot-instructions.md") -Target (Join-Path $RepoRoot "rules\AGENTS.md") -Force | Out-Null
New-Item -ItemType SymbolicLink -Path (Join-Path $CopilotDir "skills") -Target (Join-Path $RepoRoot "skills") -Force | Out-Null
Write-Host "   ✔ Configured $CopilotDir (copilot-instructions.md and skills)"

Write-Host "`n🎉 All global platforms (Antigravity, Claude Code, GitHub Copilot) are now wired to: $RepoRoot"
