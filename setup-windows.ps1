$ErrorActionPreference = "Stop"

Write-Host "Richte die globale Codex-Werkbank auf Windows ein."
Write-Host "Dieses Skript installiert nur allgemeine Werkzeuge."
Write-Host "Es installiert kein Codex, keine Skills und keine projektbezogenen Dateien."
Write-Host ""

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget wurde nicht gefunden. Bitte zuerst App Installer installieren und dann erneut starten."
}

function Install-WingetPackage {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Id,

    [Parameter(Mandatory = $true)]
    [string] $Name
  )

  Write-Host "Installiere $Name ..."
  winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements
}

Install-WingetPackage -Id "Python.Python.3.12" -Name "Python 3"
Install-WingetPackage -Id "OpenJS.NodeJS.LTS" -Name "Node.js LTS"
Install-WingetPackage -Id "Gyan.FFmpeg" -Name "FFmpeg"
Install-WingetPackage -Id "ImageMagick.ImageMagick" -Name "ImageMagick"
Install-WingetPackage -Id "ArtifexSoftware.GhostScript" -Name "Ghostscript"
Install-WingetPackage -Id "Git.Git" -Name "Git"

Write-Host "Installiere globale npm-Werkzeuge ..."
npm install -g pnpm playwright
npx -y playwright install

Write-Host "Installiere optionale globale CLI-Werkzeuge ..."
python -m pip install --upgrade pip pipx
pipx ensurepath

try {
  py -3.12 -m pip index versions meta-ads *> $null
  pipx install --force --python "py -3.12" meta-ads
} catch {
  Write-Warning "Meta Ads CLI konnte nicht installiert werden. Das ist optional."
}

Write-Host ""
Write-Host "Fertig."
Write-Host "Versionen:"
python --version
node --version
npm --version
ffmpeg -version | Select-Object -First 1
magick --version | Select-Object -First 1
gswin64c --version
