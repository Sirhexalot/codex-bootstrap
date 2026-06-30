#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$BOOTSTRAP_ROOT/.." && pwd)"
PROJECT_STATE_DIR="$BOOTSTRAP_ROOT/mcp-installs"
PROJECT_MCP_DIR="$PROJECT_ROOT/.mcp"
GLOBAL_MCP_DIR="$HOME/.codex/mcp"
GLOBAL_AGENTS_FILE="$HOME/.codex/AGENTS.md"
PROJECT_AGENTS_FILE="$PROJECT_ROOT/AGENTS.md"

SUPPORTED_MCPS=(
  "imap"
)

declare -a SELECTED_MCP_METADATA_KEYS=()
declare -a SELECTED_MCP_METADATA_FILES=()
declare -a STALE_MCP_METADATA_FILES=()

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_base_dirs() {
  mkdir -p "$PROJECT_STATE_DIR" "$PROJECT_MCP_DIR" "$GLOBAL_MCP_DIR"
}

decode_metadata_value() {
  local raw_value="$1"

  if [[ "$raw_value" == \'*\' && "$raw_value" == *\' ]]; then
    printf '%s' "${raw_value:1:${#raw_value}-2}"
  else
    printf '%s' "$raw_value" | sed -e 's/\\ / /g' -e 's/\\,/,/g' -e 's/\\|/|/g' -e 's/\\\\/\\/g'
  fi
}

load_mcp_metadata() {
  local metadata_file="$1"
  local key raw_value decoded_value

  unset NAME MODE TYPE SOURCE_KIND SOURCE_REF TARGET_DIR RUN_COMMAND SETUP_COMMAND NOTES UPDATED_AT
  while IFS='=' read -r key raw_value; do
    [[ -n "$key" ]] || continue
    decoded_value="$(decode_metadata_value "$raw_value")"
    printf -v "$key" '%s' "$decoded_value"
  done < "$metadata_file"
}

canonical_mcp_metadata_path_for() {
  local name="$1"
  local mode="$2"
  printf '%s/%s--%s.env' "$PROJECT_STATE_DIR" "$mode" "$name"
}

mcp_metadata_path_for() {
  local name="$1"
  local mode="$2"
  canonical_mcp_metadata_path_for "$name" "$mode"
}

list_supported_mcps() {
  printf '%s\n' "${SUPPORTED_MCPS[@]}"
}

prompt_mcp_selection() {
  local selected

  if command_exists gum; then
    mapfile -t selected < <(gum choose --no-limit "${SUPPORTED_MCPS[@]}")
  elif command_exists fzf; then
    mapfile -t selected < <(printf '%s\n' "${SUPPORTED_MCPS[@]}" | fzf --multi)
  else
    selected=()
    echo "Available MCP sources:" >&2
    local index=1
    local entry
    local input
    local normalized
    local -a parts=()

    for entry in "${SUPPORTED_MCPS[@]}"; do
      printf '  %s. %s\n' "$index" "$entry" >&2
      index=$((index + 1))
    done

    while true; do
      read -r -p "Select MCPs by number or name (comma-separated): " input
      [[ -n "$input" ]] || continue
      IFS=',' read -ra parts <<< "$input"
      selected=()
      for entry in "${parts[@]}"; do
        normalized="$(printf '%s' "$entry" | xargs)"
        case "$normalized" in
          1|imap)
            selected+=("imap")
            ;;
          *)
            echo "Unknown MCP selection: $normalized" >&2
            selected=()
            break
            ;;
        esac
      done
      [[ ${#selected[@]} -gt 0 ]] && break
    done
  fi

  if [[ ${#selected[@]} -eq 0 ]]; then
    echo "No MCP source selected." >&2
    exit 1
  fi

  printf '%s\n' "${selected[@]}" | awk '!seen[$0]++'
}

usage_install_mcps() {
  cat <<'EOF'
Usage:
  ./.scripts/install_mcp.sh all
  ./.scripts/install_mcp.sh imap
  ./.scripts/install_mcp.sh --mode global all
  ./.scripts/install_mcp.sh --mode project imap
EOF
}

usage_update_mcps() {
  cat <<'EOF'
Usage:
  ./.scripts/update_mcp.sh all
  ./.scripts/update_mcp.sh imap
EOF
}

prompt_mode_mcps() {
  local input
  while true; do
    read -r -p "Choose MCP mode [global/workspace]: " input
    case "$input" in
      global)
        printf 'global'
        return
        ;;
      workspace|projektbezogen|projekt|project)
        printf 'project'
        return
        ;;
    esac
    echo "Please enter 'global' or 'workspace'."
  done
}

resolve_target_dir() {
  local name="$1"
  local mode="$2"

  if [[ "$mode" == "global" ]]; then
    printf '%s/%s' "$GLOBAL_MCP_DIR" "$name"
  else
    printf '%s/%s' "$PROJECT_MCP_DIR" "$name"
  fi
}

write_mcp_metadata() {
  local name="$1"
  local mode="$2"
  local type="$3"
  local source_kind="$4"
  local source_ref="$5"
  local target_dir="$6"
  local run_command="$7"
  local setup_command="$8"
  local notes="$9"
  local updated_at

  updated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  {
    printf 'NAME=%q\n' "$name"
    printf 'MODE=%q\n' "$mode"
    printf 'TYPE=%q\n' "$type"
    printf 'SOURCE_KIND=%q\n' "$source_kind"
    printf 'SOURCE_REF=%q\n' "$source_ref"
    printf 'TARGET_DIR=%q\n' "$target_dir"
    printf 'RUN_COMMAND=%q\n' "$run_command"
    printf 'SETUP_COMMAND=%q\n' "$setup_command"
    printf 'NOTES=%q\n' "$notes"
    printf 'UPDATED_AT=%q\n' "$updated_at"
  } > "$(mcp_metadata_path_for "$name" "$mode")"
}

write_mcp_source_metadata() {
  local target_dir="$1"
  local name="$2"
  local source_kind="$3"
  local source_ref="$4"

  {
    printf 'NAME=%q\n' "$name"
    printf 'SOURCE_KIND=%q\n' "$source_kind"
    printf 'SOURCE_REF=%q\n' "$source_ref"
    printf 'UPDATED_AT=%q\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$target_dir/.mcp-source.env"
}

strip_agents_managed_block() {
  local source_file="$1"
  local output_file="$2"
  local start_marker="$3"
  local end_marker="$4"

  awk '
    $0 == start { skip=1; next }
    $0 == end { skip=0; next }
    skip != 1 { print }
  ' start="$start_marker" end="$end_marker" "$source_file" > "$output_file"
}

ensure_agents_file() {
  local agents_file="$1"
  local title="$2"

  mkdir -p "$(dirname "$agents_file")"
  if [[ ! -f "$agents_file" ]]; then
    cat >"$agents_file" <<EOF
- Always use real umlauts in externally visible text: \`ä, ö, ü, Ä, Ö, Ü, ß\`.

## $title
EOF
  fi
}

sync_agents_block() {
  local agents_file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local heading="$4"
  shift 4

  local temp_file
  local -a lines=("$@")

  ensure_agents_file "$agents_file" "$heading"
  temp_file="$(mktemp "${TMPDIR:-/tmp}/codex-agents.XXXXXX")"
  strip_agents_managed_block "$agents_file" "$temp_file" "$start_marker" "$end_marker"
  {
    cat "$temp_file"
    printf '\n%s\n' "$start_marker"
    printf '## %s\n\n' "$heading"
    if [[ ${#lines[@]} -eq 0 ]]; then
      printf -- '- none\n'
    else
      printf '%s\n' "${lines[@]}"
    fi
    printf '%s\n' "$end_marker"
  } > "$agents_file"
  rm -f "$temp_file"
}

find_selected_key_index() {
  local needle="$1"
  local index=0

  for entry in "${SELECTED_MCP_METADATA_KEYS[@]-}"; do
    if [[ "$entry" == "$needle" ]]; then
      printf '%s' "$index"
      return 0
    fi
    index=$((index + 1))
  done
  return 1
}

collect_selected_mcp_metadata_files() {
  local mode_filter="${1:-}"
  local metadata_file key canonical_file selected_file selected_index
  SELECTED_MCP_METADATA_KEYS=()
  SELECTED_MCP_METADATA_FILES=()
  STALE_MCP_METADATA_FILES=()

  while IFS= read -r metadata_file; do
    load_mcp_metadata "$metadata_file"
    [[ -n "${NAME:-}" && -n "${MODE:-}" ]] || continue
    if [[ -n "$mode_filter" && "$MODE" != "$mode_filter" ]]; then
      continue
    fi

    key="$MODE::$NAME"
    canonical_file="$(canonical_mcp_metadata_path_for "$NAME" "$MODE")"
    if ! selected_index="$(find_selected_key_index "$key")"; then
      SELECTED_MCP_METADATA_KEYS+=("$key")
      SELECTED_MCP_METADATA_FILES+=("$metadata_file")
      continue
    fi

    selected_file="${SELECTED_MCP_METADATA_FILES[$selected_index]}"

    if [[ "$metadata_file" == "$canonical_file" ]]; then
      STALE_MCP_METADATA_FILES+=("$selected_file")
      SELECTED_MCP_METADATA_FILES[$selected_index]="$metadata_file"
    else
      STALE_MCP_METADATA_FILES+=("$metadata_file")
    fi
  done < <(find "$PROJECT_STATE_DIR" -maxdepth 1 -type f -name '*.env' | LC_ALL=C sort)
}

sync_global_agents_file() {
  local -a mcp_lines=()
  local -a selected_files=()
  local mcp_count

  collect_selected_mcp_metadata_files "global"
  if [[ ${#SELECTED_MCP_METADATA_FILES[@]} -gt 0 ]]; then
    selected_files=("${SELECTED_MCP_METADATA_FILES[@]}")
  fi
  mcp_count="${#selected_files[@]}"

  mcp_lines+=("- Managed by this bootstrap as a compact global reference.")
  mcp_lines+=("- Recorded global MCP servers: \`$mcp_count\`.")
  mcp_lines+=("- Metadata directory: \`$PROJECT_STATE_DIR\`.")
  mcp_lines+=("- Global MCP root: \`$GLOBAL_MCP_DIR\`.")
  mcp_lines+=("- Inspect the current inventory from \`$PROJECT_ROOT\` with \`./.scripts/list_mcps.sh\`.")

  sync_agents_block \
    "$GLOBAL_AGENTS_FILE" \
    "<!-- CODEX_GLOBAL_MCPS_START -->" \
    "<!-- CODEX_GLOBAL_MCPS_END -->" \
    "Managed Global MCP Servers" \
    "${mcp_lines[@]}"
}

sync_project_agents_file() {
  local metadata_file
  local -a mcp_lines=()
  local -a selected_files=()

  collect_selected_mcp_metadata_files "project"
  if [[ ${#SELECTED_MCP_METADATA_FILES[@]} -gt 0 ]]; then
    selected_files=("${SELECTED_MCP_METADATA_FILES[@]}")
  fi

  if [[ ${#selected_files[@]} -gt 0 ]]; then
    for metadata_file in "${selected_files[@]}"; do
      load_mcp_metadata "$metadata_file"
      mcp_lines+=("- \`$NAME\`: Type \`$TYPE\` | Target \`$TARGET_DIR\` | Run \`$RUN_COMMAND\` | Setup \`$SETUP_COMMAND\` | Source \`$SOURCE_KIND:$SOURCE_REF\`")
      if [[ -n "${NOTES:-}" ]]; then
        mcp_lines+=("  Note: $NOTES")
      fi
    done
  fi

  sync_agents_block \
    "$PROJECT_AGENTS_FILE" \
    "<!-- CODEX_PROJECT_MCPS_START -->" \
    "<!-- CODEX_PROJECT_MCPS_END -->" \
    "Managed Project MCP Servers" \
    "${mcp_lines[@]-}"
}

write_imap_files() {
  local target_dir="$1"
  local run_script="$target_dir/run.sh"
  local setup_script="$target_dir/setup.sh"

  mkdir -p "$target_dir"
  cat > "$run_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

npx -y imap-mcp-server "$@"
EOF
  cat > "$setup_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

npx -p imap-mcp-server imap-setup "$@"
EOF
  chmod +x "$run_script" "$setup_script"
  cat > "$target_dir/README.md" <<'EOF'
# IMAP MCP

This managed MCP server uses the published `imap-mcp-server` package through `npx`.

- `./run.sh` starts the MCP server
- `./setup.sh` launches the setup assistant
EOF
}

install_imap() {
  local mode="$1"
  local target_dir run_command setup_command
  target_dir="$(resolve_target_dir "imap" "$mode")"
  run_command="$target_dir/run.sh"
  setup_command="$target_dir/setup.sh"

  write_imap_files "$target_dir"
  write_mcp_source_metadata "$target_dir" "imap" "npm" "imap-mcp-server"
  write_mcp_metadata \
    "imap" \
    "$mode" \
    "server" \
    "npm" \
    "imap-mcp-server" \
    "$target_dir" \
    "$run_command" \
    "$setup_command" \
    "Uses the published imap-mcp-server package through npx. Account data is managed by the upstream setup flow."
}

install_mcp_by_name() {
  local name="$1"
  local mode="$2"

  case "$name" in
    imap) install_imap "$mode" ;;
    *)
      echo "Error: Unsupported MCP source: $name" >&2
      exit 1
      ;;
  esac
}

bootstrap_install_mcps() {
  local mode=""
  local arg
  local -a requested=()
  local -a install_list=()

  ensure_base_dirs

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        [[ $# -ge 2 ]] || { usage_install_mcps >&2; exit 1; }
        mode="$2"
        shift 2
        ;;
      global)
        if [[ -z "$mode" && ${#requested[@]} -eq 0 ]]; then
          mode="global"
        else
          requested+=("$1")
        fi
        shift
        ;;
      workspace|project|projekt|projektbezogen)
        if [[ -z "$mode" && ${#requested[@]} -eq 0 ]]; then
          mode="project"
        else
          requested+=("$1")
        fi
        shift
        ;;
      *)
        requested+=("$1")
        shift
        ;;
    esac
  done

  if [[ -z "$mode" ]]; then
    mode="$(prompt_mode_mcps)"
  fi

  case "$mode" in
    global|project) ;;
    workspace) mode="project" ;;
    *)
      echo "Error: Invalid mode: $mode" >&2
      usage_install_mcps >&2
      exit 1
      ;;
  esac

  if [[ ${#requested[@]} -eq 0 ]]; then
    while IFS= read -r arg; do
      requested+=("$arg")
    done < <(prompt_mcp_selection)
  fi

  for arg in "${requested[@]}"; do
    if [[ "$arg" == "all" ]]; then
      while IFS= read -r arg; do
        install_list+=("$arg")
      done < <(list_supported_mcps)
      continue
    fi

    if ! printf '%s\n' "${SUPPORTED_MCPS[@]}" | grep -Fxq "$arg"; then
      echo "Error: Unsupported MCP source: $arg" >&2
      exit 1
    fi
    install_list+=("$arg")
  done

  for arg in "${install_list[@]}"; do
    echo "Installing MCP $arg ($mode)..."
    install_mcp_by_name "$arg" "$mode"
  done

  sync_global_agents_file
  sync_project_agents_file
  echo "Done."
}

bootstrap_update_mcps() {
  local name metadata_file
  local -a requested=()
  local -a selected_files=()
  local found

  ensure_base_dirs

  if [[ $# -eq 0 ]]; then
    requested=("all")
  else
    requested=("$@")
  fi

  collect_selected_mcp_metadata_files
  if [[ ${#SELECTED_MCP_METADATA_FILES[@]} -gt 0 ]]; then
    selected_files=("${SELECTED_MCP_METADATA_FILES[@]}")
  fi

  if [[ ${#selected_files[@]} -eq 0 ]]; then
    echo "No managed MCPs are installed yet."
    return 0
  fi

  if [[ "${requested[0]}" == "all" ]]; then
    if [[ ${#selected_files[@]} -gt 0 ]]; then
      for metadata_file in "${selected_files[@]}"; do
        load_mcp_metadata "$metadata_file"
        echo "Updating MCP $NAME ($MODE)..."
        install_mcp_by_name "$NAME" "$MODE"
      done
    fi
  else
    for name in "${requested[@]}"; do
      found=0
      if [[ ${#selected_files[@]} -gt 0 ]]; then
        for metadata_file in "${selected_files[@]}"; do
          load_mcp_metadata "$metadata_file"
          if [[ "$NAME" == "$name" ]]; then
            echo "Updating MCP $NAME ($MODE)..."
            install_mcp_by_name "$NAME" "$MODE"
            found=1
          fi
        done
      fi
      if [[ "$found" -eq 0 ]]; then
        echo "Error: MCP $name is not installed." >&2
        exit 1
      fi
    done
  fi

  sync_global_agents_file
  sync_project_agents_file
  echo "Done."
}

bootstrap_list_mcps() {
  local metadata_file
  local -a selected_files=()

  ensure_base_dirs
  collect_selected_mcp_metadata_files
  if [[ ${#SELECTED_MCP_METADATA_FILES[@]} -gt 0 ]]; then
    selected_files=("${SELECTED_MCP_METADATA_FILES[@]}")
  fi

  if [[ ${#selected_files[@]} -eq 0 ]]; then
    echo "Managed MCP inventory:"
    echo "- none"
    return 0
  fi

  echo "Managed MCP inventory:"
  if [[ ${#selected_files[@]} -gt 0 ]]; then
    for metadata_file in "${selected_files[@]}"; do
      load_mcp_metadata "$metadata_file"
      echo "- $NAME | Mode: $MODE | Type: $TYPE | Source: $SOURCE_KIND:$SOURCE_REF | Target: $TARGET_DIR | Updated: $UPDATED_AT"
      echo "  Run: $RUN_COMMAND"
      echo "  Setup: $SETUP_COMMAND"
      [[ -n "${NOTES:-}" ]] && echo "  Note: $NOTES"
    done
  fi

  if [[ ${#STALE_MCP_METADATA_FILES[@]} -gt 0 ]]; then
    echo
    echo "Stale metadata files:"
    printf -- '- %s\n' "${STALE_MCP_METADATA_FILES[@]}"
  fi
}
