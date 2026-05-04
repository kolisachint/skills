#!/usr/bin/env pwsh
# Verify installation of skills and tools

param(
    [Parameter(Position=0)]
    [string]$Skill = "",
    [string]$Cli = "",
    [string]$Platform = "",
    [switch]$All = $false,
    [switch]$Verbose = $false,
    [switch]$Help = $false
)

if ($Help) {
    @"
Usage: verify.ps1 [options] [<skill-name>]

Verify if skills/tools are properly installed.

Options:
  -Cli TOOL       Verify specific CLI tool (plannotator, codeburn, etc.)
  -Platform P     Verify platform-specific installation (pi, claude, copilot, etc.)
  -All            Verify all known skills
  -Verbose        Show detailed output
  -Help           Show this help

Examples:
  .\verify.ps1 plannotator           # Verify plannotator installation
  .\verify.ps1 -Cli plannotator      # Verify plannotator CLI
  .\verify.ps1 -Platform pi          # Verify Pi extensions
  .\verify.ps1 -All                  # Verify all skills

  # Via Invoke-Expression:
  irm https://raw.githubusercontent.com/kolisachint/skills/main/verify.ps1 | iex -skill plannotator
"@
    exit 0
}

function Check-Cli {
    param([string]$Tool, [bool]$Verbose)
    
    # Check in USERPROFILE\.local\bin first (where plannotator installs)
    $localBin = Join-Path $env:USERPROFILE ".local\bin\$Tool.exe"
    if (Test-Path $localBin) {
        if ($Verbose) {
            try {
                $version = & $localBin --version 2>$null
                if (-not $version) { $version = "unknown" }
            } catch {
                $version = "unknown"
            }
            Write-Host "✓ $Tool installed at $localBin ($version)" -ForegroundColor Green
        } else {
            Write-Host "✓ $Tool installed" -ForegroundColor Green
        }
        return $true
    }
    
    # Check in PATH
    $cmd = Get-Command $Tool -ErrorAction SilentlyContinue
    if ($cmd) {
        if ($Verbose) {
            try {
                $version = & $cmd.Source --version 2>$null
                if (-not $version) { $version = "unknown" }
            } catch {
                $version = "unknown"
            }
            Write-Host "✓ $Tool installed at $($cmd.Source) ($version)" -ForegroundColor Green
        } else {
            Write-Host "✓ $Tool installed" -ForegroundColor Green
        }
        return $true
    }
    
    Write-Host "✗ $Tool NOT installed" -ForegroundColor Red
    return $false
}

function Check-PiExtension {
    param([string]$Package)
    
    try {
        $list = pi list 2>$null
        if ($list -match $Package) {
            Write-Host "✓ Pi extension $Package installed" -ForegroundColor Green
            return $true
        }
    } catch {}
    
    Write-Host "✗ Pi extension $Package NOT installed" -ForegroundColor Red
    return $false
}

function Check-ClaudePlugin {
    param([string]$Plugin)
    
    $claudeSkills = Join-Path $env:USERPROFILE ".claude\skills\$Plugin"
    $claudeCmds = Join-Path $env:USERPROFILE ".claude\commands\$Plugin"
    
    if ((Test-Path $claudeSkills) -or (Test-Path $claudeCmds)) {
        Write-Host "✓ Claude plugin $Plugin installed" -ForegroundColor Green
        return $true
    }
    
    Write-Host "✗ Claude plugin $Plugin NOT installed" -ForegroundColor Red
    return $false
}

function Check-CopilotPlugin {
    param([string]$Plugin)
    
    $copilotDir = Join-Path $env:USERPROFILE ".github\copilot\skills\$Plugin"
    $ghCopilotDir = Join-Path $env:USERPROFILE ".local\share\gh\copilot\$Plugin"
    
    if ((Test-Path $copilotDir) -or (Test-Path $ghCopilotDir)) {
        Write-Host "✓ Copilot plugin $Plugin installed" -ForegroundColor Green
        return $true
    }
    
    Write-Host "✗ Copilot plugin $Plugin NOT installed" -ForegroundColor Red
    return $false
}

Write-Host "=== Skill Installation Verification ==="
Write-Host ""

