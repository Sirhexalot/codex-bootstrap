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
    - "No external actions affecting customers, accounts, data, or costs without explicit approval."
    - "Do not store credentials, API keys, or tokens in project files."
    - "Do not enable production automations without documented purpose, access, and stop criteria."
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
  tools_scope: "global_or_project"
  skills_scope: "global_or_project"
  bundles:
    - "core"
    - "documents"
    - "pdf-images"
    - "diagrams"
    - "browser-automation"
    - "composio-cli"
  required:
    - "Codex"
    - "Python"
    - "Node.js"
    - "Git"
  optional:
    - "$tools"

onboarding:
  first_prompt: "Please initialize this project as a customer agent."
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
  purpose: "Regularly check whether memory, documentation, decisions, and runbooks are being maintained."
EOF
  }

  write_customer_context() {
    cat > "$root_dir/docs/customer-context.md" <<EOF
# Customer Context

## User and Project

- User name: \`$user_name\`
- Agent name: \`$agent_name\`
- Project name: \`$project_name\`
- Customer, team, or organization: \`$customer\`
- Role or focus: \`$role\`

## Goal

- Purpose: \`$purpose\`
- Working style: \`The agent works like a reliable coworker, reads context first, delivers concrete results, and asks for approval before external or irreversible steps.\`
- Key outcomes: \`Documentation, decisions, automations, artifacts, and clear next steps.\`

## Context

- Country: \`$country\`
- Timezone: \`$timezone\`
- Language: \`$language\`
- Tone: \`$tone\`

## Boundaries

- Sensitive areas: \`$boundaries\`
- External or irreversible actions require approval
EOF
  }

  write_tools_doc() {
    cat > "$root_dir/docs/tools-and-access.md" <<EOF
# Tools and Access

## Workbench Tools

- Python: \`global\`
- Tool bundles: \`core, documents, pdf-images, diagrams, browser-automation, composio-cli\`
- Scope model: \`global or project\`
- Native priority: \`system tools first, Python or Node only as targeted supplements\`
- Global Python workbench: \`~/.codex/workbench/python\`
- Global Python entrypoint: \`codex-python\`
- Global extractor entrypoint: \`codex-markitdown\`

## Project-Relevant Systems

- Important tools or platforms: \`$tools\`
- Preferred channels: \`$channels\`

## Access Rules

- Tools and skills can be installed in global or project mode.
- Installation scripts synchronize compact managed global references into \`~/.codex/AGENTS.md\` and managed project entries into \`./AGENTS.md\`.
- Credentials are not stored in project files.
- External write actions require explicit approval.
EOF
  }

  write_decisions_doc() {
    cat > "$root_dir/docs/decisions.md" <<EOF
# Decisions

## Decisions

### $(date +%F) - Project initialized

- Decision: This repository was turned into a concrete agent for \`$user_name\`.
- Rationale: The bootstrap should now act as the real project frame for \`$agent_name\`.
- Alternatives: Keep the generic bootstrap AGENTS file.
- Impact: The visible \`AGENTS.md\` is now project-specific, and tool bundles and skills can be chosen in global or project mode.
- Status: \`active\`
EOF
  }

  write_memory() {
    cat > "$root_dir/Memory.md" <<EOF
# Project Memory

## Overview

- Project name: \`$project_name\`
- User: \`$user_name\`
- Agent: \`$agent_name\`
- Purpose: \`$purpose\`
- Role: \`$role\`
- Country: \`$country\`
- Timezone: \`$timezone\`

## Stable Rules

- Tool bundles and skills are installed by script in \`global\` or \`project\` mode.
- External or irreversible actions require approval.
- Relevant project changes are documented here.

## Open Points

- sharpen the first productive use cases
- connect the relevant tools and channels in concrete terms

## Run Log

### $timestamp - Project initialized

- Trigger: local bootstrap initialization script
- Goal: turn the template into a concrete agent
- Results:
  - wrote the final \`AGENTS.md\` for \`$agent_name\`
  - adapted \`project.yaml\`, \`docs/\`, and \`Memory.md\` to the project context
  - created or updated the Heartbeat automation
- Next steps:
  - define the first concrete tools and channels
  - install the required tool bundles and skills in global or project mode
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
  "entrypoints": [
    "setup-mac.sh",
    "setup-windows.ps1",
    "scripts/init-project.sh",
    "scripts/init-project.ps1",
    "scripts/install_skills.sh",
    "scripts/update_skill.sh",
    "scripts/update_skills.sh",
    "scripts/list_skills.sh"
  ],
  "managedAreas": [
    ".bootstrap/templates/",
    ".bootstrap/scripts/",
    ".bootstrap/lib/",
    ".bootstrap/skill-installs/",
    ".bootstrap/skills-cache/"
  ],
  "notes": [
    "Workbench tools are global.",
    "Skills are fetched from original repositories.",
    "The visible AGENTS.md is replaced with a project-specific version after initialization."
  ]
}
EOF
  }

  timestamp="$(date +"%Y-%m-%d %H:%M %Z")"
  timezone="$(detect_timezone)"
  project_name="$(prompt_default "Project name" "Customer Agent")"
  user_name="$(prompt_default "User name")"
  agent_name="$(prompt_default "Agent name" "Karl")"
  customer="$(prompt_default "Customer, team, or organization" "$user_name")"
  owner="$(prompt_default "Responsible person or team" "$user_name")"
  purpose="$(prompt_default "Agent purpose")"
  role="$(prompt_default "Agent role or focus" "AI coworker")"
  country="$(prompt_default "Country")"
  timezone="$(prompt_default "Timezone" "$timezone")"
  language="$(prompt_default "Language" "en")"
  tone="$(prompt_default "Tone" "friendly, precise, practical")"
  risk_level="$(prompt_default "Risk level" "medium")"
  boundaries="$(prompt_default "Sensitive boundaries and no-gos" "No external changes without approval")"
  tools="$(prompt_default "Important tools or systems" "GitHub, Google Workspace, Slack")"
  channels="$(prompt_default "Preferred channels" "Codex")"

  mkdir -p "$root_dir/docs" "$root_dir/automations/heartbeat"
  render_final_agents
  write_project_yaml
  write_customer_context
  write_tools_doc
  write_decisions_doc
  write_memory
  write_manifest

  echo
  echo "Project initialized."
  echo
  echo "Next recommended commands:"
  echo "  ./scripts/install_tools.sh"
  echo "  ./scripts/install_skills.sh"
}
