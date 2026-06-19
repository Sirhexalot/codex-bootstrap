#!/usr/bin/env bash
set -euo pipefail

bootstrap_init_project() {
  local root_dir
  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  local template_path="$root_dir/.bootstrap/templates/final-AGENTS.md"
  local timestamp timezone
  local project_name user_name agent_name customer owner purpose role country language tone risk_level boundaries tools channels

  prompt_default() {
    local label="$1"
    local default_value="${2:-}"
    local value

    if [[ -n "$default_value" ]]; then
      read -r -p "$label [$default_value]: " value
      printf '%s' "${value:-$default_value}"
    else
      read -r -p "$label: " value
      printf '%s' "$value"
    fi
  }

  detect_timezone() {
    if [[ -n "${TZ:-}" ]]; then
      printf '%s' "$TZ"
    elif [[ -L /etc/localtime ]]; then
      readlink /etc/localtime | sed 's#^.*zoneinfo/##'
    elif [[ -f /etc/timezone ]]; then
      cat /etc/timezone
    else
      date +%Z
    fi
  }

  render_final_agents() {
    local content
    content="$(cat "$template_path")"
    content="${content//__PROJECT_NAME__/$project_name}"
    content="${content//__USER_NAME__/$user_name}"
    content="${content//__AGENT_NAME__/$agent_name}"
    content="${content//__CUSTOMER__/$customer}"
    content="${content//__ROLE__/$role}"
    content="${content//__COUNTRY__/$country}"
    content="${content//__TIMEZONE__/$timezone}"
    content="${content//__LANGUAGE__/$language}"
    content="${content//__TONE__/$tone}"
    content="${content//__PURPOSE__/$purpose}"
    content="${content//__BOUNDARIES__/$boundaries}"
    printf '%s\n' "$content" > "$root_dir/AGENTS.md"
  }

  write_project_yaml() {
    cat > "$root_dir/project.yaml" <<EOF
bootstrap:
  name: "codex-agent-bootstrap"
  version: "0.2.0"
  initialized_at: "$timestamp"
  manifest: ".bootstrap/manifest.json"

project:
  name: "$project_name"
  customer: "$customer"
  purpose: "$purpose"
  owner: "$owner"
  user_name: "$user_name"
  agent_name: "$agent_name"
  role: "$role"
  country: "$country"
  timezone: "$timezone"
  status: "initialized"
  language: "$language"

agent:
  default_tone: "$tone"
  autonomy_level: "confirm_before_external_actions"
  risk_level: "$risk_level"
  primary_users:
    - "$user_name"
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

onboarding:
  first_prompt: "Bitte initialisiere dieses Projekt als Kunden-Agent."
  read_first:
    - "project.yaml"
    - "AGENTS.md"
    - "Memory.md"
    - "docs/customer-context.md"

heartbeat:
  enabled: true
  name: "Heartbeat"
  schedule: "weekdays hourly from 09:00 to 17:00"
  timezone: "$timezone"
  automation_path: "automations/heartbeat"
  purpose: "Regelmäßig prüfen, ob Memory, Dokumentation, Entscheidungen und Runbooks gepflegt sind."
EOF
  }

  write_customer_context() {
    cat > "$root_dir/docs/customer-context.md" <<EOF
# Kundenkontext

## Nutzer und Projekt

- Nutzername: \`$user_name\`
- Agentenname: \`$agent_name\`
- Projektname: \`$project_name\`
- Kunde, Team oder Organisation: \`$customer\`
- Rolle oder Schwerpunkt: \`$role\`

## Ziel

- Zweck: \`$purpose\`
- Arbeitsweise: \`Der Agent arbeitet wie ein verlässlicher Coworker, liest erst Kontext, liefert konkrete Ergebnisse und holt vor externen oder irreversiblen Schritten Freigaben ein.\`
- Wichtige Ergebnisse: \`Dokumentation, Entscheidungen, Automatisierungen, Artefakte und klare nächste Schritte.\`

## Kontext

- Land: \`$country\`
- Zeitzone: \`$timezone\`
- Sprache: \`$language\`
- Ton: \`$tone\`

## Grenzen

- Sensible Bereiche: \`$boundaries\`
- Externe oder irreversible Aktionen nur nach Freigabe
EOF
  }

  write_tools_doc() {
    cat > "$root_dir/docs/tools-and-access.md" <<EOF
# Tools und Zugriffe

## Werkbank-Tools

- Python: \`global\`
- Node.js: \`global\`
- Git: \`global\`
- FFmpeg: \`global\`
- ImageMagick: \`global\`
- Ghostscript: \`global\`
- pipx: \`global\`
- pnpm: \`global\`
- Playwright: \`global\`

## Projektrelevante Systeme

- Wichtige Tools oder Plattformen: \`$tools\`
- Bevorzugte Kanäle: \`$channels\`

## Zugriffsregeln

- Tools gehören immer zur globalen Werkbank.
- Skills können global oder projektbezogen installiert werden.
- Zugangsdaten werden nicht in Projektdateien gespeichert.
- Externe Schreibaktionen brauchen klare Freigaben.
EOF
  }

  write_decisions_doc() {
    cat > "$root_dir/docs/decisions.md" <<EOF
# Entscheidungen

## Entscheidungen

### $(date +%F) - Projekt initialisiert

- Entscheidung: Dieses Repository wurde in einen konkreten Agenten für \`$user_name\` überführt.
- Grund: Der Bootstrap soll ab jetzt als echter Projektrahmen für \`$agent_name\` dienen.
- Alternativen: Die generische Bootstrap-AGENTS-Datei beibehalten.
- Auswirkungen: Die sichtbare \`AGENTS.md\` ist jetzt projektspezifisch, Werkbank-Tools bleiben global und Skills sind wählbar zwischen global und projektbezogen.
- Status: \`aktiv\`
EOF
  }

  write_memory() {
    cat > "$root_dir/Memory.md" <<EOF
# Projekt-Memory

## Überblick

- Projektname: \`$project_name\`
- Nutzer: \`$user_name\`
- Agent: \`$agent_name\`
- Zweck: \`$purpose\`
- Rolle: \`$role\`
- Land: \`$country\`
- Zeitzone: \`$timezone\`

## Stabile Regeln

- Werkbank-Tools sind global.
- Skills werden per Skript als \`global\` oder \`projektbezogen\` installiert.
- Externe oder irreversible Aktionen brauchen Freigabe.
- Relevante Projektänderungen werden hier dokumentiert.

## Offene Punkte

- Erste produktive Use Cases schärfen
- Relevante Tools und Kanäle konkret verbinden

## Laufprotokoll

### $timestamp - Projekt initialisiert

- Auslöser: Lokales Bootstrap-Initialisierungsskript
- Ziel: Aus der Vorlage einen konkreten Agenten machen
- Ergebnisse:
  - Finale \`AGENTS.md\` für \`$agent_name\` geschrieben
  - \`project.yaml\`, \`docs/\` und \`Memory.md\` auf den Projektkontext angepasst
  - Heartbeat-Automatisierung angelegt oder aktualisiert
- Nächste Schritte:
  - Erste Tools und Kanäle konkretisieren
  - Benötigte Skills global oder projektbezogen installieren
EOF
  }

  write_manifest() {
    mkdir -p "$root_dir/.bootstrap"
    cat > "$root_dir/.bootstrap/manifest.json" <<EOF
{
  "bootstrap": {
    "name": "codex-agent-bootstrap",
    "version": "0.2.0"
  },
  "initialized": true,
  "initializedAt": "$timestamp",
  "project": {
    "name": "$project_name",
    "userName": "$user_name",
    "agentName": "$agent_name",
    "customer": "$customer",
    "country": "$country",
    "timezone": "$timezone"
  },
  "managedEntrypoints": [
    "setup-mac.sh",
    "setup-windows.ps1",
    "scripts/init-project.sh",
    "scripts/init-project.ps1",
    "scripts/install_skills.sh",
    "scripts/update_skill.sh",
    "scripts/list_skills.sh"
  ]
}
EOF
  }

  create_heartbeat_automation() {
    local heartbeat_dir="$root_dir/automations/heartbeat"
    mkdir -p "$heartbeat_dir"
    cp "$root_dir/.bootstrap/templates/automation-template/README.md" "$heartbeat_dir/README.md"
    cp "$root_dir/.bootstrap/templates/automation-template/Runbook.md" "$heartbeat_dir/Runbook.md"
    cat > "$heartbeat_dir/Memory.md" <<EOF
# Heartbeat Memory

## Automatisierung

- Name: \`Heartbeat\`
- Zweck: Regelmäßig prüfen, ob Memory, Dokumentation, offene Punkte und Projektkonventionen gepflegt sind.
- Status: \`aktiv vorgesehen\`

## Laufprotokoll

### $timestamp - Angelegt

- Auslöser: Projektinitialisierung
- Ziel: Standard-Heartbeat anlegen
- Ergebnis:
  - \`automations/heartbeat/README.md\`
  - \`automations/heartbeat/Runbook.md\`
  - \`automations/heartbeat/Memory.md\`
- Nächste Schritte:
  - Als werktägliche stündliche Automatisierung aktivieren
EOF
  }

  echo "Initialisiere dieses Projekt als konkreten Agenten."
  echo "Es werden nur Dateien in diesem Ordner geändert."
  echo "$root_dir"
  echo

  timezone="$(detect_timezone)"
  timestamp="$(date '+%Y-%m-%d %H:%M %Z')"
  project_name="$(prompt_default "Projektname" "Kunden-Agent")"
  user_name="$(prompt_default "Name des Nutzers" "")"
  agent_name="$(prompt_default "Name des Agenten" "Karl")"
  customer="$(prompt_default "Kunde, Team oder Organisation" "$user_name")"
  owner="$(prompt_default "Verantwortliche Person oder Team" "$user_name")"
  purpose="$(prompt_default "Zweck des Agenten" "")"
  role="$(prompt_default "Rolle oder Schwerpunkt des Agenten" "AI-Coworker")"
  country="$(prompt_default "Land" "")"
  timezone="$(prompt_default "Zeitzone" "$timezone")"
  language="$(prompt_default "Sprache" "de")"
  tone="$(prompt_default "Ton" "freundlich, präzise, pragmatisch")"
  risk_level="$(prompt_default "Risikostufe" "medium")"
  boundaries="$(prompt_default "Sensible Grenzen und No-Gos" "Keine externen Änderungen ohne Freigabe")"
  tools="$(prompt_default "Wichtige Tools oder Systeme" "GitHub, Google Workspace, Slack")"
  channels="$(prompt_default "Bevorzugte Kanäle" "Codex")"

  render_final_agents
  write_project_yaml
  write_customer_context
  write_tools_doc
  write_decisions_doc
  write_memory
  write_manifest
  create_heartbeat_automation

  echo
  echo "Fertig. Das Projekt wurde initialisiert."
  echo "Als Nächstes kannst du Skills installieren:"
  echo "  ./scripts/install_skills.sh"
}
