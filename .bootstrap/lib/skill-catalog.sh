#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$BOOTSTRAP_ROOT/.." && pwd)"
PROJECT_SKILLS_DIR="$PROJECT_ROOT/skills"
PROJECT_CACHE_DIR="$BOOTSTRAP_ROOT/skills-cache"
PROJECT_STATE_DIR="$BOOTSTRAP_ROOT/skill-installs"
GLOBAL_SKILLS_DIR="$HOME/.codex/skills"
GLOBAL_COLLECTIONS_DIR="$HOME/.codex/skills/_vendor"

SUPPORTED_SKILLS=(
  "financial-services"
  "marketingskills"
  "frontend-design"
  "humanizer"
  "ui-ux-pro-max"
  "drawio-diagrams-enhanced"
  "svg-precision"
  "pptx"
  "senior-architect"
  "brand-voice"
  "infographic-creation"
  "jira-expert"
  "confluence"
)

ensure_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Fehler: Benötigter Befehl fehlt: $command_name" >&2
    exit 1
  fi
}

ensure_base_dirs() {
  mkdir -p "$PROJECT_SKILLS_DIR" "$PROJECT_CACHE_DIR" "$PROJECT_STATE_DIR"
}

list_supported_skills() {
  printf '%s\n' "${SUPPORTED_SKILLS[@]}"
}

usage_install() {
  cat <<'EOF'
Verwendung:
  ./scripts/install_skills.sh all
  ./scripts/install_skills.sh frontend-design humanizer
  ./scripts/install_skills.sh ui-ux-pro-max pptx jira-expert
  ./scripts/install_skills.sh --mode global all
EOF
}

usage_update() {
  cat <<'EOF'
Verwendung:
  ./scripts/update_skill.sh all
  ./scripts/update_skill.sh financial-services
  ./scripts/update_skill.sh ui-ux-pro-max pptx jira-expert
EOF
}

prompt_mode() {
  local input
  while true; do
    read -r -p "Skill-Modus wählen [global/projektbezogen]: " input
    case "$input" in
      global)
        printf 'global'
        return
        ;;
      projektbezogen|projekt|project)
        printf 'project'
        return
        ;;
    esac
    echo "Bitte 'global' oder 'projektbezogen' eingeben."
  done
}

metadata_path_for() {
  local skill_name="$1"
  local mode="$2"
  printf '%s/%s--%s.env' "$PROJECT_STATE_DIR" "$mode" "$skill_name"
}

write_install_metadata() {
  local skill_name="$1"
  local mode="$2"
  local source_type="$3"
  local repo_url="$4"
  local target_dir="$5"
  local installed_at

  installed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  {
    printf 'NAME=%q\n' "$skill_name"
    printf 'MODE=%q\n' "$mode"
    printf 'TYPE=%q\n' "$source_type"
    printf 'REPO_URL=%q\n' "$repo_url"
    printf 'TARGET_DIR=%q\n' "$target_dir"
    printf 'INSTALLED_AT=%q\n' "$installed_at"
    printf 'UPDATED_AT=%q\n' "$installed_at"
  } > "$(metadata_path_for "$skill_name" "$mode")"
}

