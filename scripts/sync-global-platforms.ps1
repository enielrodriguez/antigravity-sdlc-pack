<#
.SYNOPSIS
    Deploys universal SDLC rules and skills to global AI coding tools on Windows.
    Fully compatible with Windows PowerShell 5.1 and PowerShell 7+.

.DESCRIPTION
    Automatically detects which tools (Antigravity, Claude Code, GitHub Copilot)
    are installed on your system and deploys clean copies. Clean copies ensure
    deterministic updates, safe branching, and require zero Administrator privileges.

.PARAMETER All
    Force deployment to all platforms regardless of detection.

.PARAMETER Antigravity
    Deploy to Google Antigravity only.

.PARAMETER Claude
    Deploy to Anthropic Claude Code only.

.PARAMETER Copilot
    Deploy to GitHub Copilot only.
#>

param(
    [switch]$All,
    [switch]$Antigravity,
    [switch]$Claude,
    [switch]$Copilot
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Determine target platforms
$TargetAgy = $false
$TargetClaude = $false
$TargetCopilot = $false

$SpecificTarget = $Antigravity.IsPresent -or $Claude.IsPresent -or $Copilot.IsPresent

if (-not $SpecificTarget -and -not $All) {
    # 1. Antigravity: binary or dot-dir
    $GeminiDir = Join-Path $env:USERPROFILE ".gemini"
    if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $GeminiDir)) {
        $TargetAgy = $true
    }

    # 2. Claude Code: binary or dot-dir
    $ClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $ClaudeDir)) {
        $TargetClaude = $true
    }

    # 3. GitHub Copilot: unified dot-dir or copilot binary
    $CopilotDir = Join-Path $env:USERPROFILE ".copilot"
    if ((Get-Command copilot -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $CopilotDir)) {
        $TargetCopilot = $true
    }
} elseif ($All) {
    $TargetAgy = $true
    $TargetClaude = $true
    $TargetCopilot = $true
} else {
    $TargetAgy = $Antigravity.IsPresent
    $TargetClaude = $Claude.IsPresent
    $TargetCopilot = $Copilot.IsPresent
}

Write-Host "🚀 Deploying universal SDLC suite from: $RepoRoot`n"

# ---------------------------------------------------------------------------
# 1. Google Antigravity
# ---------------------------------------------------------------------------
if ($TargetAgy) {
    if (Get-Command agy -ErrorAction SilentlyContinue) {
        Write-Host "🔹 [Google Antigravity] Installing/Updating plugin package..."
        & agy plugin install "$RepoRoot"
    } else {
        Write-Host "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
    }
} else {
    Write-Host "⏭️  [Google Antigravity] Not detected. Skipping (use -All to force)."
}

# ---------------------------------------------------------------------------
# 2. Anthropic Claude Code
# ---------------------------------------------------------------------------
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
if ($TargetClaude) {
    Write-Host "🔹 [Claude Code] Deploying suite to $ClaudeDir..."
    if (-not (Test-Path -LiteralPath $ClaudeDir)) {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    }

    # Deploy rules
    $ClaudeRules = Join-Path $ClaudeDir "CLAUDE.md"
    if (Test-Path -LiteralPath $ClaudeRules) {
        Remove-Item -LiteralPath $ClaudeRules -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -LiteralPath (Join-Path $RepoRoot "rules\AGENTS.md") -Destination $ClaudeRules -Force

    # Deploy skills (clean destination to prevent stale orphans on update)
    $ClaudeSkills = Join-Path $ClaudeDir "skills"
    if (Test-Path -LiteralPath $ClaudeSkills) {
        Remove-Item -LiteralPath $ClaudeSkills -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $ClaudeSkills -Force | Out-Null
    Copy-Item -Path (Join-Path $RepoRoot "skills\*") -Destination $ClaudeSkills -Recurse -Force

    Write-Host "   ✔ Deployed $ClaudeRules"
    Write-Host "   ✔ Deployed $ClaudeSkills (8 skills)"
} else {
    Write-Host "⏭️  [Claude Code] Not detected on this machine. Skipping (use -All or -Claude to force)."
}

# ---------------------------------------------------------------------------
# 3. GitHub Copilot
# ---------------------------------------------------------------------------
$CopilotDir = Join-Path $env:USERPROFILE ".copilot"
if ($TargetCopilot) {
    Write-Host "🔹 [GitHub Copilot] Deploying suite to $CopilotDir..."
    if (-not (Test-Path -LiteralPath $CopilotDir)) {
        New-Item -ItemType Directory -Path $CopilotDir -Force | Out-Null
    }

    # Deploy rules
    $CopilotRules = Join-Path $CopilotDir "copilot-instructions.md"
    if (Test-Path -LiteralPath $CopilotRules) {
        Remove-Item -LiteralPath $CopilotRules -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -LiteralPath (Join-Path $RepoRoot "rules\AGENTS.md") -Destination $CopilotRules -Force

    # Deploy skills (clean destination to prevent stale orphans on update)
    $CopilotSkills = Join-Path $CopilotDir "skills"
    if (Test-Path -LiteralPath $CopilotSkills) {
        Remove-Item -LiteralPath $CopilotSkills -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $CopilotSkills -Force | Out-Null
    Copy-Item -Path (Join-Path $RepoRoot "skills\*") -Destination $CopilotSkills -Recurse -Force

    Write-Host "   ✔ Deployed $CopilotRules"
    Write-Host "   ✔ Deployed $CopilotSkills (8 skills)"
} else {
    Write-Host "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use -All or -Copilot to force)."
}

Write-Host "`n✨ Global deployment finished."
