#!/usr/bin/env pwsh
# Remove skills from local project and global directories

param(
    [string]$Target = ".",
    [string]$Platform = "",
    [switch]$All = $false,
    [switch]$Help = $false,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Skills
)

if ($Help) {
    @"
Usage: remove.ps1 [options] <skill-name> [<skill-name> ...]

Remove skills from both local project and global directories.

Options:
  -Target PATH          Target directory (default: .)
  -Platform PLATFORM    Target platform for removal
  -All                  Remove ALL skills everywhere
  -Help                 Show this help

Examples:
  .\remove.ps1 caveman                    # Remove single skill
  .\remove.ps1 caveman, grill-me          # Remove multiple
  .\remove.ps1 -All                       # Remove everything everywhere
  .\remove.ps1 -Platform copilot caveman  # Remove from Copilot

  # Via Invoke-Expression:
  irm https://raw.githubusercontent.com/kolisachint/skills/main/remove.ps1 | iex -skill caveman
"@
    exit 0
}

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = "." }
$Catalog = Join-Path $ScriptDir "catalog.tsv"

# Global skill directories
$GlobalSkillDirs = @(
    "$env:USERPROFILE/.claude/skills",
    "$env:USERPROFILE/.claude/commands",
    "$env:USERPROFILE/.pi/skills",
    "$env:USERPROFILE/.opencode/skills",
    "$env:USERPROFILE/.opencode/command",
    "$env:USERPROFILE/.config/opencode/skills",
    "$env:USERPROFILE/.config/opencode/command",
    "$env:USERPROFILE/.codex/skills",
    "$env:USERPROFILE/.gemini/commands",
    "$env:USERPROFILE/.github/copilot/skills"
)

function Remove-GlobalSkill {
    param([string]$SkillName)
    $removed = $false
    
    foreach ($dir in $GlobalSkillDirs) {
        if (Test-Path $dir) {
            $items = Get-ChildItem -Path $dir -Force | Where-Object {
                $_.Name -eq $SkillName -or $_.Name -like "$SkillName-*"
            }
            foreach ($item in $items) {
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "    ✓ Removed from ${dir}: $($item.Name)"
                $removed = $true
            }
        }
    }
    return $removed
}

function Remove-NpmGlobal {
    param([string]$Pattern)
    try {
        $npmList = npm list -g --depth=0 2>$null | Select-String -Pattern "^[^\s]*[├└]─"
        $matching = $npmList | Where-Object { $_ -match $Pattern }
        if ($matching) {
            foreach ($line in $matching) {
                if ($line -match "([a-zA-Z0-9@\-/_]+)@") {
                    $pkg = $matches[1]
                    npm uninstall -g $pkg 2>$null | Out-Null
                    Write-Host "    ✓ Removed npm global: $pkg"
                }
            }
            return $true
        }
    } catch {}
    return $false
}

# Resolve target
New-Item -ItemType Directory -Path $Target -Force | Out-Null
$Target = (Resolve-Path $Target).Path

# --All: Remove everything
if ($All) {
    Write-Host "Removing ALL skills from $Target"
    
    # Local
    try {
        $origDir = Get-Location
        Set-Location $Target
        npx skills remove --all --yes 2>$null | Out-Null
        Set-Location $origDir
        Write-Host "  ✓ All local skills removed"
    } catch {
        Set-Location $origDir
        Write-Host "  ⚠ Local removal failed or none found"
    }
    
    # Global
    Write-Host "Removing global skills..."
    foreach ($dir in $GlobalSkillDirs) {
        if (Test-Path $dir) {
            Remove-Item -Path "$dir/*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ Cleared $dir"
        }
    }
    
    Write-Host ""
    Write-Host "✓ Removal complete"
    exit 0
}

# Check for skills
if ($Skills.Count -eq 0) {
    Write-Error "remove requires a SKILL name (or -All)"
    exit 1
}

Write-Host "Removing skills from $Target"

foreach ($skill in $Skills) {
    Write-Host ""
    Write-Host "→ $skill"
    
    # Determine remove command
    $removeCmd = $null
    
    # Look up in catalog
    if (Test-Path $Catalog) {
        $catalogContent = Get-Content $Catalog
        $entry = $catalogContent | Where-Object { $_ -match "^$skill`t" } | Select-Object -First 1
        if ($entry) {
            $fields = $entry -split "`t"
            if ($fields.Length -ge 9 -and $fields[8] -and $fields[8] -ne "-") {
                $removeCmd = $fields[8]
            } else {
                # Derive from install command
                $installCmd = $fields[6]
                if ($installCmd -match '^npx skills add') {
                    $removeCmd = "npx skills remove $skill --yes"
                } elseif ($installCmd -match '^npm\s+install\s+-g\s+(.+)$') {
                    $pkg = $matches[1].Trim()
                    $removeCmd = "npm uninstall -g $pkg"
                } elseif ($installCmd -match '^pi\s+install\s+(.+)$') {
                    $pkg = $matches[1].Trim()
                    $removeCmd = "pi remove $pkg"
                }
            }
        }
    }
    
    # Platform-specific override
    if ($Platform -eq "copilot") {
        if (Get-Command copilot -ErrorAction SilentlyContinue) {
            $removeCmd = "copilot -- plugin uninstall $skill"
        } else {
            $removeCmd = "gh copilot -- plugin uninstall $skill"
        }
    } elseif ($Platform -eq "pi" -and $skill -eq "plannotator") {
        $removeCmd = "pi remove npm:@plannotator/pi-extension"
    }
    
    # Fallback
    if (-not $removeCmd) {
        $removeCmd = "npx skills remove $skill --yes"
    }
    
    # Local removal
    Write-Host "  Local: $removeCmd"
    try {
        $origDir = Get-Location
        Set-Location $Target
        Invoke-Expression $removeCmd | Out-Null
        Set-Location $origDir
        Write-Host "    ✓ Removed from local project"
    } catch {
        Set-Location $origDir
        Write-Host "    ℹ Not found in local project (or already removed)"
    }
    
    # Global removal
    Write-Host "  Global directories..."
    if (Remove-GlobalSkill -SkillName $skill) {
        # Already printed
    } else {
        Write-Host "    ℹ Not found in global directories"
    }
    
    # NPM global
    Write-Host "  NPM global packages..."
    if (Remove-NpmGlobal -Pattern $skill) {
        # Already printed
    } else {
        Write-Host "    ℹ No matching npm global packages"
    }
}

Write-Host ""
Write-Host "✓ Removal complete"
