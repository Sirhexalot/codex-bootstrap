$ErrorActionPreference = "Stop"

. (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")) ".bootstrap/scripts/bootstrap-project-init.ps1")

Invoke-BootstrapProjectInit
