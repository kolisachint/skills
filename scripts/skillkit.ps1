$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Catalog = Join-Path $Root "catalog.tsv"
$MarkBegin = "<!-- BEGIN AI SKILLKIT -->"
$MarkEnd = "<!-- END AI SKILLKIT -->"

function Show-Usage {
  @"
Portable AI Skillkit

Commands:
  .\scripts\skillkit.ps1 list                          Show all components grouped by category & source
  .\scripts\skillkit.ps1 list-categories               Show available categories
  .\scripts\skillkit.ps1 list-platforms                Show available platforms
  .\scripts\skillkit.ps1 search KEYWORD                Search components by name/description
  .\scripts\skillkit.ps1 top [N]                       Show top-N starred external components
  .\scripts\skillkit.ps1 install --target PATH         Install all components (internal + external)
  .\scripts\skillkit.ps1 install --target PATH --source internal       Install only internal components
  .\scripts\skillkit.ps1 install --target PATH --source external       Install only external components
  .\scripts\skillkit.ps1 install --target PATH --category workflow     Install only workflow components
  .\scripts\skillkit.ps1 install --target PATH --platform pi           Install only Pi-compatible components
  .\scripts\skillkit.ps1 install --target PATH --agent-target codex    Install only Codex-targeted agents/workflows
  .\scripts\skillkit.ps1 export --output PATH          Export portable bundle

Dimensions:
  Source:    internal, external
  Category:  skill, prompt, command, tool, agent, workflow
  Platform:  opencode, pi, copilot, codex, claude
  Agent:     all, pi, copilot, codex, claude, opencode, or specific name

Examples:
  .\scripts\skillkit.ps1 list
  .\scripts\skillkit.ps1 install --target C:\code\repo
  .\scripts\skillkit.ps1 install --target C:\code\repo --source internal --category workflow
  .\scripts\skillkit.ps1 install --target C:\code\repo --platform copilot --agent-target copilot
  .\scripts\skillkit.ps1 search review
  .\scripts\skillkit.ps1 top 5
"@
}

# ---------------------------------------------------------------------------
# Catalog parsing
# ---------------------------------------------------------------------------

function Read-Catalog {
  $lines = Get-Content -Path $Catalog | Where-Object { $_ -notmatch '^#' -and $_ -notmatch '^name\t' }
  $lines | ForEach-Object {
    $fields = $_ -split "`t"
    if ($fields.Length -ge 6) {
      [PSCustomObject]@{
        Name = $fields[0]
        Category = $fields[1]
        Source = $fields[2]
        Platforms = $fields[3]
        AgentTarget = $fields[4]
        Description = $fields[5]
        InstallCommand = if ($fields.Length -ge 7) { $fields[6] } else { "" }
        Stars = if ($fields.Length -ge 8) { $fields[7] } else { "" }
      }
    }
  }
}

function Filter-Catalog {
  param(
    [string]$SourceFilter = "",
    [string]$CategoryFilter = "",
    [string]$PlatformFilter = "",
    [string]$AgentTargetFilter = ""
  )

  $result = Read-Catalog
  if ($SourceFilter) { $result = $result | Where-Object { $_.Source -eq $SourceFilter } }
  if ($CategoryFilter) { $result = $result | Where-Object { $_.Category -eq $CategoryFilter } }
  if ($PlatformFilter) {
    $result = $result | Where-Object {
      $_.Platforms -eq "all" -or $_.Platforms -eq $PlatformFilter -or $_.Platforms -match "(^|,)$PlatformFilter($|,)"
    }
  }
  if ($AgentTargetFilter) { $result = $result | Where-Object { $_.AgentTarget -eq "all" -or $_.AgentTarget -eq $AgentTargetFilter } }
  return $result
}

# ---------------------------------------------------------------------------
# List commands
# ---------------------------------------------------------------------------

