#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

prompt_default() {
  local label="$1"
  local default_value="$2"
  local value

  if [[ -n "$default_value" ]]; then
    read -r -p "$label [$default_value]: " value
    printf '%s' "${value:-$default_value}"
  else
    read -r -p "$label: " value
    printf '%s' "$value"
  fi
}

replace_placeholder() {
  local file="$1"
  local search="$2"
  local replacement="$3"

  [[ -f "$file" ]] || return 0

  replacement="${replacement//\\/\\\\}"
  replacement="${replacement//&/\\&}"
  replacement="${replacement//|/\\|}"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "s|$search|$replacement|g" "$file"
  else
    sed -i "s|$search|$replacement|g" "$file"
  fi
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "$value"
}

write_agents_managed_block() {
  local project_name="$1"
  local customer="$2"
  local timestamp="$3"
  local agents_file="$ROOT_DIR/AGENTS.md"
  local tmp_file
  local block_file
  local start_line
  local end_line

  [[ -f "$agents_file" ]] || return 0

  tmp_file="$(mktemp "${TMPDIR:-/tmp}/agents-md.XXXXXX")"
  block_file="$(mktemp "${TMPDIR:-/tmp}/agents-block.XXXXXX")"

  cat > "$block_file" <<EOF
<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->
## Kunden-Agent Bootstrap

- Bootstrap: \`codex-agent-bootstrap\`
- Version: \`0.1.0\`
- Initialisiert: \`$timestamp\`
- Projekt: \`$project_name\`
- Kunde/Team: \`$customer\`
- Projektprofil: \`project.yaml\`
- Manifest: \`.bootstrap/manifest.json\`
- Projekt-Memory: \`Memory.md\`
- Standard-Heartbeat: \`automations/heartbeat/\`

Dieser Block wird von den Init- und Update-Skripten verwaltet. Manuelle projektbezogene Hinweise gehoeren ausserhalb dieses Blocks.
<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->
EOF

  start_line="$(grep -n '<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->' "$agents_file" | head -n 1 | cut -d: -f1 || true)"
  end_line="$(grep -n '<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->' "$agents_file" | head -n 1 | cut -d: -f1 || true)"

  if [[ -n "$start_line" && -n "$end_line" && "$start_line" -le "$end_line" ]]; then
    {
      head -n "$((start_line - 1))" "$agents_file"
      cat "$block_file"
      tail -n +"$((end_line + 1))" "$agents_file"
    } > "$tmp_file"
    mv "$tmp_file" "$agents_file"
  else
    cat "$agents_file" "$block_file" > "$tmp_file"
    mv "$tmp_file" "$agents_file"
  fi

  rm -f "$block_file"
}

write_manifest() {
  local timestamp="$1"
  local project_name="$2"
  local customer="$3"
  local manifest_dir="$ROOT_DIR/.bootstrap"

  mkdir -p "$manifest_dir"

  cat > "$manifest_dir/manifest.json" <<EOF
{
  "bootstrap": {
    "name": "codex-agent-bootstrap",
    "version": "0.1.0"
  },
  "initialized": true,
  "initializedAt": "$(json_escape "$timestamp")",
  "project": {
    "name": "$(json_escape "$project_name")",
    "customer": "$(json_escape "$customer")"
  },
  "managedFiles": [
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
  ],
  "managedBlocks": {
    "AGENTS.md": {
      "start": "<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->",
      "end": "<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->"
    }
  },
  "notes": [
    "Workstation setup scripts may write to user-level Codex folders.",
    "Project init scripts should only edit files inside the project folder."
  ]
}
EOF
}

create_heartbeat_automation() {
  local heartbeat_dir="$ROOT_DIR/automations/heartbeat"
  local timestamp="$1"

  mkdir -p "$heartbeat_dir"

  cat > "$heartbeat_dir/README.md" <<'EOF'
# Heartbeat

Diese Automatisierung prueft regelmaessig, ob der Kunden-Agent sauber gepflegt ist.

## Zweck

Der Heartbeat sucht nach vergessenen Pflegepunkten im Projekt:

- Wurde die projektweite `Memory.md` nach relevanten Aenderungen aktualisiert?
- Haben Automatisierungen ihre eigene `Memory.md` nach jedem Lauf fortgeschrieben?
- Gibt es offene Punkte in `Memory.md`, `docs/decisions.md` oder Automatisierungs-Runbooks?
- Sind neue Erkenntnisse, Risiken oder Entscheidungen dokumentiert?
- Gibt es angelegte Dateien oder Automatisierungen ohne README, Runbook oder Memory?

## Zeitplan

- Wochentags
- Jede Stunde von 09:00 bis 17:00 lokaler Zeit
- Erwartete Laeufe: 09:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00

## Ergebnis

Jeder Lauf aktualisiert `Memory.md` dieser Automatisierung mit:

- geprueften Bereichen
- gefundenen Luecken
- erledigten Korrekturen
- offenen Empfehlungen
- naechsten Schritten

Wenn der Heartbeat projektweite Entscheidungen oder wichtige offene Punkte findet, aktualisiert er auch die Root-`Memory.md`.
EOF

  cat > "$heartbeat_dir/Runbook.md" <<'EOF'
# Runbook

## Vor Dem Lauf

1. Root-`Memory.md` lesen.
2. `project.yaml` lesen.
3. `docs/customer-context.md`, `docs/tools-and-access.md` und `docs/decisions.md` pruefen.
4. Alle Ordner unter `automations/` auf `README.md`, `Runbook.md` und `Memory.md` pruefen.

## Ablauf

1. Pruefen, ob neue oder geaenderte Projektdateien nicht in Root-`Memory.md` erwaehnt sind.
2. Pruefen, ob Automatisierungs-Memories aktuelle Laufprotokolle enthalten.
3. Offene Punkte, TODOs, Risiken und Blocker sammeln.
4. Kleine Dokumentationsluecken direkt korrigieren, wenn die richtige Korrektur eindeutig ist.
5. Unsichere Punkte als offene Frage dokumentieren.
6. Heartbeat-`Memory.md` aktualisieren.
7. Root-`Memory.md` aktualisieren, wenn projektweite Erkenntnisse, Entscheidungen oder Risiken gefunden wurden.

## Abschlusskriterien

- Heartbeat-`Memory.md` wurde aktualisiert.
- Root-`Memory.md` wurde aktualisiert, falls projektweite Punkte gefunden wurden.
- Offene Punkte sind konkret genug, dass ein spaeterer Agent sie fortsetzen kann.
- Es wurden keine globalen Codex-Dateien oder externen Systeme veraendert.

## Grenzen

- Der Heartbeat nimmt keine externen Aktionen vor.
- Der Heartbeat installiert keine Tools.
- Der Heartbeat schreibt nicht nach `~/.codex` oder `~/.agents`.
- Unklare inhaltliche Entscheidungen werden dokumentiert, nicht geraten.
EOF

  cat > "$heartbeat_dir/Memory.md" <<EOF
# Heartbeat Memory

Diese Datei dokumentiert die Laeufe der Heartbeat-Automatisierung.

## Automatisierung

- Name: \`Heartbeat\`
- Zweck: Regelmaessig pruefen, ob Memory, Dokumentation, offene Punkte und Projektkonventionen gepflegt sind.
- Zeitplan: Wochentags jede Stunde von 09:00 bis 17:00 lokaler Zeit.
- Status: \`aktiv vorgesehen\`

## Laufprotokoll

### $timestamp - Angelegt

- Ausloeser: Projektinitialisierung.
- Ziel: Standard-Heartbeat fuer Projektpflege anlegen.
- Ergebnis:
  - \`automations/heartbeat/README.md\` angelegt.
  - \`automations/heartbeat/Runbook.md\` angelegt.
  - \`automations/heartbeat/Memory.md\` angelegt.
- Naechste Schritte:
  - In Codex oder einem externen Scheduler als werktaegliche stuendliche Automatisierung von 09:00 bis 17:00 aktivieren.
EOF
}

append_memory_entry() {
  local timestamp="$1"
  local project_name="$2"
  local customer="$3"
  local purpose="$4"
  local owner="$5"

  cat >> "$ROOT_DIR/Memory.md" <<EOF

### $timestamp - Projekt Initialisiert

- Ausloeser: Lokales Init-Skript.
- Ziel: Vorlage in einen konkreten Kunden-Agenten verwandeln.
- Ergebnisse:
  - Projektname: \`$project_name\`
  - Kunde/Team: \`$customer\`
  - Zweck: \`$purpose\`
  - Verantwortlich: \`$owner\`
- Veraenderte Dateien:
  - \`AGENTS.md\`
  - \`.bootstrap/manifest.json\`
  - \`project.yaml\`
  - \`docs/customer-context.md\`
  - \`Memory.md\`
  - \`automations/heartbeat/README.md\`
  - \`automations/heartbeat/Runbook.md\`
  - \`automations/heartbeat/Memory.md\`
- Naechste Schritte:
  - README bei Bedarf kundenspezifisch ausformulieren.
  - Heartbeat als werktaegliche stuendliche Codex-Automatisierung von 09:00 bis 17:00 aktivieren.
  - Benoetigte Tools und Zugriffe in \`docs/tools-and-access.md\` klaeren.
EOF
}

echo "Initialisiere diesen Ordner als Kunden-Agent."
echo "Es werden nur Dateien in diesem Projektordner veraendert:"
echo "$ROOT_DIR"
echo

project_name="$(prompt_default "Projektname" "Codex Customer Agent")"
customer="$(prompt_default "Kunde, Team oder Organisation" "")"
purpose="$(prompt_default "Zweck des Agenten" "")"
owner="$(prompt_default "Verantwortliche Person oder Team" "")"
language="$(prompt_default "Sprache" "de")"
tone="$(prompt_default "Ton" "freundlich, praezise, pragmatisch")"
risk_level="$(prompt_default "Risikostufe" "medium")"
timestamp="$(date '+%Y-%m-%d %H:%M %Z')"

replace_placeholder "$ROOT_DIR/project.yaml" 'name: "Codex Customer Agent"' "name: $(yaml_quote "$project_name")"
replace_placeholder "$ROOT_DIR/project.yaml" 'customer: "<Kunde, Team oder Organisation>"' "customer: $(yaml_quote "$customer")"
replace_placeholder "$ROOT_DIR/project.yaml" 'purpose: "<Wobei soll der Agent helfen?>"' "purpose: $(yaml_quote "$purpose")"
replace_placeholder "$ROOT_DIR/project.yaml" 'owner: "<Verantwortliche Person oder Team>"' "owner: $(yaml_quote "$owner")"
replace_placeholder "$ROOT_DIR/project.yaml" 'status: "template"' 'status: "initialized"'
replace_placeholder "$ROOT_DIR/project.yaml" 'language: "de"' "language: $(yaml_quote "$language")"
replace_placeholder "$ROOT_DIR/project.yaml" 'initialized_at: null' "initialized_at: $(yaml_quote "$timestamp")"
replace_placeholder "$ROOT_DIR/project.yaml" 'default_tone: "freundlich, praezise, pragmatisch"' "default_tone: $(yaml_quote "$tone")"
replace_placeholder "$ROOT_DIR/project.yaml" 'risk_level: "medium"' "risk_level: $(yaml_quote "$risk_level")"

replace_placeholder "$ROOT_DIR/docs/customer-context.md" '<Kunde, Team oder Organisation>' "$customer"
replace_placeholder "$ROOT_DIR/docs/customer-context.md" '<Name oder Rolle>' "$owner"
replace_placeholder "$ROOT_DIR/docs/customer-context.md" '<Ziel>' "$purpose"
replace_placeholder "$ROOT_DIR/docs/customer-context.md" 'freundlich, praezise, pragmatisch' "$tone"
replace_placeholder "$ROOT_DIR/docs/customer-context.md" 'Sprache: `de`' "Sprache: \`$language\`"

create_heartbeat_automation "$timestamp"
write_agents_managed_block "$project_name" "$customer" "$timestamp"
write_manifest "$timestamp" "$project_name" "$customer"
append_memory_entry "$timestamp" "$project_name" "$customer" "$purpose" "$owner"

echo
echo "Fertig. Projekt wurde lokal initialisiert."
echo "Naechster Schritt in Codex:"
echo "  Bitte lies project.yaml, Memory.md und automations/heartbeat/ und hilf mir, den Heartbeat zu aktivieren."
