$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$MarkBegin = "<!-- BEGIN AI SKILLKIT -->"
$MarkEnd = "<!-- END AI SKILLKIT -->"

function Show-Usage {
  @"
Portable AI Skillkit

Commands:
  .\scripts\skillkit.ps1 list
  .\scripts\skillkit.ps1 list-components
  .\scripts\skillkit.ps1 install --target PATH --skills all|a,b --agents all|a,b
  .\scripts\skillkit.ps1 export --output PATH --skills all|a,b

Agents:
  all, shared, codex, claude, opencode, github, pi

Examples:
  .\scripts\install.ps1 --target C:\code\repo
  .\scripts\install.ps1 --target C:\code\repo --skills grill-me,caveman
  .\scripts\install.ps1 --target C:\code\repo --agents codex,claude
"@
}

function Get-AllSkills {
  Get-ChildItem -Path (Join-Path $Root "skills") -Directory |
    Sort-Object Name |
    ForEach-Object { $_.Name }
}

function Get-AllComponents {
  Get-ChildItem -Path (Join-Path $Root "components") -File -Filter "*.md" |
    Sort-Object BaseName |
    ForEach-Object { $_.BaseName }
}

function Get-SkillDescription {
  param([Parameter(Mandatory = $true)][string]$Skill)

  $skillPath = Join-Path $Root "skills/$Skill/SKILL.md"
  foreach ($line in Get-Content -Path $skillPath) {
    if ($line -match '^description:\s*(.*)$') {
      return ($Matches[1].Trim() -replace '^"|"$', '')
    }
  }

  return ""
}

function Resolve-Csv {
  param(
    [Parameter(Mandatory = $true)][string]$Value,
    [Parameter(Mandatory = $true)][string]$Kind
  )

  if ($Value -eq "all") {
    if ($Kind -eq "skill") {
      return @(Get-AllSkills)
    }

    return @("shared", "codex", "claude", "opencode", "github", "pi")
  }

  return @(
    $Value -split "," |
      ForEach-Object { $_.Trim() } |
      Where-Object { $_ -ne "" }
  )
}

function Resolve-Skills {
  param([Parameter(Mandatory = $true)][string]$Csv)

  $resolved = @(Resolve-Csv -Value $Csv -Kind "skill")
  foreach ($skill in $resolved) {
    $skillPath = Join-Path $Root "skills/$skill/SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
      throw "Unknown skill: $skill"
    }
  }

  return $resolved
}

function Resolve-Agents {
  param([Parameter(Mandatory = $true)][string]$Csv)

  return @(Resolve-Csv -Value $Csv -Kind "agent")
}

function Update-ManagedBlock {
  param(
    [Parameter(Mandatory = $true)][string]$File,
    [Parameter(Mandatory = $true)][string]$Body
  )

  $dir = Split-Path -Parent $File
  if ($dir) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }

  $existing = ""
  if (Test-Path -LiteralPath $File) {
    $existing = Get-Content -Raw -Path $File
  }

  $pattern = "(?s)\r?\n?$([regex]::Escape($MarkBegin)).*?$([regex]::Escape($MarkEnd))\r?\n?"
  $clean = [regex]::Replace($existing, $pattern, "")
  $content = $clean.TrimEnd() + "`n`n$MarkBegin`n$Body`n$MarkEnd`n"

  Set-Content -Path $File -Value $content -NoNewline -Encoding utf8
}

function Write-SharedIndex {
  param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string[]]$Skills
  )

  $sharedDir = Join-Path $Target ".ai/skillkit"
  $skillsDir = Join-Path $sharedDir "skills"
  New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

  $lines = [System.Collections.Generic.List[string]]::new()
  $lines.Add("# AI Skillkit")
  $lines.Add("")
  $lines.Add("Shared instructions installed from Portable AI Skillkit.")
  $lines.Add("")
  $lines.Add("## Active Skills")
  $lines.Add("")

  foreach ($skill in $Skills) {
    Copy-Item -Path (Join-Path $Root "skills/$skill/SKILL.md") -Destination (Join-Path $skillsDir "$skill.md") -Force
    $lines.Add("- ``$skill``: $(Get-SkillDescription -Skill $skill)")
  }

  $lines.Add("")
  $lines.Add("## Usage")
  $lines.Add("")
  $lines.Add("When the user names one of the active skills, follow its instructions from ``.ai/skillkit/skills/<skill>.md``.")
  $lines.Add("For normal coding work, default to ``control-first`` when it is installed.")
  $lines.Add("Use ``grill-me`` only when unclear requirements would make implementation risky.")
  $lines.Add("Use ``caveman`` when the user wants terse output or token discipline.")

  Set-Content -Path (Join-Path $sharedDir "AGENTS.md") -Value ($lines -join "`n") -Encoding utf8
}