function Cmd-List {
  Write-Host ""
  Write-Host "📦 Portable AI Skillkit - Curated Components"
  Write-Host ""

  $categories = Read-Catalog | Select-Object -ExpandProperty Category -Unique | Sort-Object
  foreach ($category in $categories) {
    $components = Read-Catalog | Where-Object { $_.Category -eq $category }

    switch ($category) {
      "skill"    { Write-Host "🧠 Skills" }
      "prompt"   { Write-Host "💬 Prompts" }
      "command"  { Write-Host "🎯 Commands" }
      "tool"     { Write-Host "🔧 Tools" }
      "agent"    { Write-Host "🤖 Agents" }
      "workflow" { Write-Host "⚡ Workflows" }
      default    { Write-Host $category }
    }

    foreach ($comp in ($components | Sort-Object Name)) {
      $tags = ""
      if ($comp.Source -eq "internal") { $tags += " [internal]" }
      elseif ($comp.Source -eq "external") { $tags += " [external]" }
      if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
      if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }
      if ($comp.Stars -and $comp.Stars -ne "-") { $tags += " ($($comp.Stars)★)" }

      Write-Host ("  {0,-20} {1}{2}" -f $comp.Name, $comp.Description, $tags)
    }
    Write-Host ""
  }

  Write-Host "Install everything:    .\scripts\skillkit.ps1 install --target C:\code\repo"
  Write-Host "Install by category:   .\scripts\skillkit.ps1 install --target C:\code\repo --category workflow"
  Write-Host "Install by source:     .\scripts\skillkit.ps1 install --target C:\code\repo --source internal"
  Write-Host "Install by platform:   .\scripts\skillkit.ps1 install --target C:\code\repo --platform pi"
  Write-Host "Install by agent:      .\scripts\skillkit.ps1 install --target C:\code\repo --agent-target codex"
  Write-Host ""
}

function Cmd-ListCategories {
  Write-Host ""
  Write-Host "Available Categories:"
  Write-Host ""

  $categories = Read-Catalog | Select-Object -ExpandProperty Category -Unique | Sort-Object
  foreach ($category in $categories) {
    $count = (Read-Catalog | Where-Object { $_.Category -eq $category }).Count
    switch ($category) {
      "skill"    { $icon = "🧠" }
      "prompt"   { $icon = "💬" }
      "command"  { $icon = "🎯" }
      "tool"     { $icon = "🔧" }
      "agent"    { $icon = "🤖" }
      "workflow" { $icon = "⚡" }
      default    { $icon = "  " }
    }
    Write-Host ("  {0} {1,-12} ({2} components)" -f $icon, $category, $count)
  }
  Write-Host ""
}

function Cmd-ListPlatforms {
  Write-Host ""
  Write-Host "Supported Platforms:"
  Write-Host ""
  Write-Host "  🌐 all      - Platform-agnostic (works everywhere)"
  Write-Host "  🔷 opencode - OpenCode IDE/agent"
  Write-Host "  🥧 pi       - Pi Coding Agent"
  Write-Host "  🐙 copilot  - GitHub Copilot"
  Write-Host "  🟢 codex    - OpenAI Codex"
  Write-Host "  🟣 claude   - Claude Code"
  Write-Host ""

  Write-Host "Platform-specific components:"
  Write-Host ""
  $platforms = Read-Catalog | Select-Object -ExpandProperty Platforms -Unique | Sort-Object | Where-Object { $_ -ne "all" }
  foreach ($plat in $platforms) {
    $count = (Read-Catalog | Where-Object { $_.Platforms -eq $plat -or $_.Platforms -match "(^|,)$plat($|,)" }).Count
    Write-Host ("  {0,-10} ({1} components)" -f $plat, $count)
  }
  Write-Host ""
}

# ---------------------------------------------------------------------------
# Search commands
# ---------------------------------------------------------------------------

