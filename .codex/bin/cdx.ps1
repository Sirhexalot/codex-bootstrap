$ErrorActionPreference = "Stop"
$Script:ScriptDir = $PSScriptRoot
$Script:CodexRoot = Split-Path -Parent $Script:ScriptDir
$Script:RepoRoot = Split-Path -Parent $Script:CodexRoot

function Get-BashExecutable {
  $candidates = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files\Git\usr\bin\bash.exe",
    (Get-Command bash -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue)
  ) | Where-Object { $_ -and (Test-Path $_) }

  
  if ($candidates.Count -gt 0) {
    return $candidates[0]
  }

  throw "No Bash executable was found. Install Git for Windows first, then rerun this command."
}

function Get-RepoPaths {
  $scriptDir = $Script:ScriptDir
  $codexRoot = $Script:CodexRoot
  $repoRoot = $Script:RepoRoot
  $stateToolsDir = Join-Path $codexRoot "state\tools"
  $runtimeRoot = Join-Path $codexRoot "runtime\tools"
  $runtimeBinDir = Join-Path $runtimeRoot "bin"
  $globalToolRoot = Join-Path $HOME ".codex\workbench"
  $globalPythonVenv = Join-Path $globalToolRoot "python"
  $globalBinDir = Join-Path $HOME ".local\bin"

  [pscustomobject]@{
    ScriptDir = $scriptDir
    CodexRoot = $codexRoot
    RepoRoot = $repoRoot
    StateToolsDir = $stateToolsDir
    RuntimeRoot = $runtimeRoot
    RuntimeBinDir = $runtimeBinDir
    GlobalToolRoot = $globalToolRoot
    GlobalPythonVenv = $globalPythonVenv
    GlobalBinDir = $globalBinDir
  }
}

function Ensure-Directory {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Get-BashPathStyle {
  param([string]$BashExecutable)

  $detectedStyle = & $BashExecutable --noprofile --norc -lc "if [ -d /mnt/c ]; then printf 'wsl'; elif [ -d /c ]; then printf 'msys'; else printf 'unknown'; fi"
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($detectedStyle)) {
    return "unknown"
  }

  return $detectedStyle.Trim()
}

function Convert-WindowsPathToBash {
  param(
    [string]$Path,
    [string]$Style = "unknown"
  )

  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  $normalizedPath = $resolvedPath -replace "\\", "/"

  if ($normalizedPath -match "^([A-Za-z]):(.*)$") {
    $driveLetter = $Matches[1].ToLower()
    $pathSuffix = $Matches[2]

    if ($Style -eq "wsl") {
      return "/mnt/$driveLetter$pathSuffix"
    }

    return "/$driveLetter$pathSuffix"
  }

  return $normalizedPath
}

function Get-WindowsCommandPath {
  param([string]$Name)

  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($null -ne $command) {
    return $command.Source
  }

  return $null
}

function Invoke-WingetInstall {
  param(
    [string]$Id,
    [string]$DisplayName
  )

  if (-not (Get-WindowsCommandPath "winget")) {
    throw "winget was not found. Install App Installer from Microsoft first, then rerun setup."
  }

  Write-Host "Installing $DisplayName via winget..."
  & winget install --exact --id $Id --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
}

function Ensure-WingetCommand {
  param(
    [string]$CommandName,
    [string]$WingetId,
    [string]$DisplayName
  )

  if (Get-WindowsCommandPath $CommandName) {
    return
  }

  Invoke-WingetInstall -Id $WingetId -DisplayName $DisplayName
}

