<#
.SYNOPSIS
    Deploys universal SDLC rules and skills to global AI coding tools on Windows.
    Fully compatible with Windows PowerShell 5.1 and PowerShell 7+.

.DESCRIPTION
    Automatically detects which tools (Antigravity, Claude Code, GitHub Copilot)
    are installed on your system and deploys clean copies.
    Features:
      - Non-destructive: Existing instructions are automatically backed up (.bak.<timestamp>)
      - Surgical: Only updates pack-owned skills; preserves your custom skills
      - Zero Administrator privileges required

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

# Helper: Deploy rules file safely with backup if destination differs
function Deploy-RuleFile {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestPath,
        [Parameter(Mandatory = $true)][string]$Label
    )

    if (Test-Path -LiteralPath $DestPath) {
        $SourceHash = (Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash
        $DestHash = (Get-FileHash -LiteralPath $DestPath -Algorithm SHA256).Hash

        if ($SourceHash -ne $DestHash) {
            $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $BackupPath = "$DestPath.bak.$Timestamp"
            Copy-Item -LiteralPath $DestPath -Destination $BackupPath -Force
            Write-Host "   ⚠️  Existing $Label differed from pack standards." -ForegroundColor Yellow
            Write-Host "       Original safely backed up to: $(Split-Path -Leaf $BackupPath)" -ForegroundColor Yellow
        }
        Remove-Item -LiteralPath $DestPath -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force
}

# Helper: Deploy skills surgically without wiping user's other skills
function Deploy-SkillsSurgically {
    param(
        [Parameter(Mandatory = $true)][string]$SourceSkillsDir,
        [Parameter(Mandatory = $true)][string]$DestSkillsDir
    )

    if (-not (Test-Path -LiteralPath $DestSkillsDir)) {
        New-Item -ItemType Directory -Path $DestSkillsDir -Force | Out-Null
    }

    $Count = 0
    Get-ChildItem -LiteralPath $SourceSkillsDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $TargetSkillPath = Join-Path $DestSkillsDir $SkillName

        if (Test-Path -LiteralPath $TargetSkillPath) {
            Remove-Item -LiteralPath $TargetSkillPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -LiteralPath $_.FullName -Destination $TargetSkillPath -Recurse -Force
        $Count++
    }

    Write-Host "   ✔ Surgically deployed $Count SDLC skills (existing custom skills preserved)"
}

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
    Deploy-RuleFile -SourcePath (Join-Path $RepoRoot "rules\AGENTS.md") -DestPath (Join-Path $ClaudeDir "CLAUDE.md") -Label "CLAUDE.md"
    Deploy-SkillsSurgically -SourceSkillsDir (Join-Path $RepoRoot "skills") -DestSkillsDir (Join-Path $ClaudeDir "skills")
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
    Deploy-RuleFile -SourcePath (Join-Path $RepoRoot "rules\AGENTS.md") -DestPath (Join-Path $CopilotDir "copilot-instructions.md") -Label "copilot-instructions.md"
    Deploy-SkillsSurgically -SourceSkillsDir (Join-Path $RepoRoot "skills") -DestSkillsDir (Join-Path $CopilotDir "skills")
} else {
    Write-Host "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use -All or -Copilot to force)."
}

Write-Host "`n✨ Global deployment finished."