write_source_metadata() {
  local target_dir="$1"
  local name="$2"
  local source_type="$3"
  local repo_url="$4"

  mkdir -p "$target_dir"
  {
    printf 'NAME=%q\n' "$name"
    printf 'TYPE=%q\n' "$source_type"
    printf 'REPO_URL=%q\n' "$repo_url"
    printf 'UPDATED_AT=%q\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$target_dir/.skill-source.env"
}

replace_directory() {
  local source_dir="$1"
  local target_dir="$2"

  rm -rf "$target_dir"
  mkdir -p "$(dirname "$target_dir")"
  cp -R "$source_dir" "$target_dir"
}

install_repo_subdir() {
  local skill_name="$1"
  local mode="$2"
  local source_type="$3"
  local repo_url="$4"
  local sparse_path="$5"
  local source_subdir="$6"
  local target_dir
  target_dir="$(resolve_target_dir "$skill_name" "$mode" "$source_type")"

  copy_repo_subdir() {
    local repo_dir="$1"
    replace_directory "$repo_dir/$source_subdir" "$target_dir"
    write_source_metadata "$target_dir" "$skill_name" "$source_type" "$repo_url"
    write_install_metadata "$skill_name" "$mode" "$source_type" "$repo_url" "$target_dir"
  }

  with_temp_repo "$repo_url" "$sparse_path" copy_repo_subdir
}

with_temp_repo() {
  local repo_url="$1"
  local sparse_path="${2:-}"
  local callback="$3"
  local temp_dir repo_dir

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/skill-install.XXXXXX")"
  repo_dir="$temp_dir/repo"

  if [[ -n "$sparse_path" ]]; then
    git clone --depth 1 --filter=blob:none --sparse "$repo_url" "$repo_dir" >/dev/null
    (
      cd "$repo_dir"
      git sparse-checkout set "$sparse_path" >/dev/null
    )
  else
    git clone --depth 1 "$repo_url" "$repo_dir" >/dev/null
  fi

  "$callback" "$repo_dir"
  rm -rf "$temp_dir"
}

resolve_target_dir() {
  local skill_name="$1"
  local mode="$2"
  local type="$3"

  if [[ "$mode" == "global" ]]; then
    if [[ "$type" == "collection" ]]; then
      printf '%s/%s' "$GLOBAL_COLLECTIONS_DIR" "$skill_name"
    else
      printf '%s/%s' "$GLOBAL_SKILLS_DIR" "$skill_name"
    fi
  else
    if [[ "$type" == "collection" ]]; then
      printf '%s/%s' "$PROJECT_CACHE_DIR" "$skill_name"
    else
      printf '%s/%s' "$PROJECT_SKILLS_DIR" "$skill_name"
    fi
  fi
}

install_frontend_design() {
  local mode="$1"
  local repo_url="https://github.com/anthropics/claude-code.git"
  local target_dir
  target_dir="$(resolve_target_dir "frontend-design" "$mode" "skill")"

  copy_repo() {
    local repo_dir="$1"
    replace_directory "$repo_dir/plugins/frontend-design/skills/frontend-design" "$target_dir"
    write_source_metadata "$target_dir" "frontend-design" "skill" "$repo_url"
    write_install_metadata "frontend-design" "$mode" "skill" "$repo_url" "$target_dir"
  }

  with_temp_repo "$repo_url" "plugins/frontend-design" copy_repo
}

install_humanizer() {
  local mode="$1"
  local repo_url="https://github.com/blader/humanizer.git"
  local target_dir
  target_dir="$(resolve_target_dir "humanizer" "$mode" "skill")"

  copy_repo() {
    local repo_dir="$1"
    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    cp "$repo_dir/SKILL.md" "$target_dir/SKILL.md"
    [[ -f "$repo_dir/README.md" ]] && cp "$repo_dir/README.md" "$target_dir/UPSTREAM_README.md"
    [[ -f "$repo_dir/LICENSE" ]] && cp "$repo_dir/LICENSE" "$target_dir/LICENSE"
    write_source_metadata "$target_dir" "humanizer" "skill" "$repo_url"
    write_install_metadata "humanizer" "$mode" "skill" "$repo_url" "$target_dir"
  }

  with_temp_repo "$repo_url" "" copy_repo
}

install_marketingskills() {
  local mode="$1"
  local repo_url="https://github.com/coreyhaines31/marketingskills.git"
  local target_dir
  target_dir="$(resolve_target_dir "marketingskills" "$mode" "collection")"

  copy_repo() {
    local repo_dir="$1"
    replace_directory "$repo_dir/skills" "$target_dir"
    write_source_metadata "$target_dir" "marketingskills" "collection" "$repo_url"
    write_install_metadata "marketingskills" "$mode" "collection" "$repo_url" "$target_dir"
  }

  with_temp_repo "$repo_url" "skills" copy_repo
}

install_financial_services() {
  local mode="$1"
  local repo_url="https://github.com/anthropics/financial-services.git"
  install_repo_subdir "financial-services" "$mode" "collection" "$repo_url" "plugins" "plugins"
}

install_ui_ux_pro_max() {
  local mode="$1"
  local repo_url="https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git"
  install_repo_subdir "ui-ux-pro-max" "$mode" "skill" "$repo_url" ".claude/skills/ui-ux-pro-max" ".claude/skills/ui-ux-pro-max"
}

install_drawio_diagrams_enhanced() {
  local mode="$1"
  local repo_url="https://github.com/jgtolentino/insightpulse-odoo.git"
  install_repo_subdir "drawio-diagrams-enhanced" "$mode" "skill" "$repo_url" "docs/claude-code-skills/community/drawio-diagrams-enhanced" "docs/claude-code-skills/community/drawio-diagrams-enhanced"
}

install_svg_precision() {
  local mode="$1"
  local repo_url="https://github.com/dkyazzentwatwa/chatgpt-skills.git"
  install_repo_subdir "svg-precision" "$mode" "skill" "$repo_url" "svg-precision-skill" "svg-precision-skill"
}

install_pptx() {
  local mode="$1"
  local repo_url="https://github.com/anthropics/skills.git"
  install_repo_subdir "pptx" "$mode" "skill" "$repo_url" "skills/pptx" "skills/pptx"
}

install_senior_architect() {
  local mode="$1"
  local repo_url="https://github.com/alirezarezvani/claude-skills.git"
  install_repo_subdir "senior-architect" "$mode" "skill" "$repo_url" "engineering-team/skills/senior-architect" "engineering-team/skills/senior-architect"
}

install_brand_voice() {
  local mode="$1"
  local repo_url="https://github.com/anthropics/knowledge-work-plugins.git"
  install_repo_subdir "brand-voice" "$mode" "collection" "$repo_url" "partner-built/brand-voice" "partner-built/brand-voice"
}

install_infographic_creation() {
  local mode="$1"
  local repo_url="https://github.com/antvis/Infographic.git"
  install_repo_subdir "infographic-creation" "$mode" "skill" "$repo_url" "skills/infographic-creator" "skills/infographic-creator"
}

install_jira_expert() {
  local mode="$1"
  local repo_url="https://github.com/alirezarezvani/claude-skills.git"
  install_repo_subdir "jira-expert" "$mode" "skill" "$repo_url" "project-management/skills/jira-expert" "project-management/skills/jira-expert"
}

install_confluence() {
  local mode="$1"
  local repo_url="https://github.com/alirezarezvani/claude-skills.git"
  install_repo_subdir "confluence" "$mode" "skill" "$repo_url" "project-management/skills/confluence-expert" "project-management/skills/confluence-expert"
}

install_skill_by_name() {
  local skill_name="$1"
  local mode="$2"

  case "$skill_name" in
    financial-services) install_financial_services "$mode" ;;
    marketingskills) install_marketingskills "$mode" ;;
    frontend-design) install_frontend_design "$mode" ;;
    humanizer) install_humanizer "$mode" ;;
    ui-ux-pro-max) install_ui_ux_pro_max "$mode" ;;
    drawio-diagrams-enhanced) install_drawio_diagrams_enhanced "$mode" ;;
    svg-precision) install_svg_precision "$mode" ;;
    pptx) install_pptx "$mode" ;;
    senior-architect) install_senior_architect "$mode" ;;
    brand-voice) install_brand_voice "$mode" ;;
    infographic-creation) install_infographic_creation "$mode" ;;
    jira-expert) install_jira_expert "$mode" ;;
    confluence) install_confluence "$mode" ;;
    *)
      echo "Fehler: Nicht unterstützte Skill-Quelle: $skill_name" >&2
      exit 1
      ;;
  esac
}

