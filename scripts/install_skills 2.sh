#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Gemeinsame Install- und Listing-Funktionen liegen hier zentral.
source "$ROOT_DIR/scripts/skill_catalog.sh"

usage() {
  cat <<'EOF'
Verwendung:
  ./scripts/install_skills.sh all
  ./scripts/install_skills.sh financial-services marketingskills frontend-design humanizer
  ./scripts/install_skills.sh list

Dieses Skript installiert die gewünschten Skill-Quellen projektlokal unter `skills/`.
EOF
}

main() {
  ensure_command git
  ensure_base_dirs

  if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
  fi

  if [[ "$1" == "list" ]]; then
    print_installed_skills
    exit 0
  fi

  local requested_skills=()
  local skill_name

  if [[ "$1" == "all" ]]; then
    while IFS= read -r skill_name; do
      requested_skills+=("$skill_name")
    done < <(list_supported_skills)
  else
    requested_skills=("$@")
  fi

  for skill_name in "${requested_skills[@]}"; do
    echo "Installiere $skill_name ..."
    install_skill "$skill_name"
  done

  echo
  echo "Installation abgeschlossen."
  print_installed_skills
}

main "$@"
