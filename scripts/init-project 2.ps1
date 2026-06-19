$ErrorActionPreference = "Stop"

$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")

function Prompt-Default {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Label,

    [string] $Default = ""
  )

  if ($Default) {
    $value = Read-Host "$Label [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) {
      return $Default
    }
    return $value
  }

  return Read-Host $Label
}

function Replace-Placeholder {
  param(
    [Parameter(Mandatory = $true)]
    [string] $File,

    [Parameter(Mandatory = $true)]
    [string] $Search,

    [Parameter(Mandatory = $true)]
    [string] $Replacement
  )

  if (-not (Test-Path $File)) {
    return
  }

  $content = Get-Content -Path $File -Raw
  $content = $content.Replace($Search, $Replacement)
  Set-Content -Path $File -Value $content -NoNewline -Encoding UTF8
}

function ConvertTo-YamlQuoted {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Value
  )

  $escaped = $Value.Replace("\", "\\").Replace('"', '\"')
  return "`"$escaped`""
}

function Update-AgentsManagedBlock {
  param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectName,

    [Parameter(Mandatory = $true)]
    [string] $Customer,

    [Parameter(Mandatory = $true)]
    [string] $Timestamp
  )

  $agentsFile = Join-Path $RootDir "AGENTS.md"
  if (-not (Test-Path $agentsFile)) {
    return
  }

  $block = @"
<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->
## Kunden-Agent Bootstrap

- Bootstrap: ``codex-agent-bootstrap``
- Version: ``0.1.0``
- Initialisiert: ``$Timestamp``
- Projekt: ``$ProjectName``
- Kunde/Team: ``$Customer``
- Projektprofil: ``project.yaml``
- Manifest: ``.bootstrap/manifest.json``
- Projekt-Memory: ``Memory.md``
- Standard-Heartbeat: ``automations/heartbeat/``

Dieser Block wird von den Init- und Update-Skripten verwaltet. Manuelle projektbezogene Hinweise gehoeren ausserhalb dieses Blocks.
<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->
"@

  $content = Get-Content -Path $agentsFile -Raw
  $pattern = '(?s)<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->.*?<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->'

  if ($content -match $pattern) {
    $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block }, 1)
  } else {
    $content = $content.TrimEnd() + "`n`n" + $block + "`n"
  }

  Set-Content -Path $agentsFile -Value $content -NoNewline -Encoding UTF8
}

function Write-BootstrapManifest {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Timestamp,

    [Parameter(Mandatory = $true)]
    [string] $ProjectName,

    [Parameter(Mandatory = $true)]
    [string] $Customer
  )

  $manifestDir = Join-Path $RootDir ".bootstrap"
  $manifestPath = Join-Path $manifestDir "manifest.json"
  New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null

  $manifest = [ordered]@{
    bootstrap = [ordered]@{
      name = "codex-agent-bootstrap"
      version = "0.1.0"
    }
    initialized = $true
    initializedAt = $Timestamp
    project = [ordered]@{
      name = $ProjectName
      customer = $Customer
    }
    managedFiles = @(
      "AGENTS.md",
      "Memory.md",
      "README.md",
      "START_HERE.md",
      "project.yaml",
      "docs/customer-context.md",
      "docs/tools-and-access.md",
      "docs/decisions.md",
      "automations/heartbeat/README.md",
      "automations/heartbeat/Runbook.md",
      "automations/heartbeat/Memory.md"
    )
    managedBlocks = [ordered]@{
      "AGENTS.md" = [ordered]@{
        start = "<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->"
        end = "<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->"
      }
    }
    notes = @(
      "Workstation setup scripts may write to user-level Codex folders.",
      "Project init scripts should only edit files inside the project folder."
    )
  }

  $manifest | ConvertTo-Json -Depth 8 | Set-Content -Path $manifestPath -Encoding UTF8
}

function New-HeartbeatAutomation {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Timestamp
  )

  $heartbeatDir = Join-Path $RootDir "automations/heartbeat"
  New-Item -ItemType Directory -Force -Path $heartbeatDir | Out-Null

  @"
# Heartbeat

Diese Automatisierung prueft regelmaessig, ob der Kunden-Agent sauber gepflegt ist.

## Zweck

Der Heartbeat sucht nach vergessenen Pflegepunkten im Projekt:

- Wurde die projektweite ``Memory.md`` nach relevanten Aenderungen aktualisiert?
- Haben Automatisierungen ihre eigene ``Memory.md`` nach jedem Lauf fortgeschrieben?
- Gibt es offene Punkte in ``Memory.md``, ``docs/decisions.md`` oder Automatisierungs-Runbooks?
- Sind neue Erkenntnisse, Risiken oder Entscheidungen dokumentiert?
- Gibt es angelegte Dateien oder Automatisierungen ohne README, Runbook oder Memory?

