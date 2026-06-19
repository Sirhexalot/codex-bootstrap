# AI Coworker Agent

Dieses Projekt ist die Arbeitsbasis fuer einen Codex-basierten AI-Coworker. Das Ziel ist ein Agent, der nicht nur Fragen beantwortet, sondern Kontext liest, Tools nutzt, wiederkehrende Aufgaben in Automatisierungen ueberfuehrt und konkrete Ergebnisse liefert: Reports, Recherchen, Code-Aenderungen, Dashboards, Dateien, Runbooks oder Entscheidungen.

Das Zielbild ist ein teamfaehiger AI-Coworker mit Integrationen, echter Ausfuehrung, geplanten Aufgaben und sicheren Freigabegrenzen. Dieses Repository bleibt bewusst lokal und dokumentiert, welche Tools, Zugriffe, Automatisierungen und Skills fuer den konkreten Coworker Schritt fuer Schritt eingerichtet werden.

## Aktueller Fokus

- Zielbild: `AI Coworker Agent`
- Nutzer: `Adrian`, spaeter optional Teammitglieder oder Kunden
- Sprache: `de`
- Arbeitsweise: proaktiv, aber externe oder irreversible Aktionen nur nach Freigabe
- Naechster sinnvoller Schritt: ersten konkreten Coworker-Use-Case waehlen und daraus eine Automatisierung oder Tool-Anbindung ableiten

## Ursprung Der Vorlage

Dieses Projekt basiert auf einer Bootstrap-Vorlage und enthaelt weiterhin Setup-Skripte fuer Codex-basierte Kunden-Agenten. Die Vorlage kann in neue Kundenordner kopiert und dort erneut initialisiert werden.

## Start Here

If you copied this folder for a new customer, open it in Codex and say:

```text
Bitte initialisiere dieses Projekt als Kunden-Agent.
```

Codex should read `START_HERE.md`, `AGENTS.md`, `project.yaml`, `Memory.md`, and the files in `docs/` before making changes.

Optional local initialization scripts are available:

macOS/Linux:

```bash
chmod +x ./scripts/init-project.sh
./scripts/init-project.sh
```

Windows:

```powershell
.\scripts\init-project.ps1
```

These scripts only change files inside the current project folder. They do not write to `~/.codex`, install global tools, or configure MCP servers.

## Contents

- `setup-mac.sh`: Homebrew-based setup for macOS, including macOS-only MCP servers.
- `setup-windows.ps1`: `winget`/`npm`/`pip`/Git Bash-based setup for Windows.
- `START_HERE.md`: Friendly onboarding entry point for turning the template into a customer agent.
- `AGENTS.md`: Project-level instructions for Codex agents.
- `project.yaml`: Structured project identity and onboarding metadata.
- `Memory.md`: Project-wide memory for decisions, current state, and open points.
- `docs/`: Customer context, tool access, and decision records.
- `automations/`: Concrete customer automations.
- `templates/`: Reusable templates for automations and skills.
- `skills/`: Project-specific skills.
- `scripts/`: Optional helper scripts for initialization and validation.

## Two Kinds Of Setup

This repository separates workstation setup from customer-project initialization.

Workstation setup:

- Files: `setup-mac.sh`, `setup-windows.ps1`
- Purpose: prepare the computer for Codex work.
- Scope: may install global tools, MCP servers, global skills, and Codex configuration under `~/.codex`, `~/.agents`, or related user-level folders.

Project initialization:

- Files: `scripts/init-project.sh`, `scripts/init-project.ps1`
- Purpose: turn a copied template folder into a concrete customer agent.
- Scope: only edits files inside this project folder, such as `project.yaml`, `README.md`, `Memory.md`, `.bootstrap/manifest.json`, `docs/`, and `automations/heartbeat/`.

## Project Shape

```text
customer-agent/
├─ .bootstrap/
├─ AGENTS.md
├─ Memory.md
├─ README.md
├─ START_HERE.md
├─ project.yaml
├─ automations/
├─ docs/
├─ skills/
├─ templates/
└─ scripts/
```

## Memory Model

This bootstrap uses three memory levels:

- Memory MCP Server: long-term memory for stable facts and reusable context.
- Project `Memory.md`: current state, decisions, risks, and next steps for this customer agent.
- Automation `Memory.md`: run-by-run logs and state for each automation.

Every automation run must update its own `Memory.md`. Relevant project changes should update the root `Memory.md`.

## Default Heartbeat

Project initialization creates a local automation definition named `Heartbeat` under `automations/heartbeat/`.

Its intended schedule is weekdays, every hour from 09:00 to 17:00 local time. Its job is to check whether project memory, automation memories, decisions, open points, and documentation have been kept up to date.

The init scripts create the files for this automation. The actual recurring run still needs to be activated in Codex or another scheduler for each customer project.

## Bootstrap Metadata

The bootstrap version and project identity live in `project.yaml`. A machine-readable manifest lives in `.bootstrap/manifest.json`.

`AGENTS.md` contains a managed block marked with:

```text
<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->
<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->
```

Init and update scripts may refresh that block, while manual project instructions should live outside it.

## What Gets Installed

The scripts install or configure:

- Python 3
- Python 3.13 on macOS for Meta Ads CLI compatibility
- Node.js LTS and npm
- FFmpeg
- ImageMagick
- Ghostscript
- Git / Git Bash
- OpenAI Codex CLI
- Memory MCP server for Codex
- MarkItDown MCP server for Codex
- Microsoft Teams MCP server for Codex via `@floriscornel/teams-mcp`
- Apple Mail MCP server for Codex on macOS
- Apple Calendar MCP server for Codex on macOS
- ChatGPT desktop app where supported
- `pnpm` for local Node-based MCP servers
- `pipx` for global Python CLI installs
- Python packages: `holidays`, `pillow`, `rembg`, `markitdown-mcp`
- Composio CLI
- Meta Ads CLI via `pipx install meta-ads`
- Several Codex skills, including Remotion, Composio, brand, and design-related skills

After installation, restart Codex so newly installed skills and MCP configuration are picked up.

## Windows Setup

### Requirement

Windows requires `winget`. If it is missing, install **App Installer** from the Microsoft Store and restart PowerShell.

### Run The Script

Open PowerShell in this project folder and run:

```powershell
.\setup-windows.ps1
```

If PowerShell blocks script execution, use one of these options.

### Option A: Allow Only For This Session

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-windows.ps1
```

### Option B: Allow For Your User

```powershell
Unblock-File .\setup-windows.ps1
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\setup-windows.ps1
```

### Option C: Run Directly With Bypass

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

## macOS Setup

Open Terminal in this project folder and run:

```bash
chmod +x ./setup-mac.sh
./setup-mac.sh
```

If Homebrew is missing, the script installs it automatically.

## Composio

The setup installs Composio CLI. In a new terminal, sign in and verify:

```bash
composio login
composio whoami
```

Official toolkit docs:

https://docs.composio.dev/toolkits

The scripts intentionally reinstall Composio cleanly by removing only the local Composio binary and version marker files in `~/.composio`. Existing login, user, and config files are preserved.

Typical CLI workflow:

```bash
composio search "gmail"
composio link gmail
composio execute "<TOOL_SLUG>" -d '{"key":"value"}'
```

## Microsoft Teams MCP

The setup registers the Teams MCP server from `floriscornel/teams-mcp` in the user-level Codex config:

```toml
[mcp_servers.teams_mcp]
command = "npx"
args = ["-y", "@floriscornel/teams-mcp@latest"]
enabled = true
```

It requires Node.js 18+ and a Microsoft 365 account. Authentication is done locally through Microsoft Graph device login:

```bash
npx -y @floriscornel/teams-mcp@latest authenticate
```

The server stores Microsoft Graph auth files in the user's home folder, not in this repository. Restart Codex after authentication so the MCP server is available in new sessions.

If a project uses the Composio SDK directly:

```bash
composio init
```

## Meta Ads CLI

This project uses the official Meta Ads CLI, not a Meta Ads MCP server.

The setup installs the CLI globally with `pipx`:

```bash
pipx install --python python3.13 meta-ads
```

On macOS, the setup installs `python@3.13` and `pipx`, then installs `meta-ads` against Python 3.13 because the package currently publishes compatible wheels for CPython 3.12/3.13 and this avoids the common Homebrew `pip` / PEP 668 issue.

On Windows, the setup installs the CLI through `pipx` using Python 3.12.

If `pipx` reports that `~/.local/bin` is not on `PATH`, run:

```bash
pipx ensurepath
```

Then restart your terminal.

Official Meta setup reference:

https://developers.facebook.com/documentation/ads-commerce/ads-ai-connectors/ads-cli/setup/get-started

Supplementary third-party guide:

https://www.get-ryze.ai/blog/meta-cli-command-line-tool-for-meta-ads-automation

Note: the Ryze article is useful for ideas and workflow examples, but the official Meta documentation and the official PyPI package `meta-ads` remain the source of truth for this project.

## Project-Specific CLI Paths

Use these generic path patterns in project instructions:

```text
Meta Ads CLI: ~/.local/pipx/venvs/meta-ads/bin/meta
Composio CLI: ~/.composio/composio
```

For Meta Ads work in this project, prefer the Meta Ads CLI at:

```text
~/.local/pipx/venvs/meta-ads/bin/meta
```

For other Composio access in this project, prefer the local Composio CLI at:

```text
~/.composio/composio
```

Only use another path or integration method if the relevant CLI is demonstrably unavailable.

## Remotion

Remotion is usually created per project. Start a new Remotion project with:

```bash
npx create-video@latest
```

Docs: https://www.remotion.dev/docs

## Design Skills

The setup installs two focused skills from `nextlevelbuilder/ui-ux-pro-max-skill` in addition to `ui-ux-pro-max`:

- `ckm:design`
- `ckm:banner-design`

This keeps UI/UX decisions, brand assets, and concrete creative production separated.

## MarkItDown MCP

The setup installs `markitdown-mcp` and writes it into `~/.codex/config.toml`.

On macOS, the script uses a dedicated virtual environment so Homebrew Python is not modified by global package installs:

```toml
[mcp_servers.markitdown]
command = "/Users/<your-user>/.codex/venvs/python-tools/bin/markitdown-mcp"
enabled = true
```

## macOS-only MCP Servers

On macOS, the setup also installs Apple Mail MCP and Apple Calendar MCP under `~/.codex/mcp/` and registers them in `~/.codex/config.toml`.

## Outlook MCP

The linked `marlonluo2018/outlook-mcp-server` is Windows-only. It depends on Outlook desktop and Windows COM APIs. For a cross-platform approach, a Microsoft Graph-based MCP is more appropriate.

## After Setup

1. Restart Terminal or PowerShell.
2. Restart Codex so MCP configuration and skills are reloaded.
3. Optionally verify:

```bash
codex --version
node --version
npm --version
composio whoami
~/.local/pipx/venvs/meta-ads/bin/meta --help
```
