$ErrorActionPreference = "Stop"

$Root = (Resolve-Path $PSScriptRoot).Path
$Catalog = Join-Path $Root "catalog.tsv"

function Show-Usage {
  @"
Portable AI Skillkit — Curated catalog thin wrapper around npx skills

Commands:
  .\install.ps1 list                          Show all components grouped by category
  .\install.ps1 list-categories               Show available categories
  .\install.ps1 list-platforms                Show available platforms
  .\install.ps1 search KEYWORD                Search components by name/description
  .\install.ps1 top [N]                       Show top-N starred components
  .\install.ps1 --target PATH         Install all catalog components
  .\install.ps1 --target PATH --skill NAME          Install specific component(s)
  .\install.ps1 --category CATEGORY     Install by category (target defaults to .)
  .\install.ps1 --platform PLATFORM     Install by platform (target defaults to .)
  .\install.ps1 --agent-target AGENT    Install by agent target (target defaults to .)
  .\install.ps1 --from FILE             Install from favorites file (target defaults to .)
  .\install.ps1 --from FILE --tag TAG   Install favorites matching tags
  .\install.ps1 export --output PATH    Export portable bundle

  .\install.ps1 SKILL                   Install one skill to current directory
  .\install.ps1 SKILL1, SKILL2, ...     Install multiple skills to current directory

  .\install.ps1 remove SKILL            Remove installed skill(s)
  .\install.ps1 remove SKILL1, SKILL2   Remove multiple skills
  .\install.ps1 remove --all             Remove ALL installed skills
  .\install.ps1 installed               List installed skills
  .\install.ps1 update [SKILL]          Update installed skills

Examples:
  .\install.ps1 caveman                        # one-liner: install skill to .
  .\install.ps1 caveman, grill-me              # install multiple skills to .
  .\install.ps1 list
  .\install.ps1 search review
  .\install.ps1 --target C:\code\repo --skill caveman
  .\install.ps1 --target C:\code\repo --skill caveman,grill-me
  .\install.ps1 --target C:\code\repo --from favorites.tsv --tag daily-driver
  .\install.ps1 --target C:\code\repo --category workflow

  .\install.ps1 remove caveman                 # remove a skill
  .\install.ps1 remove caveman, grill-me       # remove multiple skills
  .\install.ps1 remove --all                   # remove ALL skills
  .\install.ps1 installed                      # list installed skills
  .\install.ps1 update                         # update all skills
  .\install.ps1 update caveman                 # update a specific skill
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
        Platforms = $fields[3]
        AgentTarget = $fields[4]
        Description = $fields[5]
        InstallCommand = if ($fields.Length -ge 7) { $fields[6] } else { "" }
        Stars = if ($fields.Length -ge 8) { $fields[7] } else { "" }
        RemoveCommand = if ($fields.Length -ge 9) { $fields[8] } else { "" }
      }
    }
  }
}

function Parse-Args {
  param([array]$RawArgs)
  $positional = @()
  $flags = @{}
  $i = 0
  while ($i -lt $RawArgs.Length) {
    if ($RawArgs[$i] -match '^--') {
      $key = $RawArgs[$i]
      $val = if ($i + 1 -lt $RawArgs.Length -and $RawArgs[$i+1] -notmatch '^--') { $RawArgs[++$i] } else { "" }
      $flags[$key] = $val
    } else {
      $positional += $RawArgs[$i]
    }
    $i++
  }
  return @{ Positional = $positional; Flags = $flags }
}

function Normalize-SkillFilter {
  param([string]$Input)
  if (-not $Input) { return "" }
  $normalized = $Input -replace ',', ' ' -replace '\s+', ' ' -replace '^\s+|\s+$', '' -replace ' ', ','
  return $normalized
}