## Zeitplan

- Wochentags
- Jede Stunde von 09:00 bis 17:00 lokaler Zeit
- Erwartete Laeufe: 09:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00

## Ergebnis

Jeder Lauf aktualisiert ``Memory.md`` dieser Automatisierung mit:

- geprueften Bereichen
- gefundenen Luecken
- erledigten Korrekturen
- offenen Empfehlungen
- naechsten Schritten

Wenn der Heartbeat projektweite Entscheidungen oder wichtige offene Punkte findet, aktualisiert er auch die Root-``Memory.md``.
"@ | Set-Content -Path (Join-Path $heartbeatDir "README.md") -Encoding UTF8

  @"
# Runbook

## Vor Dem Lauf

1. Root-``Memory.md`` lesen.
2. ``project.yaml`` lesen.
3. ``docs/customer-context.md``, ``docs/tools-and-access.md`` und ``docs/decisions.md`` pruefen.
4. Alle Ordner unter ``automations/`` auf ``README.md``, ``Runbook.md`` und ``Memory.md`` pruefen.

## Ablauf

1. Pruefen, ob neue oder geaenderte Projektdateien nicht in Root-``Memory.md`` erwaehnt sind.
2. Pruefen, ob Automatisierungs-Memories aktuelle Laufprotokolle enthalten.
3. Offene Punkte, TODOs, Risiken und Blocker sammeln.
4. Kleine Dokumentationsluecken direkt korrigieren, wenn die richtige Korrektur eindeutig ist.
5. Unsichere Punkte als offene Frage dokumentieren.
6. Heartbeat-``Memory.md`` aktualisieren.
7. Root-``Memory.md`` aktualisieren, wenn projektweite Erkenntnisse, Entscheidungen oder Risiken gefunden wurden.

## Abschlusskriterien

- Heartbeat-``Memory.md`` wurde aktualisiert.
- Root-``Memory.md`` wurde aktualisiert, falls projektweite Punkte gefunden wurden.
- Offene Punkte sind konkret genug, dass ein spaeterer Agent sie fortsetzen kann.
- Es wurden keine globalen Codex-Dateien oder externen Systeme veraendert.

## Grenzen

- Der Heartbeat nimmt keine externen Aktionen vor.
- Der Heartbeat installiert keine Tools.
- Der Heartbeat schreibt nicht nach ``~/.codex`` oder ``~/.agents``.
- Unklare inhaltliche Entscheidungen werden dokumentiert, nicht geraten.
"@ | Set-Content -Path (Join-Path $heartbeatDir "Runbook.md") -Encoding UTF8

  @"
# Heartbeat Memory

Diese Datei dokumentiert die Laeufe der Heartbeat-Automatisierung.

## Automatisierung

- Name: ``Heartbeat``
- Zweck: Regelmaessig pruefen, ob Memory, Dokumentation, offene Punkte und Projektkonventionen gepflegt sind.
- Zeitplan: Wochentags jede Stunde von 09:00 bis 17:00 lokaler Zeit.
- Status: ``aktiv vorgesehen``

## Laufprotokoll

### $Timestamp - Angelegt

- Ausloeser: Projektinitialisierung.
- Ziel: Standard-Heartbeat fuer Projektpflege anlegen.
- Ergebnis:
  - ``automations/heartbeat/README.md`` angelegt.
  - ``automations/heartbeat/Runbook.md`` angelegt.
  - ``automations/heartbeat/Memory.md`` angelegt.
- Naechste Schritte:
  - In Codex oder einem externen Scheduler als werktaegliche stuendliche Automatisierung von 09:00 bis 17:00 aktivieren.
"@ | Set-Content -Path (Join-Path $heartbeatDir "Memory.md") -Encoding UTF8
}

function Add-MemoryEntry {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Timestamp,

    [Parameter(Mandatory = $true)]
    [string] $ProjectName,

    [Parameter(Mandatory = $true)]
    [string] $Customer,

    [Parameter(Mandatory = $true)]
    [string] $Purpose,

    [Parameter(Mandatory = $true)]
    [string] $Owner
  )

  $entry = @"

### $Timestamp - Projekt Initialisiert

- Ausloeser: Lokales Init-Skript.
- Ziel: Vorlage in einen konkreten Kunden-Agenten verwandeln.
- Ergebnisse:
  - Projektname: ``$ProjectName``
  - Kunde/Team: ``$Customer``
  - Zweck: ``$Purpose``
  - Verantwortlich: ``$Owner``