function New-CommandWrapperPair {
  param(
    [string]$BasePathWithoutExtension,
    [string]$Executable,
    [string[]]$FixedArgs = @()
  )

  $cmdPath = "$BasePathWithoutExtension.cmd"
  $ps1Path = "$BasePathWithoutExtension.ps1"
  $escapedExe = $Executable.Replace('"', '""')
  $cmdArgs = if ($FixedArgs.Count -gt 0) {
    ($FixedArgs | ForEach-Object { '"{0}"' -f $_.Replace('"', '""') }) -join ' '
  } else {
    ""
  }
  $psArgs = if ($FixedArgs.Count -gt 0) {
    ($FixedArgs | ForEach-Object { "'{0}'" -f $_.Replace("'", "''") }) -join ", "
  } else {
    ""
  }

  $cmdContent = if ($cmdArgs) {
    "@echo off`r`n""$escapedExe"" $cmdArgs %*`r`n"
  } else {
    "@echo off`r`n""$escapedExe"" %*`r`n"
  }

  $ps1Content = @(
    '$ErrorActionPreference = "Stop"'
    '$fixedArgs = @(' + $psArgs + ')'
    '$allArgs = @($fixedArgs + $args)'
    '& "' + $Executable + '" @allArgs'
  ) -join "`r`n"

  Set-Content -LiteralPath $cmdPath -Value $cmdContent -Encoding ASCII
  Set-Content -LiteralPath $ps1Path -Value $ps1Content -Encoding ASCII
}

function Get-PythonBootstrapCommand {
  $pythonPath = Get-WindowsCommandPath "python"
  if ($pythonPath) {
    return [pscustomobject]@{
      Executable = $pythonPath
      PrefixArgs = @()
    }
  }

  $pyPath = Get-WindowsCommandPath "py"
  if ($pyPath) {
    return [pscustomobject]@{
      Executable = $pyPath
      PrefixArgs = @("-3")
    }
  }

  throw "Python was not found after installation. Open a new terminal and rerun setup."
}

function Write-ToolMetadata {
  param(
    [pscustomobject]$Paths,
    [string]$Bundle,
    [string]$Mode,
    [string]$TargetDir,
    [string]$Commands,
    [string]$Packages,
    [string]$Notes,
    [string]$ScopeSupport
  )

  Ensure-Directory $Paths.StateToolsDir
  $updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $metadataPath = Join-Path $Paths.StateToolsDir "$Mode--$Bundle.env"
  $content = @(
    "NAME=$Bundle"
    "KIND=tool"
    "SCOPE=$Mode"
    "SOURCE=bundle:$Bundle"
    "TARGET_DIR=$TargetDir"
    "COMMANDS=$Commands"
    "UPDATED_AT=$updatedAt"
    "NOTES=$Notes"
    "MODE=$Mode"
    "TYPE=bundle"
    "SCOPE_SUPPORT=$ScopeSupport"
    "PACKAGES=$Packages"
  )
  Set-Content -LiteralPath $metadataPath -Value $content -Encoding UTF8
}

function Install-CoreBundleWindows {
  param([pscustomobject]$Paths)

  Ensure-WingetCommand -CommandName "git" -WingetId "Git.Git" -DisplayName "Git"
  Ensure-WingetCommand -CommandName "python" -WingetId "Python.Python.3.12" -DisplayName "Python"
  Ensure-WingetCommand -CommandName "node" -WingetId "OpenJS.NodeJS.LTS" -DisplayName "Node.js LTS"
  Ensure-WingetCommand -CommandName "rg" -WingetId "BurntSushi.ripgrep.MSVC" -DisplayName "ripgrep"

  $pythonCmd = Get-PythonBootstrapCommand
  & $pythonCmd.Executable @($pythonCmd.PrefixArgs + @("-m", "pip", "install", "--user", "--upgrade", "pip", "pipx"))
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install pipx via pip."
  }

  & $pythonCmd.Executable @($pythonCmd.PrefixArgs + @("-m", "pipx", "ensurepath"))
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "pipx ensurepath failed. You may need to add the pipx scripts directory to PATH manually."
  }

  Write-ToolMetadata -Paths $Paths -Bundle "core" -Mode "global" -TargetDir (($Paths.GlobalToolRoot, $Paths.GlobalBinDir) -join "|") -Commands "python,node,npm,git,winget,pipx,rg" -Packages "winget:Git.Git,Python.Python.3.12,OpenJS.NodeJS.LTS,BurntSushi.ripgrep.MSVC|pip:pip,pipx" -Notes "Core Windows tools are managed via winget and pip." -ScopeSupport "global_only"
}

