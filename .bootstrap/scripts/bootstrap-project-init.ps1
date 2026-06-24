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

  $projectName = Prompt-Default "Project name" "Customer Agent"
  $userName = Prompt-Default "User name"
  $agentName = Prompt-Default "Agent name" "Karl"
  $customer = Prompt-Default "Customer, team, or organization" $userName
  $owner = Prompt-Default "Responsible person or team" $userName
  $purpose = Prompt-Default "Agent purpose"
  $role = Prompt-Default "Agent role or focus" "AI coworker"
  $country = Prompt-Default "Country"
  $timezone = Prompt-Default "Timezone" (Get-TimeZone).Id
  $language = Prompt-Default "Language" "en"
  $tone = Prompt-Default "Tone" "friendly, precise, practical"
  $riskLevel = Prompt-Default "Risk level" "medium"
  $boundaries = Prompt-Default "Sensitive boundaries and no-gos" "No external changes without approval"
  $tools = Prompt-Default "Important tools or systems" "GitHub, Google Workspace, Slack"
  $channels = Prompt-Default "Preferred channels" "Codex"

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
"@ | Set-Content -Path (Join-Path $rootDir "project.yaml") -Encoding UTF8

  New-Item -ItemType Directory -Force -Path (Join-Path $rootDir "docs") | Out-Null
  @"
# Customer Context

## User and Project

- User name: ``$userName``
- Agent name: ``$agentName``
- Project name: ``$projectName``
- Customer, team, or organization: ``$customer``
- Role or focus: ``$role``

## Goal

- Purpose: ``$purpose``
- Working style: ``The agent works like a reliable coworker, reads context first, delivers concrete results, and asks for approval before external or irreversible steps.``
- Key outcomes: ``Documentation, decisions, automations, artifacts, and clear next steps.``

## Context

- Country: ``$country``
- Timezone: ``$timezone``
- Language: ``$language``
- Tone: ``$tone``

## Boundaries

- Sensitive areas: ``$boundaries``
- External or irreversible actions require approval
"@ | Set-Content -Path (Join-Path $rootDir "docs/customer-context.md") -Encoding UTF8

  @"
# Tools and Access

## Workbench Tools

- Python: ``global``
- Tool bundles: ``core, documents, pdf-images, diagrams, browser-automation, composio-cli``
- Scope model: ``global or project``
- Native priority: ``system tools first, Python or Node only as targeted supplements``
- Global Python workbench: ``~/.codex/workbench/python``
- Global Python entrypoint: ``codex-python``
- Global extractor entrypoint: ``codex-markitdown``

## Project-Relevant Systems

- Important tools or platforms: ``$tools``
- Preferred channels: ``$channels``

## Access Rules

- Tools and skills can be installed in global or project mode.
- Installation scripts synchronize compact managed global references into ``~/.codex/AGENTS.md`` and managed project entries into ``./AGENTS.md``.
- Credentials are not stored in project files.
- External write actions require explicit approval.
"@ | Set-Content -Path (Join-Path $rootDir "docs/tools-and-access.md") -Encoding UTF8

  @"
# Decisions

## Decisions

### $(Get-Date -Format "yyyy-MM-dd") - Project initialized

- Decision: This repository was turned into a concrete agent for ``$userName``.
- Rationale: The bootstrap should now act as the real project frame for ``$agentName``.
- Alternatives: Keep the generic bootstrap AGENTS file.
- Impact: The visible ``AGENTS.md`` is now project-specific, and tool bundles and skills can be chosen in global or project mode.
- Status: ``active``
"@ | Set-Content -Path (Join-Path $rootDir "docs/decisions.md") -Encoding UTF8

  @"
# Project Memory

## Overview

- Project name: ``$projectName``
- User: ``$userName``
- Agent: ``$agentName``
- Purpose: ``$purpose``
- Role: ``$role``
- Country: ``$country``
- Timezone: ``$timezone``

## Stable Rules

- Tool bundles and skills are installed by script in ``global`` or ``project`` mode.
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
  - wrote the final ``AGENTS.md`` for ``$agentName``
  - adapted ``project.yaml``, ``docs/``, and ``Memory.md`` to the project context
  - created or updated the Heartbeat automation
- Next steps:
  - define the first concrete tools and channels
  - install the required tool bundles and skills in global or project mode
"@ | Set-Content -Path (Join-Path $rootDir "Memory.md") -Encoding UTF8

  Write-Host ""
  Write-Host "Project initialized."
  Write-Host ""
  Write-Host "Next recommended commands:"
  Write-Host "  ./scripts/install_tools.sh"
  Write-Host "  ./scripts/install_skills.sh"
}