function Install-StackDocs {
  param([Parameter(Mandatory = $true)][string]$Target)

  $sharedDir = Join-Path $Target ".ai/skillkit"
  $componentsDir = Join-Path $sharedDir "components"
  $stacksDir = Join-Path $sharedDir "stacks"

  New-Item -ItemType Directory -Force -Path $componentsDir, $stacksDir | Out-Null
  Copy-Item -Path (Join-Path $Root "stacks/control-first.md") -Destination (Join-Path $stacksDir "control-first.md") -Force
  Copy-Item -Path (Join-Path $Root "components/*.md") -Destination $componentsDir -Force
}

function Install-Shared {
  param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string[]]$Skills
  )

  $lines = [System.Collections.Generic.List[string]]::new()
  $lines.Add("## AI Skillkit")
  $lines.Add("Follow the shared instructions in ``.ai/skillkit/AGENTS.md``.")
  $lines.Add("")
  $lines.Add("Active skills:")

  foreach ($skill in $Skills) {
    $lines.Add("- ``$skill``: .ai/skillkit/skills/$skill.md")
  }

  Update-ManagedBlock -File (Join-Path $Target "AGENTS.md") -Body ($lines -join "`n")
}

function Install-Claude {
  param([Parameter(Mandatory = $true)][string]$Target)

  $body = "@.ai/skillkit/AGENTS.md`n`nUse the shared AI Skillkit instructions above. For risky work, prefer a short plan before edits."
  Update-ManagedBlock -File (Join-Path $Target "CLAUDE.md") -Body $body
}

function Install-GitHub {
  param([Parameter(Mandatory = $true)][string]$Target)

  $body = "Follow the repository AI Skillkit instructions in ``.ai/skillkit/AGENTS.md`` and ``AGENTS.md``.`n`nKeep changes narrowly scoped, preserve existing project conventions, run relevant tests, and summarize verification."
  Update-ManagedBlock -File (Join-Path $Target ".github/copilot-instructions.md") -Body $body
}

function Install-OpenCode {
  param([Parameter(Mandatory = $true)][string]$Target)

  $body = "Follow ``../AGENTS.md`` and ``.ai/skillkit/AGENTS.md`` for project behavior.`n`nUse installed skills from ``.ai/skillkit/skills/`` when the user names them."
  Update-ManagedBlock -File (Join-Path $Target ".opencode/AGENTS.md") -Body $body
}

function Install-Codex {
  param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string[]]$Skills
  )

  foreach ($skill in $Skills) {
    $dir = Join-Path $Target ".codex/skills/$skill"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -Path (Join-Path $Root "skills/$skill/SKILL.md") -Destination (Join-Path $dir "SKILL.md") -Force
  }
}

function Install-Pi {
  param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string[]]$Skills
  )

  foreach ($skill in $Skills) {
    $dir = Join-Path $Target ".pi/skills/$skill"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -Path (Join-Path $Root "skills/$skill/SKILL.md") -Destination (Join-Path $dir "SKILL.md") -Force
  }
}

function Parse-Options {
  param([string[]]$Items)

  $parsed = @{}
  $i = 0
  while ($i -lt $Items.Count) {
    $key = $Items[$i]
    if ($key -in @("--target", "-target", "-Target")) {
      if ($i + 1 -ge $Items.Count) { throw "Missing value for $key" }
      $parsed["target"] = $Items[$i + 1]
      $i += 2
      continue
    }
    if ($key -in @("--skills", "-skills", "-Skills")) {
      if ($i + 1 -ge $Items.Count) { throw "Missing value for $key" }
      $parsed["skills"] = $Items[$i + 1]
      $i += 2
      continue
    }
    if ($key -in @("--agents", "-agents", "-Agents")) {
      if ($i + 1 -ge $Items.Count) { throw "Missing value for $key" }
      $parsed["agents"] = $Items[$i + 1]
      $i += 2
      continue
    }
    if ($key -in @("--output", "-output", "-Output")) {
      if ($i + 1 -ge $Items.Count) { throw "Missing value for $key" }
      $parsed["output"] = $Items[$i + 1]
      $i += 2
      continue
    }
    if ($key -in @("--help", "-help", "-h")) {
      $parsed["help"] = "true"
      $i += 1
      continue
    }

    throw "Unknown option: $key"
  }

  return $parsed
}

