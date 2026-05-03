$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Catalog = Join-Path $Root "catalog.tsv"
$MarkBegin = "<!-- BEGIN AI SKILLKIT -->"
$MarkEnd = "<!-- END AI SKILLKIT -->"

function Show-Usage {
  @"
Portable AI Skillkit

Commands:
  .\scripts\skillkit.ps1 list                          Show all components grouped by category
  .\scripts\skillkit.ps1 list-categories               Show available categories
  .\scripts\skillkit.ps1 install --target PATH         Install all components (bundled + external)
  .\scripts\skillkit.ps1 install --target PATH --source bundled     Install only bundled components
  .\scripts\skillkit.ps1 install --target PATH --source external    Install only external components
  .\scripts\skillkit.ps1 install --target PATH --category workflow  Install only workflow components
  .\scripts\skillkit.ps1 export --output PATH          Export portable bundle

Categories:
  workflow, command, tool, agent

Examples:
  .\scripts\skillkit.ps1 list
  .\scripts\skillkit.ps1 install --target C:\code\repo
  .\scripts\skillkit.ps1 install --target C:\code\repo --source bundled
  .\scripts\skillkit.ps1 install --target C:\code\repo --category workflow
  .\scripts\skillkit.ps1 export --output .\dist
"@
}

function Read-Catalog {
  $lines = Get-Content -Path $Catalog | Where-Object { $_ -notmatch '^#' -and $_ -notmatch '^name\t' }
  $lines | ForEach-Object {
    $fields = $_ -split "\t"
    if ($fields.Length -ge 4) {
      [PSCustomObject]@{
        Name = $fields[0]
        Category = $fields[1]
        Source = $fields[2]
        Description = $fields[3]
        InstallCommand = if ($fields.Length -ge 5) { $fields[4] } else { "" }
        Stars = if ($fields.Length -ge 6) { $fields[5] } else { "" }
      }
    }
  }
}

function Get-Categories {
  (Read-Catalog | Select-Object -ExpandProperty Category -Unique | Sort-Object)
}

function Cmd-List {
  Write-Host ""
  Write-Host "📦 Portable AI Skillkit - Curated Components"
  Write-Host ""

  foreach ($category in Get-Categories) {
    $components = Read-Catalog | Where-Object { $_.Category -eq $category }
    $count = $components.Count

    switch ($category) {
      "workflow" { Write-Host "⚡ Workflows (how you structure work)" }
      "command"  { Write-Host "🎯 Commands (interactive modes)" }
      "tool"     { Write-Host "🔧 Tools (monitoring & analysis)" }
      "agent"    { Write-Host "🤖 Agents (execution harnesses)" }
      default    { Write-Host $category }
    }

    foreach ($comp in ($components | Sort-Object Name)) {
      $source = ""
      if ($comp.Source -eq "bundled") { $source = " [bundled]" }
      elseif ($comp.Source -eq "external") { $source = " [external]" }

      $stars = ""
      if ($comp.Stars -and $comp.Stars -ne "-") { $stars = " ($($comp.Stars)★)" }

      Write-Host ("  {0,-20} {1}{2}{3}" -f $comp.Name, $comp.Description, $source, $stars)
    }
    Write-Host ""
  }

  Write-Host "Install everything: .\scripts\skillkit.ps1 install --target C:\code\repo"
  Write-Host "Install by category: .\scripts\skillkit.ps1 install --target C:\code\repo --category workflow"
  Write-Host "Install by source:   .\scripts\skillkit.ps1 install --target C:\code\repo --source bundled"
  Write-Host ""
}

function Cmd-ListCategories {
  Write-Host ""
  Write-Host "Available Categories:"
  Write-Host ""

  foreach ($category in Get-Categories) {
    $count = (Read-Catalog | Where-Object { $_.Category -eq $category }).Count
    Write-Host ("  {0,-12} ({1} components)" -f $category, $count)
  }
  Write-Host ""
}

function Filter-Catalog {
  param([string]$SourceFilter = "", [string]$CategoryFilter = "")

  $result = Read-Catalog
  if ($SourceFilter) { $result = $result | Where-Object { $_.Source -eq $SourceFilter } }
  if ($CategoryFilter) { $result = $result | Where-Object { $_.Category -eq $CategoryFilter } }
  return $result
}