function Filter-Catalog {
  param(
    [string]$CategoryFilter = "",
    [string]$PlatformFilter = "",
    [string]$AgentTargetFilter = "",
    [string]$SkillFilter = ""
  )

  $result = Read-Catalog
  if ($CategoryFilter) { $result = $result | Where-Object { $_.Category -eq $CategoryFilter } }
  if ($PlatformFilter) {
    $result = $result | Where-Object {
      $_.Platforms -eq "all" -or $_.Platforms -eq $PlatformFilter -or $_.Platforms -match "(^|,)$PlatformFilter($|,)"
    }
  }
  if ($AgentTargetFilter) { $result = $result | Where-Object { $_.AgentTarget -eq "all" -or $_.AgentTarget -eq $AgentTargetFilter } }
  if ($SkillFilter) {
    $skills = $SkillFilter -split ","
    $result = $result | Where-Object { $skills -contains $_.Name }
  }
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
      if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
      if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }
      if ($comp.Stars -and $comp.Stars -ne "-") { $tags += " ($($comp.Stars)★)" }
      Write-Host ("  {0,-20} {1}{2}" -f $comp.Name, $comp.Description, $tags)
    }
    Write-Host ""
  }

  Write-Host "Install one:     .\install.ps1 --target C:\code\repo --skill <name>"
  Write-Host "Install by cat:  .\install.ps1 --target C:\code\repo --category <cat>"
  Write-Host "Install all:     .\install.ps1 --target C:\code\repo"
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
    Write-Host "  .\install.ps1 list    to see all components"
    Write-Host "  .\install.ps1 top 5   to see top starred skills"
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
    if ($comp.Platforms -ne "all") { $tags += " [$($comp.Platforms)]" }
    if ($comp.AgentTarget -ne "all") { $tags += " → $($comp.AgentTarget)" }
    if ($comp.Stars -and $comp.Stars -ne "-") { $tags += " ($($comp.Stars)★)" }

    Write-Host ("  {0} {1,-20} {2}{3}" -f $icon, $comp.Name, $comp.Description, $tags)
  }

  Write-Host ""
  Write-Host "Install: .\install.ps1 --target C:\code\repo --skill <name>"
  Write-Host ""
}

