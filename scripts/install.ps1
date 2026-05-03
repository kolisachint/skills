$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "skillkit.ps1") install @args
