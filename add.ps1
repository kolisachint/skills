#!/usr/bin/env pwsh
# Add a new skill to catalog.tsv

param(
    [Parameter(Position=0)]
    [string]$Name = "",
    [string]$Category = "",
    [string]$Platforms = "all",
    [string]$AgentTarget = "all",
    [string]$Description = "",
    [string]$InstallCmd = "",
    [string]$RemoveCmd = "",
    [string]$Stars = "",
    [string]$DocsUrl = "",
    [string]$Github = "",
    [string]$Npm = "",
    [switch]$Help = $false
)

if ($Help) {
    @"
Usage: add.ps1 [options] <name>

Add a new skill to the catalog.

Options:
  -Category CAT         Category: skill, prompt, command, tool, agent, workflow
  -Platforms PLATFORMS  Comma-separated platforms (default: all)
  -AgentTarget TARGET   Agent target (default: all)
  -Description DESC     Short description
  -InstallCmd CMD       Install command
  -RemoveCmd CMD        Remove command
  -Stars STARS          Star count (e.g., 90K, 5K)
  -DocsUrl URL          Documentation URL
  -Github OWNER/REPO    GitHub repo (auto-generates fields)
  -Npm PACKAGE          npm package (auto-generates fields)
  -Help                 Show this help

Examples:
  .\add.ps1 my-skill -Category skill -Description "My skill" -Github owner/repo
  .\add.ps1 my-tool -Category tool -Npm my-package -Stars 1K
  .\add.ps1 my-skill -Category skill -Platforms "claude,pi" -Description "Custom"

  # Via Invoke-Expression:
  irm https://raw.githubusercontent.com/kolisachint/skills/main/add.ps1 | iex -name my-skill -github owner/repo
"@
    exit 0
}

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = "." }
$Catalog = Join-Path $ScriptDir "catalog.tsv"

# Fallback to ~/github/skills if catalog not found in script directory
$githubSkillsPath = Join-Path $env:USERPROFILE "github/skills/catalog.tsv"
if (-not (Test-Path $Catalog) -and (Test-Path $githubSkillsPath)) {
    $Catalog = $githubSkillsPath
}

# Validate name
if (-not $Name) {
    Write-Error "Skill name is required"
    exit 1
}

# Check if exists
if (Test-Path $Catalog) {
    $exists = Get-Content $Catalog | Where-Object { $_ -match "^$Name`t" }
    if ($exists) {
        Write-Error "Skill '$Name' already exists in catalog"
        exit 1
    }
}

# Auto-generate from GitHub
if ($Github) {
    if ($Github -notmatch '/') {
        Write-Error "GitHub repo must be owner/repo format"
        exit 1
    }
    if (-not $InstallCmd) { $InstallCmd = "npx skills add $Github --yes" }
    if (-not $RemoveCmd) { $RemoveCmd = "npx skills remove $Name --yes" }
    if (-not $DocsUrl) { $DocsUrl = "https://github.com/$Github" }
    if (-not $Stars) { $Stars = "-" }
}

# Auto-generate from npm
if ($Npm) {
    if (-not $InstallCmd) { $InstallCmd = "npm install -g $Npm" }
    if (-not $RemoveCmd) { $RemoveCmd = "npm uninstall -g $Npm" }
    if (-not $DocsUrl) { $DocsUrl = "https://www.npmjs.com/package/$Npm" }
    if (-not $Stars) { $Stars = "-" }
}

# Interactive prompts for missing fields
if ($host.Name -eq 'ConsoleHost') {
    Write-Host "Adding skill to catalog: $Name"
    Write-Host ""
    
    if (-not $Category) {
        $Category = Read-Host "Category [skill]"
        if (-not $Category) { $Category = "skill" }
    }
    if (-not $Description) {
        $Description = Read-Host "Description"
    }
    if (-not $InstallCmd) {
        $InstallCmd = Read-Host "Install command"
    }
    if (-not $RemoveCmd) {
        $defaultRemove = "npx skills remove $Name --yes"
        $RemoveCmd = Read-Host "Remove command [$defaultRemove]"
        if (-not $RemoveCmd) { $RemoveCmd = $defaultRemove }
    }
    if (-not $DocsUrl) {
        $DocsUrl = Read-Host "Docs URL"
    }
    if (-not $Stars) {
        $Stars = Read-Host "Stars [-]"
        if (-not $Stars) { $Stars = "-" }
    }
}

# Validate required
if (-not $Category) {
    Write-Error "-Category is required"
    exit 1
}
if (-not $Description) {
    Write-Error "-Description is required"
    exit 1
}
if (-not $InstallCmd) {
    Write-Error "-InstallCmd is required (or use -Github or -Npm)"
    exit 1
}

# Defaults
if (-not $RemoveCmd) { $RemoveCmd = "npx skills remove $Name --yes" }
if (-not $Stars) { $Stars = "-" }
if (-not $DocsUrl) { $DocsUrl = "-" }

# Build entry (tab-separated)
$entry = "$Name`t$Category`texternal`t$Platforms`t$AgentTarget`t$Description`t$InstallCmd`t$Stars`t$RemoveCmd`t$DocsUrl"

# Preview
Write-Host ""
Write-Host "=== Preview ==="
Write-Host "Name:         $Name"
Write-Host "Category:     $Category"
Write-Host "Platforms:    $Platforms"
Write-Host "Description:  $Description"
Write-Host "Install:      $InstallCmd"
Write-Host "Remove:       $RemoveCmd"
Write-Host "Stars:        $Stars"
Write-Host "Docs:         $DocsUrl"
Write-Host ""

# Confirm
if ($host.Name -eq 'ConsoleHost') {
    $confirm = Read-Host "Add to catalog? [y/N]"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Cancelled"
        exit 0
    }
}

# Add to catalog
if (Test-Path $Catalog) {
    Add-Content -Path $Catalog -Value $entry
} else {
    # Create with header
    $header = "name`tcategory`tsource`tplatforms`tagent_target`tdescription`tinstall_command`tstars`tremove_command`tdocs_url"
    Set-Content -Path $Catalog -Value $header
    Add-Content -Path $Catalog -Value $entry
}

Write-Host ""
Write-Host "✓ Added '$Name' to catalog"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review: Get-Content catalog.tsv | Select-String $Name"
Write-Host "  2. Commit: git add catalog.tsv; git commit -m `"Add $Name to catalog`""
Write-Host "  3. Push:   git push origin"