function Cmd-Top {
  param([string]$N = "10")

  if ($N -notmatch '^\d+$') { $N = 10 }
  $N = [int]$N

  Write-Host ""
  Write-Host "⭐ Top $N Starred Components"
  Write-Host ""

  $results = Read-Catalog | Where-Object {
    $_.Stars -and $_.Stars -ne "-"
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
    Write-Host "No starred components found."
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
}

# ---------------------------------------------------------------------------
# Favorites resolution
# ---------------------------------------------------------------------------

function Read-Favorites {
  param([string]$File, [string]$TagFilter = "")

  if (-not (Test-Path $File)) {
    Write-Error "Favorites file not found: $File"
    return @()
  }

  $reqTags = if ($TagFilter) { $TagFilter -split "," | ForEach-Object { $_.Trim() } } else { @() }

  Get-Content -Path $File | Where-Object { $_ -notmatch '^#' -and $_ -notmatch '^name\t' } | ForEach-Object {
    $fields = $_ -split "`t"
    if ($fields.Length -lt 5) { return }
    $favTags = $fields[3] -split "," | ForEach-Object { $_.Trim() }
    $match = $reqTags.Count -eq 0
    foreach ($rt in $reqTags) {
      if ($favTags -contains $rt) { $match = $true; break }
    }
    if ($match) { $fields[0] }
  }
}

# ---------------------------------------------------------------------------
# Platform-specific command transformation
# ---------------------------------------------------------------------------

function Transform-CommandForPlatform {
  param(
    [string]$Command,
    [string]$Platform = ""
  )

  # No platform specified - return command as-is
  if (-not $Platform) { return $Command }

  switch ($Platform) {
    "opencode" {
      # OpenCode requires -a opencode flag for npx skills
      if ($Command -match '^npx\s+skills\s+add') {
        if ($Command -notmatch '-a\s+opencode') {
          $Command += " -a opencode"
        }
        if ($Command -notmatch '-g') {
          $Command += " -g"
        }
        if ($Command -notmatch '-y' -and $Command -notmatch '--yes') {
          $Command += " -y"
        }
      }
    }

    "pi" {
      # Pi uses pi install for npm packages with pi-extension
      if ($Command -match '^npm\s+install\s+(.+)$') {
        $pkg = $matches[1].Trim()
        if ($pkg -match 'pi-extension') {
          return "pi install npm:$pkg"
        }
      }
      # Pi can also install from GitHub repos
      if ($Command -match '^npx\s+skills\s+add\s+([^\s]+)') {
        $repo = $matches[1].Trim()
        if ($repo -match '/') {
          return "pi install https://github.com/$repo"
        }
      }
    }

    "codex" {
      # Codex uses: codex skills add <skill-name>
      if ($Command -match '^npx\s+skills\s+add\s+([^\s]+)') {
        $repo = $matches[1].Trim()
        $skillName = $repo -replace '.*/', ''
        return "codex skills add $skillName"
      }
    }

    "copilot" {
      # Copilot doesn't support CLI skill installation
      if ($Command -match '^npx\s+skills\s+add') {
        return "UNSUPPORTED:Copilot doesn't support npx skills installation. See docs/REFERENCES.md for Copilot skill setup."
      }
    }

    "claude" {
      # Claude Code uses npx skills with default behavior - no transform needed
    }
  }

  return $Command
}

# ---------------------------------------------------------------------------
# Install — thin wrapper around npx skills / npm install
# ---------------------------------------------------------------------------

function Cmd-Install {
  param(
    [string]$Target = "",
    [string]$CategoryFilter = "",
    [string]$PlatformFilter = "",
    [string]$AgentTargetFilter = "",
    [string]$SkillFilter = "",
    [string]$FromFile = "",
    [string]$TagFilter = ""
  )

  $SkillFilter = Normalize-SkillFilter -Input $SkillFilter

  if ($TagFilter -and -not $FromFile) {
    Write-Error "--tag requires --from <favorites-file>"
    Show-Usage
    exit 1
  }

  if (-not $Target) {
    $Target = "."
  }

  # Resolve favorites to catalog entries
  if ($FromFile) {
    $favNames = Read-Favorites -File $FromFile -TagFilter $TagFilter
    if ($favNames.Count -eq 0) {
      Write-Host "No favorites match the tag filter: $($TagFilter -or '(none)')"
      return
    }

    $catalogNames = Read-Catalog | Select-Object -ExpandProperty Name
    $validNames = @()
    foreach ($name in $favNames) {
      if ($catalogNames -contains $name) {
        $validNames += $name
      } else {
        Write-Warning "$name : not found in catalog, skipping"
      }
    }

    if ($validNames.Count -eq 0) {
      Write-Host "No valid favorites found in catalog."
      return
    }

    $SkillFilter = $validNames -join ","
  }

  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $Target = (Resolve-Path $Target).Path

  Write-Host "Installing Portable AI Skillkit to $Target"

  $components = Filter-Catalog -CategoryFilter $CategoryFilter -PlatformFilter $PlatformFilter -AgentTargetFilter $AgentTargetFilter -SkillFilter $SkillFilter

  if ($components.Count -eq 0) {
    Write-Host "No components match the filter (category=$CategoryFilter, platform=$PlatformFilter, agent=$AgentTargetFilter, skill=$SkillFilter)"
    return
  }

  Write-Host "  Components to install: $($components.Count)"
  Write-Host ""

  foreach ($comp in ($components | Sort-Object Name)) {
    if (-not $comp.InstallCommand -or $comp.InstallCommand -eq "-") {
      Write-Host "  ⚠ $($comp.Name): no install command" -ForegroundColor Yellow
      continue
    }

    # Transform command based on platform
    $cmd = Transform-CommandForPlatform -Command $comp.InstallCommand -Platform $PlatformFilter

    # Handle unsupported platforms
    if ($cmd -match '^UNSUPPORTED:') {
      Write-Host "  → $($comp.Name) ($($comp.Description))"
      Write-Warning "  ⚠ $($cmd.Substring(12))"
      Write-Host ""
      continue
    }

    # Skip empty commands
    if (-not $cmd) { continue }

    Write-Host "  → $($comp.Name) ($($comp.Description))"
    Write-Host "    $cmd"

    try {
      $origDir = Get-Location
      Set-Location $Target
      Invoke-Expression $cmd
      Set-Location $origDir
      Write-Host "  ✓ $($comp.Name) installed"
      Write-Host ""
    }
    catch {
      Set-Location $origDir
      Write-Warning "  ⚠ $($comp.Name) installation failed (non-fatal): $_"
      Write-Host ""
    }
  }

  Write-Host "✓ Installation complete"
  switch ($PlatformFilter) {
    "opencode" { Write-Host "  Skills installed to .opencode/skills/" }
    "pi"       { Write-Host "  Skills installed to .pi/skills/" }
    "codex"    { Write-Host "  Skills installed to .codex/skills/" }
    "copilot"  { Write-Host "  See docs/REFERENCES.md for Copilot skill configuration" }
    "claude"   { Write-Host "  Skills installed to .claude/skills/" }
    default    { Write-Host "  npx skills manages .agents/skills/ and platform symlinks automatically." }
  }
}

# ---------------------------------------------------------------------------
# Remove command - local and global
# ---------------------------------------------------------------------------

# Global skill directories to check/remove from
$script:GlobalSkillDirs = @(
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

# Remove skill from global directories
function Remove-GlobalSkill {
  param([string]$SkillName)
  
  $removed = $false
  
  foreach ($dir in $script:GlobalSkillDirs) {
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

# Remove npm global package
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
  }
  catch {
    # Ignore errors
  }
  return $false
}

function Cmd-Remove {
  param(
    [string]$Target = "",
    [string]$SkillFilter = "",
    [string]$PlatformFilter = "",
    [switch]$All = $false
  )

  $SkillFilter = Normalize-SkillFilter -Input $SkillFilter

  if (-not $Target) { $Target = "." }
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $Target = (Resolve-Path $Target).Path

  # --all: nuke everything
  if ($All) {
    Write-Host "Removing ALL skills from $Target"
    try {
      $origDir = Get-Location
      Set-Location $Target
      Invoke-Expression "npx skills remove --all --yes"
      Set-Location $origDir
      Write-Host "✓ All local skills removed"
    }
    catch {
      Set-Location $origDir
      Write-Warning "  ⚠ bulk local removal failed (non-fatal): $_"
    }
    
    # Also remove from global directories
    Write-Host "Removing global skills..."
    foreach ($dir in $script:GlobalSkillDirs) {
      if (Test-Path $dir) {
        Remove-Item -Path "$dir/*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Cleared $dir"
      }
    }
    return
  }

  if (-not $SkillFilter) {
    Write-Error "remove requires a SKILL name (or --all)"
    Show-Usage
    exit 1
  }

  Write-Host "Removing skills from $Target"

  $skills = $SkillFilter -split ","
  $catalog = Read-Catalog

  foreach ($skillName in $skills) {
    Write-Host ""
    Write-Host "→ $skillName"
    
    $comp = $catalog | Where-Object { $_.Name -eq $skillName } | Select-Object -First 1

    # 1. Remove from local target directory
    $removeCmd = $null
    if ($comp -and $comp.RemoveCommand -and $comp.RemoveCommand -ne "-") {
      $removeCmd = $comp.RemoveCommand
    }

    # Derive from install command
    if (-not $removeCmd -and $comp) {
      $installCmd = $comp.InstallCommand
      if ($installCmd -match '^npx skills add') {
        $removeCmd = "npx skills remove $skillName --yes"
      } elseif ($installCmd -match '^npm\s+install\s+-g\s+(.+)$') {
        $pkg = $matches[1].Trim()
        $removeCmd = "npm uninstall -g $pkg"
      } elseif ($installCmd -match '^npm\s+install\s+(.+)$') {
        $pkg = $matches[1].Trim()
        $removeCmd = "npm uninstall $pkg"
      } elseif ($installCmd -match '^pi\s+install\s+(.+)$') {
        $pkg = $matches[1].Trim()
        $removeCmd = "pi remove $pkg"
      }
    }

    # Fallback: try npx skills remove for anything not in catalog
    if (-not $removeCmd) {
      $removeCmd = "npx skills remove $skillName --yes"
    }

    Write-Host "  Local: $removeCmd"
    try {
      $origDir = Get-Location
      Set-Location $Target
      Invoke-Expression $removeCmd | Out-Null
      Set-Location $origDir
      Write-Host "    ✓ Removed from local project"
    }
    catch {
      Set-Location $origDir
      Write-Host "    ℹ Not found in local project (or already removed)"
    }

    # 2. Remove from global directories
    Write-Host "  Global directories..."
    if (Remove-GlobalSkill -SkillName $skillName) {
      # Items were removed (output already printed)
    } else {
      Write-Host "    ℹ Not found in global directories"
    }

    # 3. Also try npm global removal
    Write-Host "  NPM global packages..."
    if (Remove-NpmGlobal -Pattern $skillName) {
      # Packages were removed (output already printed)
    } else {
      Write-Host "    ℹ No matching npm global packages"
    }
  }

  Write-Host ""
  Write-Host "✓ Removal complete"
}

# ---------------------------------------------------------------------------
# Installed command
# ---------------------------------------------------------------------------

function Cmd-Installed {
  param([string]$Target = "")

  if (-not $Target) { $Target = "." }
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $Target = (Resolve-Path $Target).Path

  Write-Host "Installed skills in $Target:"
  Write-Host ""

  try {
    $origDir = Get-Location
    Set-Location $Target
    Invoke-Expression "npx skills list"
    Set-Location $origDir
  }
  catch {
    Set-Location $origDir
    Write-Host "  (no skills found or npx skills not available)"
  }
}

# ---------------------------------------------------------------------------
# Update command
# ---------------------------------------------------------------------------

function Cmd-Update {
  param(
    [string]$Target = "",
    [string]$SkillFilter = ""
  )

  $SkillFilter = Normalize-SkillFilter -Input $SkillFilter

  if (-not $Target) { $Target = "." }
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $Target = (Resolve-Path $Target).Path

  Write-Host "Updating skills in $Target"

  try {
    $origDir = Get-Location
    Set-Location $Target
    if ($SkillFilter) {
      $skills = ($SkillFilter -split "," | ForEach-Object { $_.Trim() }) -join " "
      Invoke-Expression "npx skills update $skills"
    } else {
      Invoke-Expression "npx skills update"
    }
    Set-Location $origDir
    Write-Host "✓ Update complete"
  }
  catch {
    Set-Location $origDir
    Write-Warning "  ⚠ update failed: $_"
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
  Copy-Item -Path (Join-Path $Root "install.sh") -Destination $Output -Force -ErrorAction SilentlyContinue
  Copy-Item -Path (Join-Path $Root "install.ps1") -Destination $Output -Force -ErrorAction SilentlyContinue

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

$knownCommands = @("list", "list-categories", "list-platforms", "search", "top", "install", "export", "remove", "installed", "update")

# If first argument is a flag (starts with --), default to install command
if ($command -match '^--') {
  $remaining = $args
  $command = "install"
}
# If first argument is not a known command, treat positional args as skill names
elseif ($command -and $knownCommands -notcontains $command) {
  $skills = $command
  $remaining = @()
  $foundFlag = $false
  for ($i = 1; $i -lt $args.Length; $i++) {
    if ($args[$i] -match '^--') {
      $remaining = $args[$i..$args.Length]
      $foundFlag = $true
      break
    }
    $skills += ",$($args[$i])"
  }
  $remaining = @("--skill", $skills) + $remaining
  $command = "install"
}

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
    $categoryFilter = ""
    $platformFilter = ""
    $agentTargetFilter = ""
    $skillFilter = ""
    $fromFile = ""
    $tagFilter = ""

    for ($i = 0; $i -lt $remaining.Length; $i++) {
      switch ($remaining[$i]) {
        "--target"       { $target = $remaining[++$i] }
        "--category"     { $categoryFilter = $remaining[++$i] }
        "--platform"     { $platformFilter = $remaining[++$i] }
        "--agent-target" { $agentTargetFilter = $remaining[++$i] }
        "--skill"        { $skillFilter = $remaining[++$i] }
        "--from"         { $fromFile = $remaining[++$i] }
        "--tag"          { $tagFilter = $remaining[++$i] }
        default {
          if ($remaining[$i] -match '^--') {
            Write-Error "Unknown flag: $($remaining[$i]). Did you mean --skill? Use --skill <name> to install a specific component."
            Show-Usage
            exit 1
          }
        }
      }
    }

    Cmd-Install -Target $target -CategoryFilter $categoryFilter -PlatformFilter $platformFilter -AgentTargetFilter $agentTargetFilter -SkillFilter $skillFilter -FromFile $fromFile -TagFilter $tagFilter
  }
  "export" {
    $output = ""
    for ($i = 0; $i -lt $remaining.Length; $i++) {
      if ($remaining[$i] -eq "--output") { $output = $remaining[++$i] }
    }
    Cmd-Export -Output $output
  }
  "remove" {
    $parsed = Parse-Args $remaining
    $target = $parsed.Flags["--target"]
    $skillFilter = if ($parsed.Flags["--skill"]) { $parsed.Flags["--skill"] } else { $parsed.Positional -join "," }
    $all = $parsed.Flags.ContainsKey("--all")
    Cmd-Remove -Target $target -SkillFilter $skillFilter -All:$all
  }
  "installed" {
    $parsed = Parse-Args $remaining
    $target = $parsed.Flags["--target"]
    Cmd-Installed -Target $target
  }
  "update" {
    $parsed = Parse-Args $remaining
    $target = $parsed.Flags["--target"]
    $skillFilter = if ($parsed.Flags["--skill"]) { $parsed.Flags["--skill"] } else { $parsed.Positional -join "," }
    Cmd-Update -Target $target -SkillFilter $skillFilter
  }
  default {
    Show-Usage
    exit 1
  }
}