function Cmd-Search {
  param([string]$Query = "")

  if (-not $Query) {
    Write-Error "search requires a KEYWORD"
    Show-Usage
    exit 1
  }

  Write-Host ""
  Write-Host "🔍 Search results for: $Query"
  Write-Host ""

  $lq = $Query.ToLower()
  $results = Read-Catalog | Where-Object {
    $_.Name.ToLower() -match $lq -or
    $_.Description.ToLower() -match $lq -or
    $_.Category.ToLower() -match $lq -or
    $_.AgentTarget.ToLower() -match $lq
  }

  if ($results.Count -eq 0) {
    Write-Host 'No components match "$Query".'
    Write-Host ""
    Write-Host "Try:"
    Write-Host "  .\scripts\skillkit.ps1 list           to see all components"
    Write-Host "  .\scripts\skillkit.ps1 top 5          to see top starred skills"
    Write-Host ""
    return
  }

  Write-Host "Found $($results.Count) result(s):"
  Write-Host ""

  foreach ($comp in ($results | Sort-Object Category, Name)) {
    $icon = switch ($comp.Category) {
      "skill"    { "🧠" }
      "prompt"   { "💬" }
      "command"  { "🎯" }
      "tool"     { "🔧" }
      "agent"    { "🤖" }
      "workflow" { "⚡" }
      default    { "  " }
    }

    $tags = ""
    if ($comp.Source -eq "internal") { $tags += " [internal]" }
    elseif ($comp.Source -eq "external") { $tags += " [external]" }
    if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
    if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }
    if ($comp.Stars -and $comp.Stars -ne "-") { $tags += " ($($comp.Stars)★)" }

    Write-Host ("  {0} {1,-20} {2}{3}" -f $icon, $comp.Name, $comp.Description, $tags)
  }

  Write-Host ""
  Write-Host "Install a result:"
  Write-Host "  .\scripts\skillkit.ps1 install --target C:\code\repo --agent-target <name>"
  Write-Host "  .\scripts\skillkit.ps1 install --target C:\code\repo --category <category>"
  Write-Host ""
}

function Cmd-Top {
  param([string]$N = "10")

  if ($N -notmatch '^\d+$') { $N = 10 }
  $N = [int]$N

  Write-Host ""
  Write-Host "⭐ Top $N Starred External Components"
  Write-Host ""

  $results = Read-Catalog | Where-Object {
    $_.Source -eq "external" -and $_.Stars -and $_.Stars -ne "-"
  } | ForEach-Object {
    $starsRaw = $_.Stars -replace '[K+]', ''
    $starsNum = [int]$starsRaw
    if ($_.Stars -match 'K') { $starsNum = $starsNum * 1000 }
    [PSCustomObject]@{
      Component = $_
      StarsNum = $starsNum
    }
  } | Sort-Object StarsNum -Descending | Select-Object -First $N

  if ($results.Count -eq 0) {
    Write-Host "No starred external components found."
    Write-Host ""
    return
  }

  $rank = 1
  foreach ($item in $results) {
    $comp = $item.Component
    $icon = switch ($comp.Category) {
      "skill"    { "🧠" }
      "prompt"   { "💬" }
      "command"  { "🎯" }
      "tool"     { "🔧" }
      "agent"    { "🤖" }
      "workflow" { "⚡" }
      default    { "  " }
    }

    $tags = ""
    if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
    if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }

    Write-Host ("  {0,2}. {1} {2,-20} {3}{4} ({5}★)" -f $rank, $icon, $comp.Name, $comp.Description, $tags, $comp.Stars)
    $rank++
  }

  Write-Host ""
  Write-Host "Install one:"
  Write-Host "  .\scripts\skillkit.ps1 install --target C:\code\repo --agent-target <name>"
  Write-Host ""
}

# ---------------------------------------------------------------------------
# Platform detection & paths
# ---------------------------------------------------------------------------

function Detect-Platforms {
  param([string]$Target)

  $detected = @()
  if ((Test-Path (Join-Path $Target ".pi")) -or (Test-Path (Join-Path $Target "AGENTS.md"))) { $detected += "pi" }
  if (Test-Path (Join-Path $Target ".opencode")) { $detected += "opencode" }
  if ((Test-Path (Join-Path $Target ".github/copilot-skills")) -or (Test-Path (Join-Path $Target ".github/copilot-instructions.md"))) { $detected += "copilot" }
  if (Test-Path (Join-Path $Target ".codex")) { $detected += "codex" }
  if (Test-Path (Join-Path $Target ".claude")) { $detected += "claude" }

  return $detected
}