function Install-DocumentsBundleWindows {
  param([pscustomobject]$Paths)

  Ensure-Directory $Paths.GlobalToolRoot
  Ensure-Directory $Paths.GlobalBinDir
  Ensure-WingetCommand -CommandName "pandoc" -WingetId "JohnMacFarlane.Pandoc" -DisplayName "Pandoc"

  $pythonCmd = Get-PythonBootstrapCommand
  & $pythonCmd.Executable @($pythonCmd.PrefixArgs + @("-m", "venv", $Paths.GlobalPythonVenv))
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the global Python virtual environment."
  }

  $venvPython = Join-Path $Paths.GlobalPythonVenv "Scripts\python.exe"
  & $venvPython -m pip install --upgrade pip
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to upgrade pip in the global document environment."
  }

  & $venvPython -m pip install --upgrade openpyxl python-docx python-pptx markitdown pypdf pymupdf
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install Python document packages."
  }

  & npm.cmd install -g mammoth docx xlsx pptxgenjs pdf-parse
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install Node document packages."
  }

  $codexPythonBase = Join-Path $Paths.GlobalBinDir "codex-python"
  $codexMarkitdownBase = Join-Path $Paths.GlobalBinDir "codex-markitdown"
  New-CommandWrapperPair -BasePathWithoutExtension $codexPythonBase -Executable $venvPython
  New-CommandWrapperPair -BasePathWithoutExtension $codexMarkitdownBase -Executable $venvPython -FixedArgs @("-m", "markitdown")

  Write-ToolMetadata -Paths $Paths -Bundle "documents" -Mode "global" -TargetDir (($Paths.GlobalPythonVenv, $Paths.GlobalBinDir) -join "|") -Commands "codex-python.cmd,codex-markitdown.cmd,pandoc" -Packages "winget:JohnMacFarlane.Pandoc|python:openpyxl,python-docx,python-pptx,markitdown,pypdf,pymupdf|npm:mammoth,docx,xlsx,pptxgenjs,pdf-parse" -Notes "Global document tooling is managed with a Windows venv plus npm packages." -ScopeSupport "global_or_project"
}

function Install-BrowserAutomationBundleWindows {
  param([pscustomobject]$Paths)

  & npm.cmd install -g pnpm playwright
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install pnpm and Playwright globally."
  }

  & npx.cmd -y playwright install
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install Playwright browser binaries."
  }

  Write-ToolMetadata -Paths $Paths -Bundle "browser-automation" -Mode "global" -TargetDir $Paths.GlobalBinDir -Commands "pnpm,playwright,npx" -Packages "npm:pnpm,playwright" -Notes "Global browser automation is managed via npm on Windows." -ScopeSupport "global_or_project"
}

function Install-OptionalWindowsBundle {
  param(
    [pscustomobject]$Paths,
    [string]$Bundle
  )

  switch ($Bundle) {
    "pdf-images" {
      $packageIds = @(
        @{ Command = "ffmpeg"; Id = "Gyan.FFmpeg"; Name = "FFmpeg" },
        @{ Command = "magick"; Id = "ImageMagick.ImageMagick"; Name = "ImageMagick" },
        @{ Command = "gswin64c"; Id = "ArtifexSoftware.GhostScript"; Name = "Ghostscript" },
        @{ Command = "tesseract"; Id = "UB-Mannheim.TesseractOCR"; Name = "Tesseract OCR" }
      )

      foreach ($package in $packageIds) {
        try {
          Ensure-WingetCommand -CommandName $package.Command -WingetId $package.Id -DisplayName $package.Name
        } catch {
          Write-Warning "Skipping optional package $($package.Name): $($_.Exception.Message)"
        }
      }

      Write-ToolMetadata -Paths $Paths -Bundle "pdf-images" -Mode "global" -TargetDir $Paths.GlobalBinDir -Commands "ffmpeg,magick,gswin64c,tesseract" -Packages "winget:Gyan.FFmpeg,ImageMagick.ImageMagick,ArtifexSoftware.GhostScript,UB-Mannheim.TesseractOCR" -Notes "Optional PDF and image tools are installed best-effort on Windows." -ScopeSupport "global_only"
    }
    "diagrams" {
      Write-Warning "Bundle 'diagrams' is not yet automated on Windows. Install draw.io manually if you need it."
      Write-ToolMetadata -Paths $Paths -Bundle "diagrams" -Mode "global" -TargetDir "manual" -Commands "drawio" -Packages "manual:draw.io" -Notes "draw.io still requires manual installation on Windows." -ScopeSupport "global_only"
    }
    "composio-cli" {
      Write-Warning "Bundle 'composio-cli' is not yet automated on Windows. Install it manually if you need it."
      Write-ToolMetadata -Paths $Paths -Bundle "composio-cli" -Mode "global" -TargetDir "manual" -Commands "composio" -Packages "manual:composio-cli" -Notes "Composio CLI still requires manual installation on Windows." -ScopeSupport "global_only"
    }
    default {
      throw "Unsupported Windows bundle: $Bundle"
    }
  }
}