- Veraenderte Dateien:
  - ``AGENTS.md``
  - ``.bootstrap/manifest.json``
  - ``project.yaml``
  - ``docs/customer-context.md``
  - ``Memory.md``
  - ``automations/heartbeat/README.md``
  - ``automations/heartbeat/Runbook.md``
  - ``automations/heartbeat/Memory.md``
- Naechste Schritte:
  - README bei Bedarf kundenspezifisch ausformulieren.
  - Heartbeat als werktaegliche stuendliche Codex-Automatisierung von 09:00 bis 17:00 aktivieren.
  - Benoetigte Tools und Zugriffe in ``docs/tools-and-access.md`` klaeren.
"@

  Add-Content -Path (Join-Path $RootDir "Memory.md") -Value $entry
}

Write-Host "Initialisiere diesen Ordner als Kunden-Agent."
Write-Host "Es werden nur Dateien in diesem Projektordner veraendert:"
Write-Host $RootDir
Write-Host ""

$projectName = Prompt-Default -Label "Projektname" -Default "Codex Customer Agent"
$customer = Prompt-Default -Label "Kunde, Team oder Organisation"
$purpose = Prompt-Default -Label "Zweck des Agenten"
$owner = Prompt-Default -Label "Verantwortliche Person oder Team"
$language = Prompt-Default -Label "Sprache" -Default "de"
$tone = Prompt-Default -Label "Ton" -Default "freundlich, praezise, pragmatisch"
$riskLevel = Prompt-Default -Label "Risikostufe" -Default "medium"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm zzz"

$projectYaml = Join-Path $RootDir "project.yaml"
$customerContext = Join-Path $RootDir "docs/customer-context.md"

Replace-Placeholder -File $projectYaml -Search 'name: "Codex Customer Agent"' -Replacement "name: $(ConvertTo-YamlQuoted $projectName)"
Replace-Placeholder -File $projectYaml -Search 'customer: "<Kunde, Team oder Organisation>"' -Replacement "customer: $(ConvertTo-YamlQuoted $customer)"
Replace-Placeholder -File $projectYaml -Search 'purpose: "<Wobei soll der Agent helfen?>"' -Replacement "purpose: $(ConvertTo-YamlQuoted $purpose)"
Replace-Placeholder -File $projectYaml -Search 'owner: "<Verantwortliche Person oder Team>"' -Replacement "owner: $(ConvertTo-YamlQuoted $owner)"
Replace-Placeholder -File $projectYaml -Search 'status: "template"' -Replacement 'status: "initialized"'
Replace-Placeholder -File $projectYaml -Search 'language: "de"' -Replacement "language: $(ConvertTo-YamlQuoted $language)"
Replace-Placeholder -File $projectYaml -Search 'initialized_at: null' -Replacement "initialized_at: $(ConvertTo-YamlQuoted $timestamp)"
Replace-Placeholder -File $projectYaml -Search 'default_tone: "freundlich, praezise, pragmatisch"' -Replacement "default_tone: $(ConvertTo-YamlQuoted $tone)"
Replace-Placeholder -File $projectYaml -Search 'risk_level: "medium"' -Replacement "risk_level: $(ConvertTo-YamlQuoted $riskLevel)"

Replace-Placeholder -File $customerContext -Search '<Kunde, Team oder Organisation>' -Replacement $customer
Replace-Placeholder -File $customerContext -Search '<Name oder Rolle>' -Replacement $owner
Replace-Placeholder -File $customerContext -Search '<Ziel>' -Replacement $purpose
Replace-Placeholder -File $customerContext -Search 'freundlich, praezise, pragmatisch' -Replacement $tone
Replace-Placeholder -File $customerContext -Search 'Sprache: `de`' -Replacement "Sprache: ``$language``"

New-HeartbeatAutomation -Timestamp $timestamp
Update-AgentsManagedBlock -ProjectName $projectName -Customer $customer -Timestamp $timestamp
Write-BootstrapManifest -Timestamp $timestamp -ProjectName $projectName -Customer $customer
Add-MemoryEntry -Timestamp $timestamp -ProjectName $projectName -Customer $customer -Purpose $purpose -Owner $owner

Write-Host ""
Write-Host "Fertig. Projekt wurde lokal initialisiert."
Write-Host "Naechster Schritt in Codex:"
Write-Host "  Bitte lies project.yaml, Memory.md und automations/heartbeat/ und hilf mir, den Heartbeat zu aktivieren."
