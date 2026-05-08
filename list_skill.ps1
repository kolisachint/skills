#!/usr/bin/env pwsh
# List user-installed skills across all agent platforms

#!/usr/bin/env pwsh
# List user-installed skills across all agent platforms

param(
    [string]$Format = "default",
    [switch]$Help = $false
)

if ($Help) {
    @"
Usage: list_skill.ps1 [options]

List all user-installed skills (hides system packages).

Options:
  -Format FORMAT    Output format: default|readme (default: default)
  -Help             Show this help

Examples:
  .\list_skill.ps1                           # Human readable output
  .\list_skill.ps1 -Format readme            # Markdown table for README

  # Via Invoke-Expression:
  irm https://raw.githubusercontent.com/kolisachint/skills/main/list_skill.ps1 | iex
"@
    exit 0
}

$ExcludePatterns = '^\.|runtime|system|corepack|^npm$|^@mariozechner/pi-coding-agent$|^@openai/codex$'

# Collect skills
$allSkills = @()

# Local directories
$localDirs = @{
    '.agents' = 'all'
    '.claude' = 'claude'
    '.pi' = 'pi'
    '.opencode' = 'opencode'
    '.codex' = 'codex'
    '.github/copilot' = 'copilot'
}

foreach ($dir in $localDirs.Keys) {
    $skillsDir = Join-Path $dir "skills"
    if (Test-Path $skillsDir) {
        Get-ChildItem -Path $skillsDir -Force | Where-Object {
            $_.Name -notmatch $ExcludePatterns
        } | ForEach-Object {
            $allSkills += [PSCustomObject]@{
                Name = $_.Name
                Platform = $localDirs[$dir]
                Type = "Skill"
            }
        }
    }
}

# Global directories
$globalDirs = @(
    @{ Path = "$env:USERPROFILE/.claude/skills"; Platform = "Claude"; Type = "Skill" }
    @{ Path = "$env:USERPROFILE/.claude/commands"; Platform = "Claude"; Type = "Command" }
    @{ Path = "$env:USERPROFILE/.pi/skills"; Platform = "Pi"; Type = "Skill" }
    @{ Path = "$env:USERPROFILE/.opencode/skills"; Platform = "OpenCode"; Type = "Skill" }
    @{ Path = "$env:USERPROFILE/.opencode/command"; Platform = "OpenCode"; Type = "Command" }
    @{ Path = "$env:USERPROFILE/.config/opencode/skills"; Platform = "OpenCode"; Type = "Skill" }
    @{ Path = "$env:USERPROFILE/.config/opencode/command"; Platform = "OpenCode"; Type = "Command" }
    @{ Path = "$env:USERPROFILE/.codex/skills"; Platform = "Codex"; Type = "Skill" }
    @{ Path = "$env:USERPROFILE/.gemini/commands"; Platform = "Gemini"; Type = "Command" }
    @{ Path = "$env:USERPROFILE/.github/copilot/skills"; Platform = "Copilot"; Type = "Skill" }
)

foreach ($gdir in $globalDirs) {
    if (Test-Path $gdir.Path) {
        Get-ChildItem -Path $gdir.Path -Force | Where-Object {
            $_.Name -notmatch $ExcludePatterns
        } | ForEach-Object {
            $allSkills += [PSCustomObject]@{
                Name = $_.Name
                Platform = $gdir.Platform
                Type = $gdir.Type
            }
        }
    }
}

# Remove duplicates
$allSkills = $allSkills | Sort-Object Name, Platform -Unique

if ($Format -eq "readme") {
    Write-Host "## My Installed Skills"
    Write-Host ""
    Write-Host "| Skill | Platform | Type |"
    Write-Host "|-------|----------|------|"
    
    if ($allSkills.Count -gt 0) {
        foreach ($skill in $allSkills) {
            Write-Host "| $($skill.Name) | $($skill.Platform) | $($skill.Type) |"
        }
    } else {
        Write-Host "| (none) | - | - |"
    }
    Write-Host ""
    Write-Host "*Generated with [Portable AI Skillkit](https://github.com/kolisachint/skills)*"
} else {
    Write-Host "=== LOCAL PROJECT SKILLS ==="
    Write-Host "Directory: $(Get-Location)"
    Write-Host ""
    
    $localFound = $false
    foreach ($dir in $localDirs.Keys) {
        $skillsDir = Join-Path $dir "skills"
        if (Test-Path $skillsDir) {
            $skills = Get-ChildItem -Path $skillsDir -Force | Where-Object {
                $_.Name -notmatch $ExcludePatterns
            }
            if ($skills) {
                $localFound = $true
                Write-Host "📁 $skillsDir/ ($($skills.Count) skills)"
                $skills | ForEach-Object { Write-Host "   • $($_.Name)" }
                Write-Host ""
            }
        }
    }
    
    if (-not $localFound) {
        Write-Host "   (no local skills found)"
        Write-Host ""
    }
    
    Write-Host ""
    Write-Host "=== GLOBAL USER SKILLS ==="
    Write-Host ""
    
    $globalFound = $false
    foreach ($gdir in $globalDirs) {
        if (Test-Path $gdir.Path) {
            $items = Get-ChildItem -Path $gdir.Path -Force | Where-Object {
                $_.Name -notmatch $ExcludePatterns
            }
            if ($items) {
                $globalFound = $true
                $count = $items.Count
                Write-Host "📁 $($gdir.Platform): $($gdir.Path)/ ($count skills)"
                $items | Select-Object -First 20 | ForEach-Object { Write-Host "   • $($_.Name)" }
                if ($count -gt 20) {
                    Write-Host "   ... and $($count - 20) more"
                }
                Write-Host ""
            }
        }
    }
    
    if (-not $globalFound) {
        Write-Host "   (no global skills found)"
        Write-Host ""
    }
    
    Write-Host ""
    Write-Host "=== USER INSTALLED NPM PACKAGES ==="
    Write-Host ""
    try {
        $npmPkgs = npm list -g --depth=0 2>$null | Select-String -Pattern "^[^\s]*[├└]─"
        $filtered = $npmPkgs | Where-Object {
            $_ -notmatch "corepack" -and $_ -notmatch "npm@" -and 
            $_ -notmatch "@mariozechner/pi-coding-agent" -and $_ -notmatch "@openai/codex"
        }
        if ($filtered) {
            $filtered | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "   (no user-installed npm packages)"
        }
    } catch {
        Write-Host "   npm not found"
    }
    
    Write-Host ""
    Write-Host "=== CLI TOOLS ==="
    Write-Host ""
    $tools = @("claude", "codex", "pi", "opencode", "codeburn")
    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            $location = (Get-Command $tool).Source
            Write-Host "✓ $tool`: $location"
        }
    }
    
    Write-Host ""
    Write-Host "=== SUMMARY ==="
    Write-Host ""
    Write-Host "Excluded: npm, corepack, agent CLIs, system files"
}