count_skill_files() {
  local target_dir="$1"
  find "$target_dir" -type f -name "SKILL.md" | wc -l | tr -d ' '
}

print_installations() {
  local file
  local found=0

  echo "Verwaltete Skill-Installationen:"
  for file in "$PROJECT_STATE_DIR"/*.env; do
    [[ -f "$file" ]] || continue
    found=1
    # shellcheck disable=SC1090
    source "$file"
    echo "- $NAME | Modus: $MODE | Typ: $TYPE | Quelle: $REPO_URL | Ziel: $TARGET_DIR | Stand: $UPDATED_AT"
    if [[ -d "$TARGET_DIR" ]]; then
      echo "  SKILL.md-Dateien: $(count_skill_files "$TARGET_DIR")"
    fi
  done

  if [[ "$found" -eq 0 ]]; then
    echo "- keine"
  fi
}

bootstrap_install_skills() {
  ensure_command git
  ensure_base_dirs

  local mode=""
  local -a requested=()
  local arg

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --mode)
        mode="$2"
        shift 2
        ;;
      -h|--help)
        usage_install
        return
        ;;
      *)
        requested+=("$1")
        shift
        ;;
    esac
  done

  [[ ${#requested[@]} -gt 0 ]] || {
    usage_install
    return 1
  }

  if [[ -z "$mode" ]]; then
    mode="$(prompt_mode)"
  fi
  [[ "$mode" == "global" || "$mode" == "project" ]] || {
    echo "Fehler: Modus muss 'global' oder 'project' sein." >&2
    return 1
  }

  if [[ "${requested[0]}" == "all" ]]; then
    requested=()
    while IFS= read -r arg; do
      requested+=("$arg")
    done < <(list_supported_skills)
  fi

  for arg in "${requested[@]}"; do
    echo "Installiere $arg im Modus $mode ..."
    install_skill_by_name "$arg" "$mode"
  done

  echo
  print_installations
}

bootstrap_update_skills() {
  ensure_command git
  ensure_base_dirs

  local -a requested=()
  local file name_found

  [[ "$#" -gt 0 ]] || {
    usage_update
    return 1
  }

  if [[ "$1" == "all" ]]; then
    for file in "$PROJECT_STATE_DIR"/*.env; do
      [[ -f "$file" ]] || continue
      # shellcheck disable=SC1090
      source "$file"
      echo "Aktualisiere $NAME im Modus $MODE ..."
      install_skill_by_name "$NAME" "$MODE"
    done
  else
    requested=("$@")
    for name_found in "${requested[@]}"; do
      local matched=0
      for file in "$PROJECT_STATE_DIR"/*.env; do
        [[ -f "$file" ]] || continue
        # shellcheck disable=SC1090
        source "$file"
        if [[ "$NAME" == "$name_found" ]]; then
          matched=1
          echo "Aktualisiere $NAME im Modus $MODE ..."
          install_skill_by_name "$NAME" "$MODE"
        fi
      done
      if [[ "$matched" -eq 0 ]]; then
        echo "Keine verwaltete Installation für $name_found gefunden." >&2
      fi
    done
  fi

  echo
  print_installations
}

bootstrap_list_skills() {
  ensure_base_dirs
  print_installations
}
