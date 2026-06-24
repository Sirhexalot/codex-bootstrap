param(
  [string] $Mode = "",
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $Args
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "..\.bootstrap\lib\tool-catalog.ps1")

$selectedMode = $Mode
$bundles = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $Args.Count; $i++) {
  $arg = $Args[$i]
  switch -Regex ($arg) {
    '^--mode$' {
      if ($i + 1 -ge $Args.Count) {
        throw "Missing value after --mode."
      }
      $selectedMode = $Args[$i + 1]
      $i++
      continue
    }
    '^(global|project|workspace)$' {
      if (-not $selectedMode -and $bundles.Count -eq 0) {
        $selectedMode = $arg
      } else {
        $bundles.Add($arg)
      }
      continue
    }
    default {
      $bundles.Add($arg)
      continue
    }
  }
}

if ($bundles.Count -eq 0) {
  $bundles.Add("all")
}

Invoke-InstallTools -Mode $selectedMode -Bundles $bundles.ToArray()