function Get-PlatformSkillDir {
  param([string]$Platform, [string]$Target)
  switch ($Platform) {
    "pi"       { return Join-Path $Target ".pi/skills" }
    "opencode" { return Join-Path $Target ".opencode/skills" }
    "copilot"  { return Join-Path $Target ".github/copilot-skills" }
    "codex"    { return Join-Path $Target ".codex/skills" }
    "claude"   { return Join-Path $Target ".claude/skills" }
    default    { return Join-Path $Target ".ai/skillkit/skills" }
  }
}

function Get-PlatformAgentDir {
  param([string]$Platform, [string]$Target)
  switch ($Platform) {
    "pi"       { return Join-Path $Target ".pi/agents" }
    "opencode" { return Join-Path $Target ".opencode/agents" }
    "copilot"  { return Join-Path $Target ".github/copilot-agents" }
    "codex"    { return Join-Path $Target ".codex/agents" }
    "claude"   { return Join-Path $Target ".claude/agents" }
    default    { return $null }
  }
}

function Get-SourceFileName {
  param([string]$Category)
  switch ($Category) {
    "prompt"  { return "PROMPT.md" }
    "command" { return "COMMAND.md" }
    default   { return "SKILL.md" }
  }
}

# ---------------------------------------------------------------------------
# Install helpers
# ---------------------------------------------------------------------------

function Install-Internal {
  param(
    [string]$Target,
    [PSCustomObject]$Component,
    [string[]]$ActivePlatforms
  )

  $srcFile = Join-Path $Root "skills/$($Component.Name)/$(Get-SourceFileName $Component.Category)"

  if (-not (Test-Path $srcFile)) {
    Write-Host "  ⚠ $($Component.Name): source file not found ($srcFile)" -ForegroundColor Yellow
    return
  }

  # Shared neutral directory
  $sharedDir = Join-Path $Target ".ai/skillkit/$($Component.Category)s"
  New-Item -ItemType Directory -Path $sharedDir -Force | Out-Null
  Copy-Item -Path $srcFile -Destination (Join-Path $sharedDir "$($Component.Name).md") -Force

  # Platform-specific directories
  foreach ($plat in $ActivePlatforms) {
    $platDir = Get-PlatformSkillDir -Platform $plat -Target $Target
    if ($platDir) {
      New-Item -ItemType Directory -Path $platDir -Force | Out-Null
      Copy-Item -Path $srcFile -Destination (Join-Path $platDir "$($Component.Name).md") -Force
    }

    # Agent configs
    if ($Component.Category -eq "agent" -or $Component.Category -eq "workflow") {
      $agentDir = Get-PlatformAgentDir -Platform $plat -Target $Target
      if ($agentDir) {
        $configFiles = Get-ChildItem -Path (Join-Path $Root "skills/$($Component.Name)") -Filter "agent.*" -ErrorAction SilentlyContinue
        foreach ($configFile in $configFiles) {
          New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
          $ext = $configFile.Extension.TrimStart('.')
          Copy-Item -Path $configFile.FullName -Destination (Join-Path $agentDir "$($Component.Name).$ext") -Force
        }
      }
    }
  }

  Write-Host "  ✓ $($Component.Name) - $($Component.Description)"
}

function Install-External {
  param([PSCustomObject]$Component)

  if (-not $Component.InstallCommand -or $Component.InstallCommand -eq "-") {
    Write-Host "  ⚠ $($Component.Name): no install command" -ForegroundColor Yellow
    return
  }

  Write-Host "  → $($Component.Name) ($($Component.Description))"
  Write-Host "    Running: $($Component.InstallCommand)"
  try {
    Invoke-Expression $Component.InstallCommand
    Write-Host "  ✓ $($Component.Name) installed"
  }
  catch {
    Write-Warning "  ⚠ $($Component.Name) installation failed (non-fatal): $_"
  }
}