function Invoke-List {
  foreach ($skill in Get-AllSkills) {
    "$skill`t$(Get-SkillDescription -Skill $skill)"
  }
}

function Invoke-ListComponents {
  foreach ($component in Get-AllComponents) {
    "$component`tcomponents/$component.md"
  }
}

function Invoke-Install {
  param([string[]]$Items)

  $options = Parse-Options -Items $Items
  if ($options.ContainsKey("help")) {
    Show-Usage
    return
  }

  $target = if ($options.ContainsKey("target")) { $options["target"] } else { (Get-Location).Path }
  $skillsCsv = if ($options.ContainsKey("skills")) { $options["skills"] } else { "all" }
  $agentsCsv = if ($options.ContainsKey("agents")) { $options["agents"] } else { "all" }

  New-Item -ItemType Directory -Force -Path $target | Out-Null

  $skills = @(Resolve-Skills -Csv $skillsCsv)
  $agents = @(Resolve-Agents -Csv $agentsCsv)

  Write-SharedIndex -Target $target -Skills $skills
  Install-StackDocs -Target $target

  foreach ($agent in $agents) {
    switch ($agent) {
      "shared" { Install-Shared -Target $target -Skills $skills }
      "codex" { Install-Codex -Target $target -Skills $skills }
      "claude" { Install-Claude -Target $target }
      "opencode" { Install-OpenCode -Target $target }
      "github" { Install-GitHub -Target $target }
      "pi" { Install-Pi -Target $target -Skills $skills }
      default { throw "Unknown agent: $agent" }
    }
  }

  "Installed $($skills.Count) skill(s) for agents: $($agents -join ',')"
  "Target: $target"
}

function Invoke-Export {
  param([string[]]$Items)

  $options = Parse-Options -Items $Items
  if ($options.ContainsKey("help")) {
    Show-Usage
    return
  }
  if (-not $options.ContainsKey("output")) {
    throw "Missing required --output PATH"
  }

  $output = $options["output"]
  $skillsCsv = if ($options.ContainsKey("skills")) { $options["skills"] } else { "all" }
  $skills = @(Resolve-Skills -Csv $skillsCsv)

  New-Item -ItemType Directory -Force -Path (Join-Path $output "skills"), (Join-Path $output "scripts"), (Join-Path $output "components"), (Join-Path $output "stacks") | Out-Null
  Copy-Item -Path (Join-Path $Root "README.md") -Destination (Join-Path $output "README.md") -Force
  Copy-Item -Path (Join-Path $Root "AGENTS.md") -Destination (Join-Path $output "AGENTS.md") -Force
  Copy-Item -Path (Join-Path $Root "scripts/skillkit.sh") -Destination (Join-Path $output "scripts/skillkit.sh") -Force
  Copy-Item -Path (Join-Path $Root "scripts/install.sh") -Destination (Join-Path $output "scripts/install.sh") -Force
  Copy-Item -Path (Join-Path $Root "scripts/export.sh") -Destination (Join-Path $output "scripts/export.sh") -Force
  Copy-Item -Path (Join-Path $Root "scripts/skillkit.ps1") -Destination (Join-Path $output "scripts/skillkit.ps1") -Force
  Copy-Item -Path (Join-Path $Root "scripts/install.ps1") -Destination (Join-Path $output "scripts/install.ps1") -Force
  Copy-Item -Path (Join-Path $Root "scripts/export.ps1") -Destination (Join-Path $output "scripts/export.ps1") -Force
  Copy-Item -Path (Join-Path $Root "stacks/control-first.md") -Destination (Join-Path $output "stacks/control-first.md") -Force
  Copy-Item -Path (Join-Path $Root "components/*.md") -Destination (Join-Path $output "components") -Force

  foreach ($skill in $skills) {
    $dir = Join-Path $output "skills/$skill"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -Path (Join-Path $Root "skills/$skill/SKILL.md") -Destination (Join-Path $dir "SKILL.md") -Force
  }

  "Exported $($skills.Count) skill(s) to $output"
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }
$rest = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] } else { @() }

switch ($command) {
  "list" { Invoke-List }
  "list-components" { Invoke-ListComponents }
  "install" { Invoke-Install -Items $rest }
  "export" { Invoke-Export -Items $rest }
  { $_ -in @("help", "-h", "--help") } { Show-Usage }
  default {
    throw "Unknown command: $command"
  }
}