function Cmd-Install {
  param(
    [string]$Target = "",
    [string]$SourceFilter = "",
    [string]$CategoryFilter = ""
  )

  if (-not $Target) {
    Write-Error "--target is required"
    Show-Usage
    exit 1
  }

  $Target = (Resolve-Path $Target).Path
  New-Item -ItemType Directory -Path $Target -Force | Out-Null

  Write-Host "Installing Portable AI Skillkit to $Target"

  $components = Filter-Catalog -SourceFilter $SourceFilter -CategoryFilter $CategoryFilter

  if ($components.Count -eq 0) {
    Write-Host "No components match the filter (source=$SourceFilter, category=$CategoryFilter)"
    return
  }

  $bundledCount = ($components | Where-Object { $_.Source -eq "bundled" }).Count
  $externalCount = ($components | Where-Object { $_.Source -eq "external" }).Count

  Write-Host "  Bundled: $bundledCount"
  Write-Host "  External: $externalCount"
  Write-Host ""

  if ($bundledCount -gt 0) {
    Write-Host "→ Installing bundled components..."
    foreach ($comp in ($components | Where-Object { $_.Source -eq "bundled" } | Sort-Object Name)) {
      $skillPath = Join-Path $Root "skills/$($comp.Name)/SKILL.md"
      if (Test-Path $skillPath) {
        $destDir = Join-Path $Target ".ai/skillkit/skills"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Copy-Item -Path $skillPath -Destination (Join-Path $destDir "$($comp.Name).md") -Force
        Write-Host "  ✓ $($comp.Name) - $($comp.Description)"
      }
    }
  }

  if ($externalCount -gt 0) {
    Write-Host ""
    Write-Host "→ Installing external components..."
    foreach ($comp in ($components | Where-Object { $_.Source -eq "external" } | Sort-Object Name)) {
      if ($comp.InstallCommand -and $comp.InstallCommand -ne "-") {
        Write-Host "  → $($comp.Name) ($($comp.Description))"
        Write-Host "    Running: $($comp.InstallCommand)"
        try {
          Invoke-Expression $comp.InstallCommand
          Write-Host "  ✓ $($comp.Name) installed"
        }
        catch {
          Write-Warning "  ⚠ $($comp.Name) installation failed (non-fatal): $_"
        }
      }
    }
  }

  Write-SharedIndex -Target $Target -Components $components

  Write-Host ""
  Write-Host "✓ Installation complete"
  Write-Host "  Skills installed in: $Target/.ai/skillkit/"
}

function Write-SharedIndex {
  param(
    [string]$Target,
    [array]$Components
  )

  $sharedDir = Join-Path $Target ".ai/skillkit"
  $index = Join-Path $sharedDir "AGENTS.md"
  New-Item -ItemType Directory -Path $sharedDir -Force | Out-Null

  $lines = @()
  $lines += "# AI Skillkit"
  $lines += ""
  $lines += "Shared instructions installed from Portable AI Skillkit."
  $lines += ""
  $lines += "## Active Components"
  $lines += ""

  $prevCat = ""
  foreach ($comp in ($Components | Sort-Object Category, Name)) {
    if ($comp.Category -ne $prevCat) {
      switch ($comp.Category) {
        "workflow" { $lines += "### ⚡ Workflows" }
        "command"  { $lines += "### 🎯 Commands" }
        "tool"     { $lines += "### 🔧 Tools" }
        "agent"    { $lines += "### 🤖 Agents" }
        default    { $lines += "### $($comp.Category)" }
      }
      $prevCat = $comp.Category
    }

    $srcTag = ""
    if ($comp.Source -eq "external") { $srcTag = " [external]" }
    $lines += "- ``$($comp.Name)``$srcTag: $($comp.Description)"
  }

  $lines += ""
  $lines += "## Usage"
  $lines += ""
  $lines += "Components are organized by category."
  $lines += "For normal coding work, default to workflow components when available."

  $lines | Out-File -FilePath $index -Encoding utf8
}

function Cmd-Export {
  param([string]$Output = "")

  if (-not $Output) {
    Write-Error "--output is required"
    Show-Usage
    exit 1
  }

  New-Item -ItemType Directory -Path $Output -Force | Out-Null
  $Output = (Resolve-Path $Output).Path

  Write-Host "Exporting Portable AI Skillkit to $Output"

  Copy-Item -Path $Catalog -Destination (Join-Path $Output "catalog.tsv") -Force

  $skillsDir = Join-Path $Root "skills"
  if (Test-Path $skillsDir) {
    Copy-Item -Path $skillsDir -Destination (Join-Path $Output "skills") -Recurse -Force
  }

  $scriptsDir = Join-Path $Output "scripts"
  New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
  Copy-Item -Path (Join-Path $Root "scripts/skillkit.sh") -Destination $scriptsDir -Force
  Copy-Item -Path (Join-Path $Root "scripts/skillkit.ps1") -Destination $scriptsDir -Force

  foreach ($doc in @("README.md", "AGENTS.md", "PHILOSOPHY.md", "MIGRATION.md")) {
    $docPath = Join-Path $Root $doc
    if (Test-Path $docPath) {
      Copy-Item -Path $docPath -Destination (Join-Path $Output $doc) -Force
    }
  }

  Write-Host "✓ Exported to $Output"
}

# Main command dispatcher
$command = $args[0]
$remaining = $args[1..$args.Length]

switch ($command) {
  "list" {
    Cmd-List
  }
  "list-categories" {
    Cmd-ListCategories
  }
  "install" {
    $target = ""
    $sourceFilter = ""
    $categoryFilter = ""

    for ($i = 0; $i -lt $remaining.Length; $i++) {
      switch ($remaining[$i]) {
        "--target" { $target = $remaining[++$i] }
        "--source" { $sourceFilter = $remaining[++$i] }
        "--category" { $categoryFilter = $remaining[++$i] }
      }
    }

    Cmd-Install -Target $target -SourceFilter $sourceFilter -CategoryFilter $categoryFilter
  }
  "export" {
    $output = ""
    for ($i = 0; $i -lt $remaining.Length; $i++) {
      if ($remaining[$i] -eq "--output") { $output = $remaining[++$i] }
    }
    Cmd-Export -Output $output
  }
  default {
    Show-Usage
    exit 1
  }
}