# If -Cli specified
if ($Cli) {
    Check-Cli -Tool $Cli -Verbose $Verbose
    exit $LASTEXITCODE
}

# If specific skill provided
if ($Skill) {
    switch ($Skill) {
        "plannotator" {
            Write-Host "Checking plannotator..."
            $cliStatus = Check-Cli -Tool "plannotator" -Verbose $Verbose
            
            if ($Platform) {
                Write-Host ""
                Write-Host "Checking platform-specific installation ($Platform)..."
                switch ($Platform) {
                    "pi" { Check-PiExtension -Package "@plannotator/pi-extension" }
                    "claude" { Check-ClaudePlugin -Plugin "plannotator" }
                    "copilot" { Check-CopilotPlugin -Plugin "plannotator" }
                    default { Write-Host "⚠ Unknown platform: $Platform" -ForegroundColor Yellow }
                }
            } else {
                Write-Host ""
                Write-Host "Checking all platform installations..."
                Check-PiExtension -Package "@plannotator/pi-extension" | Out-Null
                Check-ClaudePlugin -Plugin "plannotator" | Out-Null
                Check-CopilotPlugin -Plugin "plannotator" | Out-Null
            }
            
            if ($cliStatus) {
                Write-Host ""
                Write-Host "✓ plannotator is ready to use" -ForegroundColor Green
                Write-Host "  CLI: $env:USERPROFILE\.local\bin\plannotator.exe"
                Write-Host "  Usage: plannotator --help"
            }
        }
        
        "codeburn" {
            Write-Host "Checking codeburn..."
            Check-Cli -Tool "codeburn" -Verbose $Verbose
        }
        
        "caveman" {
            Write-Host "Checking caveman..."
            $claudeDir = Join-Path $env:USERPROFILE ".claude\skills\caveman"
            if (Test-Path $claudeDir) {
                Write-Host "✓ caveman skill installed" -ForegroundColor Green
            } else {
                Write-Host "✗ caveman skill NOT installed" -ForegroundColor Red
            }
        }
        
        default {
            Write-Host "Checking $Skill..."
            $cli = Check-Cli -Tool $Skill -Verbose $Verbose
            if (-not $cli) {
                $plugin = Check-ClaudePlugin -Plugin $Skill
                if (-not $plugin) {
                    Write-Host "✗ $Skill not found" -ForegroundColor Red
                }
            }
        }
    }
    exit 0
}

# If -All
if ($All) {
    Write-Host "Checking all known skills..."
    Write-Host ""
    
    Write-Host "CLI Tools:"
    Check-Cli -Tool "plannotator" -Verbose $Verbose | Out-Null
    Check-Cli -Tool "codeburn" -Verbose $Verbose | Out-Null
    Check-Cli -Tool "claude" -Verbose $Verbose | Out-Null
    Check-Cli -Tool "codex" -Verbose $Verbose | Out-Null
    Check-Cli -Tool "pi" -Verbose $Verbose | Out-Null
    
    Write-Host ""
    Write-Host "Agent CLI Tools:"
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($gh) {
        Write-Host "✓ gh CLI installed" -ForegroundColor Green
        try {
            gh copilot --help 2>$null | Out-Null
            Write-Host "✓ gh copilot extension installed" -ForegroundColor Green
        } catch {}
    }
    
    Write-Host ""
    Write-Host "Platform Directories:"
    $paths = @(
        @{ Path = "$env:USERPROFILE\.claude\skills"; Name = "Claude skills" }
        @{ Path = "$env:USERPROFILE\.pi\skills"; Name = "Pi skills" }
        @{ Path = "$env:USERPROFILE\.codex\skills"; Name = "Codex skills" }
        @{ Path = "$env:USERPROFILE\.opencode\skills"; Name = "OpenCode skills" }
    )
    foreach ($p in $paths) {
        if (Test-Path $p.Path) {
            Write-Host "✓ $($p.Name) directory" -ForegroundColor Green
        } else {
            Write-Host "⚠ $($p.Name) directory missing" -ForegroundColor Yellow
        }
    }
    
    exit 0
}

# No arguments
Write-Host "Usage: verify.ps1 [options] [<skill-name>]"
Write-Host "Use -Help for more information"
exit 1