# ---------------------------------------------------------------------------
# Index / manifest generation
# ---------------------------------------------------------------------------

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
        "skill"    { $lines += "### 🧠 Skills" }
        "prompt"   { $lines += "### 💬 Prompts" }
        "command"  { $lines += "### 🎯 Commands" }
        "tool"     { $lines += "### 🔧 Tools" }
        "agent"    { $lines += "### 🤖 Agents" }
        "workflow" { $lines += "### ⚡ Workflows" }
        default    { $lines += "### $($comp.Category)" }
      }
      $prevCat = $comp.Category
    }

    $tags = ""
    if ($comp.Source -eq "external") { $tags += " [external]" }
    if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
    if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }

    $lines += "- ``$($comp.Name)``$tags: $($comp.Description)"
  }

  $lines += ""
  $lines += "## Usage"
  $lines += ""
  $lines += "Components are organized by category and source."
  $lines += "For normal coding work, default to workflow components when available."
  $lines += "Platform-specific components are installed to their respective directories."

  $lines | Out-File -FilePath $index -Encoding utf8
}

function Update-AgentsMd {
  param(
    [string]$Target,
    [array]$Components
  )

  $agentsFile = Join-Path $Target "AGENTS.md"
  if (-not (Test-Path $agentsFile)) { return }

  $content = Get-Content -Path $agentsFile -Raw
  if ($content -notmatch [regex]::Escape($MarkBegin)) { return }

  $block = "$MarkBegin`r`n`r`n"
  $block += "# AI Skillkit (auto-installed)`r`n`r`n"
  $block += "The following components are managed by Portable AI Skillkit.`r`n"
  $block += "Do not edit this block manually; it will be regenerated on install.`r`n`r`n"

  $prevCat = ""
  foreach ($comp in ($Components | Sort-Object Category, Name)) {
    if ($comp.Category -ne $prevCat) {
      switch ($comp.Category) {
        "skill"    { $block += "### Skills`r`n" }
        "prompt"   { $block += "### Prompts`r`n" }
        "command"  { $block += "### Commands`r`n" }
        "tool"     { $block += "### Tools`r`n" }
        "agent"    { $block += "### Agents`r`n" }
        "workflow" { $block += "### Workflows`r`n" }
        default    { $block += "### $($comp.Category)`r`n" }
      }
      $prevCat = $comp.Category
    }
    $block += "- ``$($comp.Name)``: $($comp.Description)`r`n"
  }

  $block += "`r`n$MarkEnd"

  $before = $content.Substring(0, $content.IndexOf($MarkBegin))
  $afterIdx = $content.IndexOf($MarkEnd) + $MarkEnd.Length
  $after = $content.Substring($afterIdx)

  ($before + $block + $after).Trim() | Out-File -FilePath $agentsFile -Encoding utf8
}

function Write-PlatformIndex {
  param(
    [string]$Target,
    [string]$Platform,
    [array]$Components
  )

  $indexPath = switch ($Platform) {
    "pi"       { Join-Path $Target ".pi/AGENTS.md" }
    "opencode" { Join-Path $Target ".opencode/AGENTS.md" }
    "copilot"  { Join-Path $Target ".github/copilot-instructions.md" }
    "codex"    { Join-Path $Target ".codex/AGENTS.md" }
    "claude"   { Join-Path $Target ".claude/AGENTS.md" }
    default    { $null }
  }

  if (-not $indexPath) { return }
  $indexDir = Split-Path -Parent $indexPath
  if (-not (Test-Path $indexDir)) { return }

  $platformLabel = $Platform.Substring(0,1).ToUpper() + $Platform.Substring(1)
  $lines = @()
  $lines += "# AI Skillkit - $platformLabel"
  $lines += ""
  $lines += "Platform-specific instructions installed from Portable AI Skillkit."
  $lines += ""
  $lines += "## Components"
  $lines += ""

  foreach ($comp in ($Components | Sort-Object Category, Name)) {
    $lines += "- ``$($comp.Name)`` ($($comp.Category)): $($comp.Description)"
  }

  $lines | Out-File -FilePath $indexPath -Encoding utf8
}

# ---------------------------------------------------------------------------
# Main install command
# ---------------------------------------------------------------------------

