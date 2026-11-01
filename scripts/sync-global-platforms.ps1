param(
    [switch]$All,
    [switch]$Antigravity,
    [switch]$Claude,
    [switch]$Copilot
)

$RepoRoot = Split-Path -Parent $PSScriptRoot

$TargetAgy = $false
$TargetClaude = $false
$TargetCopilot = $false

$SpecificTarget = $Antigravity -or $Claude -or $Copilot

if (-not $SpecificTarget -and -not $All) {
    # 1. Detect Antigravity
    $GeminiDir = Join-Path $env:USERPROFILE ".gemini"
    if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path $GeminiDir)) {
        $TargetAgy = $true
    }

    # 2. Detect Claude Code
    $ClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $ClaudeDir)) {
        $TargetClaude = $true
    }

    # 3. Detect GitHub Copilot
    $CopilotDir = Join-Path $env:USERPROFILE ".copilot"
    if ((Get-Command copilot -ErrorAction SilentlyContinue) -or (Test-Path $CopilotDir)) {
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

# 1. Google Antigravity
if ($TargetAgy) {
    if (Get-Command agy -ErrorAction SilentlyContinue) {
        Write-Host "🔹 [Google Antigravity] Registering plugin via agy CLI..."
        agy plugin install "$RepoRoot"
    } else {
        Write-Host "⚠️  [Google Antigravity] 'agy' CLI not found on PATH. Skipping Antigravity registration."
    }
} else {
    Write-Host "⏭️  [Google Antigravity] Not detected. Skipping (use -All to force)."
}

# 2. Anthropic Claude Code
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
if ($TargetClaude) {
    Write-Host "🔹 [Claude Code] Setting up global user environment ($ClaudeDir)..."
    if (-not (Test-Path $ClaudeDir)) { New-Item -ItemType Directory -Path $ClaudeDir | Out-Null }
    New-Item -ItemType SymbolicLink -Path (Join-Path $ClaudeDir "CLAUDE.md") -Target (Join-Path $RepoRoot "rules\AGENTS.md") -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path (Join-Path $ClaudeDir "skills") -Target (Join-Path $RepoRoot "skills") -Force | Out-Null
    Write-Host "   ✔ Configured $ClaudeDir (CLAUDE.md and skills)"
} else {
    Write-Host "⏭️  [Claude Code] Not detected on this machine. Skipping (use -All or -Claude to force)."
}

# 3. GitHub Copilot
$CopilotDir = Join-Path $env:USERPROFILE ".copilot"
if ($TargetCopilot) {
    Write-Host "🔹 [GitHub Copilot] Setting up global user environment ($CopilotDir)..."
    if (-not (Test-Path $CopilotDir)) { New-Item -ItemType Directory -Path $CopilotDir | Out-Null }
    New-Item -ItemType SymbolicLink -Path (Join-Path $CopilotDir "copilot-instructions.md") -Target (Join-Path $RepoRoot "rules\AGENTS.md") -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path (Join-Path $CopilotDir "skills") -Target (Join-Path $RepoRoot "skills") -Force | Out-Null
    Write-Host "   ✔ Configured $CopilotDir (copilot-instructions.md and skills)"
} else {
    Write-Host "⏭️  [GitHub Copilot] Not detected on this machine. Skipping (use -All or -Copilot to force)."
}

Write-Host "`n✨ Global synchronization finished."
