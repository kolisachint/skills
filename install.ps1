$ErrorActionPreference = "Stop"

# Portable AI Skillkit — One-shot installer
# Usage:
#   irm https://raw.githubusercontent.com/YOURNAME/skills/main/install.ps1 | iex
#   .\install.ps1 --target C:\code\repo

$RepoUrl = if ($env:SKILLKIT_REPO) { $env:SKILLKIT_REPO } else { "https://github.com/kolisachint/skills.git" }
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# If running from cloned repo, use local scripts. Otherwise clone temp copy.
$skillkitScript = Join-Path $ScriptDir "scripts\skillkit.ps1"
if (-not (Test-Path $skillkitScript)) {
  $tempDir = Join-Path $env:TEMP ("skillkit-" + [Guid]::NewGuid().ToString())
  Write-Host "→ Cloning Portable AI Skillkit..."
  git clone --depth 1 $RepoUrl $tempDir | Out-Null
  $skillkitScript = Join-Path $tempDir "scripts\skillkit.ps1"
}

# Forward all arguments to the real installer
& $skillkitScript install @args
