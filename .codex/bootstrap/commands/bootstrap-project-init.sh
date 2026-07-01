#!/usr/bin/env bash
set -euo pipefail

bootstrap_init_project() {
  local root_dir customer_dir template_dir runtime_automation_dir timestamp today timezone
  local project_name user_name agent_name customer owner purpose role country language tone boundaries default_project_name

  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  customer_dir="$(cd "$root_dir/.." && pwd)"
  template_dir="$root_dir/bootstrap/templates"
  runtime_automation_dir="$root_dir/runtime/automations/heartbeat"
  timestamp="$(date +"%Y-%m-%d %H:%M %Z")"
  today="$(date +%F)"

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

  prompt_with_help() {
    local label="$1"
    local help_text="$2"
    local default_value="${3:-}"

    echo >&2
    echo "$label" >&2
    echo "  Hilft später bei: $help_text" >&2
    prompt_default "  Antwort" "$default_value"
  }

  confirm_overwrite() {
    local path="$1"
    local answer
    if [[ ! -f "$path" ]]; then
      return 0
    fi
    read -r -p "File exists: $path. Overwrite? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
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

  detect_default_project_name() {
    local root_name customer_name

    root_name="$(basename "$root_dir")"
    customer_name="$(basename "$customer_dir")"

    if [[ "$customer_name" == "Codex Setup" || "$customer_name" == ".codex" ]]; then
      printf 'Mein Projekt'
    elif [[ "$root_name" == ".codex" && -n "$customer_name" ]]; then
      printf '%s' "$customer_name"
    else
      printf 'Mein Projekt'
    fi
  }

  render_template() {
    local template_path="$1"
    local output_path="$2"
    local content

    if ! confirm_overwrite "$output_path"; then
      echo "Skipping existing file: $output_path"
      return 0
    fi

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
    content="${content//__TIMESTAMP__/$timestamp}"
    content="${content//__DATE__/$today}"
    printf '%s\n' "$content" > "$output_path"
  }

  write_manifest() {
    cat > "$root_dir/bootstrap/manifest.json" <<EOF
{
  "bootstrap": {
    "name": "codex-agent-bootstrap",
    "version": "0.3.0"
  },
  "initialized": true,
  "initializedAt": "$timestamp",
  "entrypoints": [
    "bin/cdx",
    "bin/cdx.ps1"
  ],
  "managedAreas": [
    "bootstrap/",
    "state/",
    "runtime/"
  ],
  "notes": [
    "The repository is intended to live as .codex inside a customer folder.",
    "Visible project docs live one directory above the repository root.",
    "Tools, Skills, and MCPs are managed through a single cdx CLI."
  ]
}
EOF
  }

  write_heartbeat_readme() {
    mkdir -p "$runtime_automation_dir"
    cat > "$runtime_automation_dir/README.md" <<EOF
# Heartbeat

This automation folder is reserved for the default project heartbeat.

- Timezone: \`$timezone\`
- Created by: \`cdx init\`
EOF
  }

  timezone="$(detect_timezone)"
  default_project_name="$(detect_default_project_name)"

  echo "Lass uns kurz die Projektdateien vorbereiten:"
  echo "  - ../Agents.md"
  echo "  - ../Memory.md"
  echo "  - ../Decisions.md"
  echo
  echo "Ich frage dich jetzt nach ein paar Basisangaben, damit der Start nicht bei null beginnt."
  echo "Wenn etwas noch nicht ganz feststeht, nimm einfach den Vorschlag oder ändere es später direkt in den Dateien."

  project_name="$(prompt_with_help "Wie soll das Projekt heißen?" "Der Name taucht später in den Startdokumenten als Bezugspunkt auf." "$default_project_name")"
  user_name="$(prompt_with_help "Für wen richten wir das Projekt ein?" "Der Name hilft dabei, Rollen und Zuständigkeiten in den Dokumenten klar zu halten.")"
  agent_name="$(prompt_with_help "Wie soll der Agent heißen?" "So wird der projektbezogene Codex-Agent in den Dokumenten benannt." "Codex")"
  customer="$user_name"
  owner="$user_name"
  purpose="$(prompt_with_help "Wobei soll der Agent hauptsächlich helfen?" "Das landet als kurze Ausrichtung in den Startdokumenten.")"
  country="$(prompt_with_help "Welches Land ist relevant?" "Hilft bei Sprache, Marktbezug oder Rahmenbedingungen, wenn das Projekt sie braucht.")"
  timezone="$(prompt_with_help "Welche Zeitzone passt?" "Wichtig für Zeitbezug und mögliche Automationen." "$timezone")"
  language="$(prompt_with_help "In welcher Sprache sollen die Startdokumente angelegt werden?" "Damit Ton und Grundsprache von Anfang an passen." "de")"
  role="KI-Mitarbeiter"
  tone="freundlich, präzise, praktisch"
  boundaries="Keine externen Änderungen ohne Freigabe"

  render_template "$template_dir/Agents.template.md" "$customer_dir/Agents.md"
  render_template "$template_dir/Memory.template.md" "$customer_dir/Memory.md"
  render_template "$template_dir/Decisions.template.md" "$customer_dir/Decisions.md"
  write_manifest
  write_heartbeat_readme
  rm -f "$root_dir/START_HERE.md"

  echo
  echo "Fertig, die Projektdateien sind angelegt."
  echo "Du findest sie hier:"
  echo "  $customer_dir/Agents.md"
  echo "  $customer_dir/Memory.md"
  echo "  $customer_dir/Decisions.md"
  echo
  echo "Sinnvolle nächste Schritte:"
  echo "  ./.codex/bin/cdx add tool documents --scope project"
  echo "  ./.codex/bin/cdx add skill drawio-diagrams-enhanced --scope project"
  echo "  ./.codex/bin/cdx add mcp macos-mcp --scope global"
}
