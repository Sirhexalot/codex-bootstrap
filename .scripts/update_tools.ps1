param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $Bundles
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "..\.bootstrap\lib\tool-catalog.ps1")

if (-not $Bundles -or $Bundles.Count -eq 0) {
  $Bundles = @("all")
}

Invoke-UpdateTools -Bundles $Bundles