function Get-ManagedToolInstallations {
  param([pscustomobject]$Paths)

  Ensure-Directory $Paths.StateToolsDir
  Get-ChildItem -LiteralPath $Paths.StateToolsDir -Filter "*.env" -File | Sort-Object Name
}

function Show-WindowsToolInventory {
  param([pscustomobject]$Paths)

  $files = Get-ManagedToolInstallations -Paths $Paths
  Write-Host ""
  Write-Host "Managed tool installations:"

  if ($files.Count -eq 0) {
    Write-Host "- none"
    return
  }

  foreach ($file in $files) {
    $values = @{}
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
      if ($line -match "^(?<key>[^=]+)=(?<value>.*)$") {
        $values[$Matches.key] = $Matches.value
      }
    }

    Write-Host ("- {0} ({1}) | Scope: {2} | Target: {3} | Commands: {4} | Updated: {5}" -f $values.NAME, $values.MODE, $values.SCOPE_SUPPORT, $values.TARGET_DIR, $values.COMMANDS, $values.UPDATED_AT)
    Write-Host ("  Packages: {0}" -f $values.PACKAGES)
    Write-Host ("  Note: {0}" -f $values.NOTES)
  }
}

function Invoke-WindowsSetup {
  $paths = Get-RepoPaths
  Ensure-Directory $paths.StateToolsDir
  Ensure-Directory $paths.RuntimeRoot
  Ensure-Directory $paths.RuntimeBinDir
  Ensure-Directory $paths.GlobalToolRoot
  Ensure-Directory $paths.GlobalBinDir

  $bundles = @("core", "documents", "pdf-images", "diagrams", "browser-automation", "composio-cli")
  foreach ($bundle in $bundles) {
    Write-Host "Installing tool bundle $bundle in global mode..."
    switch ($bundle) {
      "core" { Install-CoreBundleWindows -Paths $paths }
      "documents" { Install-DocumentsBundleWindows -Paths $paths }
      "browser-automation" { Install-BrowserAutomationBundleWindows -Paths $paths }
      default { Install-OptionalWindowsBundle -Paths $paths -Bundle $bundle }
    }
  }

  Show-WindowsToolInventory -Paths $paths
}

function Invoke-BashFallback {
  param([string[]]$ForwardArgs)

  $bashExe = Get-BashExecutable
  $shellScript = Join-Path $Script:ScriptDir "cdx"
  $bashStyle = Get-BashPathStyle -BashExecutable $bashExe
  $bashScript = Convert-WindowsPathToBash -Path $shellScript -Style $bashStyle
  & $bashExe --noprofile --norc $bashScript @ForwardArgs
}

if ($IsWindows -and $Args.Count -gt 0 -and $Args[0] -eq "setup") {
  Invoke-WindowsSetup
  exit 0
}

if ($IsWindows -and $Args.Count -gt 0 -and $Args[0] -eq "list" -and ($Args.Count -eq 1 -or $Args[1] -eq "tools")) {
  $paths = Get-RepoPaths
  Show-WindowsToolInventory -Paths $paths
  exit 0
}

Invoke-BashFallback -ForwardArgs $Args
