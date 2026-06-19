$ErrorActionPreference = "Stop"

function Invoke-BootstrapProjectInit {
  $rootDir = Resolve-Path (Join-Path $PSScriptRoot "../..")
  $templatePath = Join-Path $rootDir ".bootstrap/templates/final-AGENTS.md"
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm zzz"

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

  $projectName = Prompt-Default "Projektname" "Kunden-Agent"
  $userName = Prompt-Default "Name des Nutzers"
  $agentName = Prompt-Default "Name des Agenten" "Karl"
  $customer = Prompt-Default "Kunde, Team oder Organisation" $userName
  $owner = Prompt-Default "Verantwortliche Person oder Team" $userName
  $purpose = Prompt-Default "Zweck des Agenten"
  $role = Prompt-Default "Rolle oder Schwerpunkt des Agenten" "AI-Coworker"
  $country = Prompt-Default "Land"
  $timezone = Prompt-Default "Zeitzone" (Get-TimeZone).Id
  $language = Prompt-Default "Sprache" "de"
  $tone = Prompt-Default "Ton" "freundlich, präzise, pragmatisch"
  $riskLevel = Prompt-Default "Risikostufe" "medium"
  $boundaries = Prompt-Default "Sensible Grenzen und No-Gos" "Keine externen Änderungen ohne Freigabe"
  $tools = Prompt-Default "Wichtige Tools oder Systeme" "GitHub, Google Workspace, Slack"
  $channels = Prompt-Default "Bevorzugte Kanäle" "Codex"

  $agents = Get-Content -Path $templatePath -Raw
  $agents = $agents.Replace("__PROJECT_NAME__", $projectName).Replace("__USER_NAME__", $userName).Replace("__AGENT_NAME__", $agentName).Replace("__CUSTOMER__", $customer).Replace("__ROLE__", $role).Replace("__COUNTRY__", $country).Replace("__TIMEZONE__", $timezone).Replace("__LANGUAGE__", $language).Replace("__TONE__", $tone).Replace("__PURPOSE__", $purpose).Replace("__BOUNDARIES__", $boundaries)
  Set-Content -Path (Join-Path $rootDir "AGENTS.md") -Value $agents -Encoding UTF8

  @"
bootstrap:
  name: "codex-agent-bootstrap"
  version: "0.2.0"
  initialized_at: "$timestamp"
  manifest: ".bootstrap/manifest.json"

project:
  name: "$projectName"
  customer: "$customer"
  purpose: "$purpose"
  owner: "$owner"
  user_name: "$userName"
  agent_name: "$agentName"
  role: "$role"
  country: "$country"
  timezone: "$timezone"
  status: "initialized"
  language: "$language"

agent:
  default_tone: "$tone"
  autonomy_level: "confirm_before_external_actions"
  risk_level: "$riskLevel"
  primary_users:
    - "$userName"
  out_of_scope:
    - "Keine externen Aktionen mit Wirkung auf Kunden, Konten, Daten oder Kosten ohne klare Freigabe."
    - "Keine Zugangsdaten, API-Keys oder Tokens in Projektdateien speichern."
    - "Keine produktiven Automatisierungen ohne dokumentierten Zweck, Zugriff und Abbruchkriterien aktivieren."
  boundaries: "$boundaries"

memory:
  long_term_memory: "Memory MCP Server"
  project_memory: "Memory.md"
  automation_memory_required: true
  update_project_memory_on_relevant_changes: true

folders:
  automations: "automations"
  docs: "docs"
  skills: "skills"
  bootstrap: ".bootstrap"

tools:
  workstation_scope: "global"
  skills_scope: "global_or_project"
  required:
    - "Codex"
    - "Python"
    - "Node.js"
    - "Git"
  optional:
    - "$tools"

heartbeat:
  enabled: true
  name: "Heartbeat"
  schedule: "weekdays hourly from 09:00 to 17:00"
  timezone: "$timezone"
  automation_path: "automations/heartbeat"
  purpose: "Regelmäßig prüfen, ob Memory, Dokumentation, Entscheidungen und Runbooks gepflegt sind."
"@ | Set-Content -Path (Join-Path $rootDir "project.yaml") -Encoding UTF8

  New-Item -ItemType Directory -Force -Path (Join-Path $rootDir "docs") | Out-Null
  @"
# Kundenkontext

- Nutzername: ``$userName``
- Agentenname: ``$agentName``
- Projektname: ``$projectName``
- Kunde, Team oder Organisation: ``$customer``
- Rolle oder Schwerpunkt: ``$role``
- Land: ``$country``
- Zeitzone: ``$timezone``
- Zweck: ``$purpose``
"@ | Set-Content -Path (Join-Path $rootDir "docs/customer-context.md") -Encoding UTF8

  @"
# Tools und Zugriffe

- Werkbank-Tools sind global.
- Wichtige Tools oder Plattformen: ``$tools``
- Bevorzugte Kanäle: ``$channels``
- Skills können global oder projektbezogen installiert werden.
"@ | Set-Content -Path (Join-Path $rootDir "docs/tools-and-access.md") -Encoding UTF8

  @"
# Entscheidungen

### $(Get-Date -Format "yyyy-MM-dd") - Projekt initialisiert

- Entscheidung: Dieses Repository wurde in einen konkreten Agenten überführt.
- Grund: Der Bootstrap soll jetzt als echter Projektrahmen dienen.
- Auswirkungen: Sichtbare ``AGENTS.md`` ist projektspezifisch, Werkbank-Tools bleiben global und Skills sind wählbar.
- Status: ``aktiv``
"@ | Set-Content -Path (Join-Path $rootDir "docs/decisions.md") -Encoding UTF8

  @"
# Projekt-Memory

## Überblick

- Projektname: ``$projectName``
- Nutzer: ``$userName``
- Agent: ``$agentName``
- Zweck: ``$purpose``
- Rolle: ``$role``
- Land: ``$country``
- Zeitzone: ``$timezone``

## Stabile Regeln

- Werkbank-Tools sind global.
- Skills werden per Skript als ``global`` oder ``projektbezogen`` installiert.
- Externe oder irreversible Aktionen brauchen Freigabe.

## Laufprotokoll

### $timestamp - Projekt initialisiert

- Auslöser: Lokales Bootstrap-Initialisierungsskript
- Ziel: Aus der Vorlage einen konkreten Agenten machen
- Ergebnisse:
  - Finale ``AGENTS.md`` geschrieben
  - ``project.yaml``, ``docs/`` und ``Memory.md`` angepasst
  - Heartbeat-Automatisierung angelegt
"@ | Set-Content -Path (Join-Path $rootDir "Memory.md") -Encoding UTF8

  New-Item -ItemType Directory -Force -Path (Join-Path $rootDir "automations/heartbeat") | Out-Null
  Copy-Item (Join-Path $rootDir ".bootstrap/templates/automation-template/README.md") (Join-Path $rootDir "automations/heartbeat/README.md") -Force
  Copy-Item (Join-Path $rootDir ".bootstrap/templates/automation-template/Runbook.md") (Join-Path $rootDir "automations/heartbeat/Runbook.md") -Force
  @"
# Heartbeat Memory

### $timestamp - Angelegt

- Auslöser: Projektinitialisierung
- Ziel: Standard-Heartbeat anlegen
"@ | Set-Content -Path (Join-Path $rootDir "automations/heartbeat/Memory.md") -Encoding UTF8

  New-Item -ItemType Directory -Force -Path (Join-Path $rootDir ".bootstrap") | Out-Null
  @"
{
  "bootstrap": {
    "name": "codex-agent-bootstrap",
    "version": "0.2.0"
  },
  "initialized": true,
  "initializedAt": "$timestamp",
  "project": {
    "name": "$projectName",
    "userName": "$userName",
    "agentName": "$agentName",
    "customer": "$customer",
    "country": "$country",
    "timezone": "$timezone"
  }
}
"@ | Set-Content -Path (Join-Path $rootDir ".bootstrap/manifest.json") -Encoding UTF8

  Write-Host ""
  Write-Host "Fertig. Das Projekt wurde initialisiert."
  Write-Host "Als Nächstes kannst du Skills installieren:"
  Write-Host "  ./scripts/install_skills.sh"
}
