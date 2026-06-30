$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "..\.bootstrap\lib\tool-catalog.ps1")

Write-Host "Setting up the global Codex workbench on Windows."
Write-Host "This script installs shared tooling only."
Write-Host "It does not install Codex or any skills."
Write-Host ""

Invoke-InstallTools -Mode "global" -Bundles @("all")
