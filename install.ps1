#!/usr/bin/env pwsh
# Install skills from catalog or directly from GitHub repos

param(
    [string]$Target = ".",
    [string]$Platform = "",
    [string]$Category = "",
    [string]$Skill = "",
    [string]$From = "",
    [string]$Tag = "",
    [switch]$Direct = $false,
    [switch]$Help = $false
)

if ($Help) {
    @"
Usage: install.ps1 [options] [<skill-name> | <github-repo>]

Install skills from catalog or directly from GitHub repositories.

Options:
  -Target PATH          Install to specific directory (default: .)
  -Platform PLATFORM    Target platform: opencode, pi, copilot, codex, claude
  -Category CATEGORY    Install by category from catalog
  -Skill NAME           Install specific skill(s), comma-separated
  -From FILE            Install from favorites file
  -Tag TAG              Filter favorites by tag
  -Direct               Treat argument as GitHub repo (owner/repo)
  -Help                 Show this help

Examples:
  .\install.ps1 caveman                    # Install from catalog
  .\install.ps1 -Platform pi caveman       # Install for Pi
  .\install.ps1 -Direct owner/repo         # Install from GitHub directly
  .\install.ps1 -Platform copilot -Direct owner/repo  # Direct to Copilot
  .\install.ps1 -Category workflow         # Install all workflow skills

  # Via Invoke-Expression:
  irm https://raw.githubusercontent.com/kolisachint/skills/main/install.ps1 | iex -skill caveman
"@
    exit 0
}

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = "." }
$Catalog = Join-Path $ScriptDir "catalog.tsv"

# Get positional arguments
$Repo = $args[0]

function Transform-CommandForPlatform {
    param([string]$Command, [string]$Platform)
    
    if (-not $Platform) { return $Command }
    
    switch ($Platform) {
        "opencode" {
            if ($Command -match '^npx\s+skills\s+add') {
                if ($Command -notmatch '-a\s+opencode') { $Command += " -a opencode" }
                if ($Command -notmatch '-g') { $Command += " -g" }
                if ($Command -notmatch '-y' -and $Command -notmatch '--yes') { $Command += " -y" }
            }
            # Special case: plannotator on OpenCode - config + install CLI
            if ($Command -match 'plannotator\.ai/install\.sh') {
                return "# Add to opencode.json: { `"plugin`": [`"@plannotator/opencode@latest`"] }; then: (curl -fsSL https://plannotator.ai/install.sh | bash) && $env:USERPROFILE/.local/bin/plannotator --version"
            }
        }
        "pi" {
            if ($Command -match '^npm\s+install\s+(.+)$') {
                $pkg = $matches[1].Trim()
                if ($pkg -match 'pi-extension') { return "pi install npm:$pkg" }
            }
            if ($Command -match '^npx\s+skills\s+add\s+([^\s]+)') {
                $repo = $matches[1].Trim()
                if ($repo -match '/') { return "pi install https://github.com/$repo" }
            }
            # Special case: plannotator on Pi - install CLI then pi-extension
            if ($Command -match 'plannotator\.ai/install\.sh') {
                return "(curl -fsSL https://plannotator.ai/install.sh | bash) && $env:USERPROFILE/.local/bin/plannotator --version && pi install npm:@plannotator/pi-extension"
            }
        }
        "codex" {
            if ($Command -match '^npx\s+skills\s+add\s+([^\s]+)') {
                $repo = $matches[1].Trim()
                $skillName = $repo -replace '.*/', ''
                return "codex skills add $skillName"
            }
            # Special case: plannotator on Codex - install CLI then restart
            if ($Command -match 'plannotator\.ai/install\.sh') {
                return "(curl -fsSL https://plannotator.ai/install.sh | bash) && $env:USERPROFILE/.local/bin/plannotator --version # Then restart Codex Desktop"
            }
        }
        "copilot" {
            if ($Command -match '^npx\s+skills\s+add\s+([^\s]+)') {
                $repo = $matches[1].Trim()
                if (Get-Command copilot -ErrorAction SilentlyContinue) {
                    return "copilot -- plugin install $repo"
                } else {
                    return "gh copilot -- plugin install $repo"
                }
            }
            # Special case: plannotator on Copilot - install CLI then plugin
            if ($Command -match 'plannotator\.ai/install\.sh') {
                return "(curl -fsSL https://plannotator.ai/install.sh | bash) && $env:USERPROFILE/.local/bin/plannotator --version && copilot -- plugin marketplace add backnotprop/plannotator && copilot -- plugin install plannotator-copilot@plannotator"
            }
        }
        "claude" {
            # Special case: plannotator on Claude - install CLI then plugin
            if ($Command -match 'plannotator\.ai/install\.sh') {
                return "(curl -fsSL https://plannotator.ai/install.sh | bash) && $env:USERPROFILE/.local/bin/plannotator --version # Then in Claude: /plugin marketplace add backnotprop/plannotator"
            }
        }
    }
    return $Command
}