function Cmd-Install {
  param(
    [string]$Target = "",
    [string]$SourceFilter = "",
    [string]$CategoryFilter = "",
    [string]$PlatformFilter = "",
    [string]$AgentTargetFilter = ""
  )

  if (-not $Target) {
    Write-Error "--target is required"
    Show-Usage
    exit 1
  }

  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $Target = (Resolve-Path $Target).Path

  Write-Host "Installing Portable AI Skillkit to $Target"

  $activePlatforms = @()
  if ($PlatformFilter -and $PlatformFilter -ne "all") {
    $activePlatforms = @($PlatformFilter)
  } else {
    $activePlatforms = Detect-Platforms -Target $Target
  }

  if ($activePlatforms.Count -gt 0) {
    Write-Host "Target platforms: $($activePlatforms -join ' ')"
  } else {
    Write-Host "No platform directories detected. Installing to shared .ai/skillkit/ only."
    Write-Host "Use --platform <name> to force platform-specific installation."
  }

  $components = Filter-Catalog -SourceFilter $SourceFilter -CategoryFilter $CategoryFilter -PlatformFilter $PlatformFilter -AgentTargetFilter $AgentTargetFilter

  if ($components.Count -eq 0) {
    Write-Host "No components match the filter (source=$SourceFilter, category=$CategoryFilter, platform=$PlatformFilter, agent=$AgentTargetFilter)"
    return
  }

  $internalCount = ($components | Where-Object { $_.Source -eq "internal" }).Count
  $externalCount = ($components | Where-Object { $_.Source -eq "external" }).Count

  Write-Host "  Internal: $internalCount"
  Write-Host "  External: $externalCount"
  Write-Host ""

  if ($internalCount -gt 0) {
    Write-Host "→ Installing internal components..."
    foreach ($comp in ($components | Where-Object { $_.Source -eq "internal" } | Sort-Object Name)) {
      Install-Internal -Target $Target -Component $comp -ActivePlatforms $activePlatforms
    }
  }

  if ($externalCount -gt 0) {
    Write-Host ""
    Write-Host "→ Installing external components..."
    foreach ($comp in ($components | Where-Object { $_.Source -eq "external" } | Sort-Object Name)) {
      Install-External -Component $comp
    }
  }

  Write-SharedIndex -Target $Target -Components $components
  Update-AgentsMd -Target $Target -Components $components

  foreach ($plat in $activePlatforms) {
    Write-PlatformIndex -Target $Target -Platform $plat -Components $components
  }

  Write-Host ""
  Write-Host "✓ Installation complete"
  Write-Host "  Shared index:      $Target/.ai/skillkit/AGENTS.md"
  if ($activePlatforms.Count -gt 0) {
    Write-Host "  Platform dirs:     installed to detected platform directories"
  }
}

# ---------------------------------------------------------------------------
# Export command
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Main dispatcher
# ---------------------------------------------------------------------------

$command = $args[0]
$remaining = $args[1..$args.Length]

switch ($command) {
  "list" {
    Cmd-List
  }
  "list-categories" {
    Cmd-ListCategories
  }
  "list-platforms" {
    Cmd-ListPlatforms
  }
  "search" {
    $query = if ($remaining.Length -gt 0) { $remaining[0] } else { "" }
    Cmd-Search -Query $query
  }
  "top" {
    $n = if ($remaining.Length -gt 0) { $remaining[0] } else { "10" }
    Cmd-Top -N $n
  }
  "install" {
    $target = ""
    $sourceFilter = ""
    $categoryFilter = ""
    $platformFilter = ""
    $agentTargetFilter = ""

    for ($i = 0; $i -lt $remaining.Length; $i++) {
      switch ($remaining[$i]) {
        "--target"       { $target = $remaining[++$i] }
        "--source"       { $sourceFilter = $remaining[++$i] }
        "--category"     { $categoryFilter = $remaining[++$i] }
        "--platform"     { $platformFilter = $remaining[++$i] }
        "--agent-target" { $agentTargetFilter = $remaining[++$i] }
      }
    }

    Cmd-Install -Target $target -SourceFilter $sourceFilter -CategoryFilter $categoryFilter -PlatformFilter $platformFilter -AgentTargetFilter $agentTargetFilter
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
