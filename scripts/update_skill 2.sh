#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Updates laufen absichtlich über die gleiche Install-Logik, damit die Ordner konsistent bleiben.
source "$ROOT_DIR/scripts/skill_catalog.sh"

usage() {
  cat <<'EOF'
Verwendung:
  ./scripts/update_skill.sh all
  ./scripts/update_skill.sh financial-services
  ./scripts/update_skill.sh frontend-design humanizer
  ./scripts/update_skill.sh list

Dieses Skript aktualisiert bereits bekannte Skill-Quellen durch erneutes Holen aus den Upstream-Repositories.
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
    echo "Aktualisiere $skill_name ..."
    install_skill "$skill_name"
  done

  echo
  echo "Aktualisierung abgeschlossen."
  print_installed_skills
}

main "$@"