# Resolve target
New-Item -ItemType Directory -Path $Target -Force | Out-Null
$Target = (Resolve-Path $Target).Path

# Direct GitHub repo installation
if ($Direct -and $Repo) {
    if ($Repo -notmatch '/') {
        Write-Error "Direct install requires owner/repo format"
        exit 1
    }
    
    Write-Host "Installing $Repo to $Target"
    
    if ($Platform) {
        $cmd = Transform-CommandForPlatform -Command "npx skills add $Repo --yes" -Platform $Platform
    } else {
        $cmd = "npx skills add $Repo --yes"
    }
    
    Write-Host "  → $Repo"
    Write-Host "    $cmd"
    
    try {
        $origDir = Get-Location
        Set-Location $Target
        Invoke-Expression $cmd
        Set-Location $origDir
        Write-Host "  ✓ $Repo installed"
        Write-Host ""
        Write-Host "✓ Installation complete"
        switch ($Platform) {
            "opencode" { Write-Host "  Skills installed to .opencode/skills/" }
            "pi"       { Write-Host "  Skills installed to .pi/skills/" }
            "codex"    { Write-Host "  Skills installed to .codex/skills/" }
            "copilot"  { Write-Host "  Skills installed via gh copilot -- plugin install" }
            "claude"   { Write-Host "  Skills installed to .claude/skills/" }
            default    { Write-Host "  npx skills manages .agents/skills/ automatically" }
        }
    } catch {
        Set-Location $origDir
        Write-Error "Installation failed: $_"
        exit 1
    }
    exit 0
}

# Catalog-based installation
if (-not (Test-Path $Catalog)) {
    Write-Host "Note: catalog.tsv not found locally. Using -Direct mode for GitHub repos." -ForegroundColor Yellow
    Write-Host "Clone the repo to use catalog-based installation." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: install.ps1 -Direct owner/repo"
    exit 1
}

Write-Host "Installing to $Target"

# Read and filter catalog
$components = Get-Content $Catalog | Select-Object -Skip 1 | ForEach-Object {
    $fields = $_ -split "`t"
    if ($fields.Length -ge 7) {
        [PSCustomObject]@{
            Name = $fields[0]
            Category = $fields[1]
            Platforms = $fields[3]
            Description = $fields[5]
            InstallCommand = $fields[6]
        }
    }
}

# Apply filters
if ($Category) {
    $components = $components | Where-Object { $_.Category -eq $Category }
}
if ($Platform) {
    $components = $components | Where-Object { $_.Platforms -eq "all" -or $_.Platforms -match $Platform }
}
if ($Skill) {
    $skillNames = $Skill -split ","
    $components = $components | Where-Object { $_.Name -in $skillNames }
}
if ($Repo) {
    $components = $components | Where-Object { $_.Name -eq $Repo }
}

if (-not $components) {
    Write-Host "No components found matching criteria"
    exit 0
}

Write-Host "  Components to install: $($components.Count)"
Write-Host ""

foreach ($comp in $components) {
    if (-not $comp.InstallCommand -or $comp.InstallCommand -eq "-") { continue }
    
    $cmd = Transform-CommandForPlatform -Command $comp.InstallCommand -Platform $Platform
    
    if ($cmd -match '^UNSUPPORTED:') {
        Write-Host "  → $($comp.Name)"
        Write-Warning $cmd.Substring(12)
        continue
    }
    
    Write-Host "  → $($comp.Name) ($($comp.Description))"
    Write-Host "    $cmd"
    
    try {
        $origDir = Get-Location
        Set-Location $Target
        Invoke-Expression $cmd | Out-Null
        Set-Location $origDir
        Write-Host "  ✓ $($comp.Name) installed"
        Write-Host ""
    } catch {
        Set-Location $origDir
        Write-Warning "  ⚠ $($comp.Name) installation failed (non-fatal)"
        Write-Host ""
    }
}

Write-Host "✓ Installation complete"
switch ($Platform) {
    "opencode" { Write-Host "  Skills installed to .opencode/skills/" }
    "pi"       { Write-Host "  Skills installed to .pi/skills/" }
    "codex"    { Write-Host "  Skills installed to .codex/skills/" }
    "copilot"  { Write-Host "  Skills installed via gh copilot -- plugin install" }
    "claude"   { Write-Host "  Skills installed to .claude/skills/" }
    default    { Write-Host "  npx skills manages .agents/skills/ and platform symlinks automatically" }
}
