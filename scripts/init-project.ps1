$ErrorActionPreference = "Stop"

. (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")) ".bootstrap/scripts/init-project.ps1")

Invoke-BootstrapProjectInit
