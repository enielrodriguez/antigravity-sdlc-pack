<#
.SYNOPSIS
    Syncs universal SDLC rules and skills to global AI coding tools on Windows.
    Fully compatible with Windows PowerShell 5.1 and PowerShell 7+.

.DESCRIPTION
    By default, it automatically detects which tools (Antigravity, Claude Code,
    GitHub Copilot) are installed on your system and configures only active ones.
    Uses NTFS Junctions and HardLinks for zero-privilege non-admin support.

.PARAMETER All
    Force configuration for all platforms regardless of detection.

.PARAMETER Antigravity
    Configure Google Antigravity only.

.PARAMETER Claude
    Configure Anthropic Claude Code only.

.PARAMETER Copilot
    Configure GitHub Copilot only.
#>

param(
    [switch]$All,
    [switch]$Antigravity,
    [switch]$Claude,
    [switch]$Copilot
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Helper: Create directory link (Junction requires zero admin privileges on NTFS)
function Link-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$LinkPath,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )
    if (Test-Path -LiteralPath $LinkPath) {
        try {
            [System.IO.Directory]::Delete($LinkPath, $false)
        } catch {
            Remove-Item -LiteralPath $LinkPath -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    try {
        # PS 5.1 & PS 7 compatible: -Value specifies target for Junction
        New-Item -ItemType Junction -Path $LinkPath -Value $TargetPath -Force | Out-Null
        Write-Host "   ✔ Linked directory $LinkPath -> $TargetPath"
    } catch {
        Write-Warning "Failed to create directory junction for $LinkPath. Falling back to folder copy."
        Copy-Item -Path $TargetPath -Destination $LinkPath -Recurse -Force
        Write-Host "   ✔ Copied directory $LinkPath (fallback)"
    }
}

# Helper: Create file link (SymbolicLink -> HardLink -> Copy fallback)
function Link-File {
    param(
        [Parameter(Mandatory = $true)][string]$LinkPath,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )
    if (Test-Path -LiteralPath $LinkPath) {
        Remove-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
    }
    try {
        # Requires Developer Mode or Admin on Windows
        New-Item -ItemType SymbolicLink -Path $LinkPath -Value $TargetPath -Force -ErrorAction Stop | Out-Null
        Write-Host "   ✔ Linked file $LinkPath"
    } catch {
        try {
            # Hard link works on same NTFS volume without admin rights
            New-Item -ItemType HardLink -Path $LinkPath -Value $TargetPath -Force -ErrorAction Stop | Out-Null
            Write-Host "   ✔ Hardlinked file $LinkPath (non-admin fallback)"
        } catch {
            Copy-Item -LiteralPath $TargetPath -Destination $LinkPath -Force
            Write-Host "   ✔ Copied file $LinkPath (fallback)"
        }
    }
}

# Determine target platforms
$TargetAgy = $false
$TargetClaude = $false
$TargetCopilot = $false

$SpecificTarget = $Antigravity.IsPresent -or $Claude.IsPresent -or $Copilot.IsPresent

if (-not $SpecificTarget -and -not $All) {
    # 1. Detect Antigravity
    $GeminiDir = Join-Path $env:USERPROFILE ".gemini"
    if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $GeminiDir)) {
        $TargetAgy = $true
    }

    # 2. Detect Claude Code
    $ClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $ClaudeDir)) {
        $TargetClaude = $true
    }

    # 3. Detect GitHub Copilot
    $CopilotDir = Join-Path $env:USERPROFILE ".copilot"
    $HasCopilotCli = [bool](Get-Command copilot -ErrorAction SilentlyContinue)
    $HasCopilotDir = Test-Path -LiteralPath $CopilotDir
    $HasCodeCopilot = $false
    if (Get-Command code -ErrorAction SilentlyContinue) {
        try {
            $exts = & code --list-extensions 2>$null
            if ($exts -match "github\.copilot") { $HasCodeCopilot = $true }
        } catch {}
    }

    if ($HasCopilotCli -or $HasCopilotDir -or $HasCodeCopilot) {
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

Write-Host "🚀 Syncing universal SDLC suite from: $RepoRoot`n"

# ---------------------------------------------------------------------------
# 1. Google Antigravity
# ---------------------------------------------------------------------------
if ($TargetAgy) {
    if (Get-Command agy -ErrorAction SilentlyContinue) {
        Write-Host "🔹 [Google Antigravity] Registering plugin via agy CLI..."
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
    Write-Host "🔹 [Claude Code] Setting up global user environment ($ClaudeDir)..."
    if (-not (Test-Path -LiteralPath $ClaudeDir)) {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    }
    Link-File -LinkPath (Join-Path $ClaudeDir "CLAUDE.md") -TargetPath (Join-Path $RepoRoot "rules\AGENTS.md")
    Link-Directory -LinkPath (Join-Path $ClaudeDir "skills") -TargetPath (Join-Path $RepoRoot "skills")
} else {
    Write-Host "⏭️  [Claude Code] Not detected on this machine. Skipping (use -All or -Claude to force)."
}

# ---------------------------------------------------------------------------
# 3. GitHub Copilot
# ---------------------------------------------------------------------------
$CopilotDir = Join-Path $env:USERPROFILE ".copilot"
if ($TargetCopilot) {
    Write-Host "🔹 [GitHub Copilot] Setting up global user environment ($CopilotDir)..."
    if (-not (Test-Path -LiteralPath $CopilotDir)) {
        New-Item -ItemType Directory -Path $CopilotDir -Force | Out-Null
    }
    Link-File -LinkPath (Join-Path $CopilotDir "copilot-instructions.md") -TargetPath (Join-Path $RepoRoot "rules\AGENTS.md")
    Link-Directory -LinkPath (Join-Path $CopilotDir "skills") -TargetPath (Join-Path $RepoRoot "skills")
} else {
    Write-Host "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use -All or -Copilot to force)."
}

Write-Host "`n✨ Global synchronization finished."
