# Bootstrap Internals

This folder contains the hidden bootstrap logic for this repository.

## Purpose

- initialize a new agent project
- provide templates for the final `AGENTS.md`, `Memory.md`, and `Decisions.md`
- store metadata about bootstrap versions and managed installations
- track skill catalogs and skill installation state
- track MCP catalogs and MCP installation state
- provide templates for automations and skills

## What Agents Should Read First

If this repository has not been initialized yet, read at least in this order:

1. `.bootstrap/README.md`
2. `.bootstrap/templates/final-AGENTS.md`
3. `.bootstrap/scripts/bootstrap-project-init.sh` or `.bootstrap/scripts/bootstrap-project-init.ps1`
4. `.bootstrap/lib/skill-catalog.sh`

## Important Rules

- the visible `AGENTS.md` is only the bootstrap entry point
- after initialization, the visible `AGENTS.md` belongs to the concrete project
- customer context belongs in `AGENTS.md`, not in a separate `docs/` tree
- tool bundles, skills, and MCP servers can be installed in global or project mode depending on the task
- native system tools stay globally preferred, while document-heavy Python or Node runtimes may be added locally when useful
- skills are fetched from original repositories and installed per run as `global` or `project`
- MCP servers keep their own metadata under `.bootstrap/mcp-installs/` and project-local runtime wrappers under `.mcp/`
- project collections should live under `.bootstrap/skills-cache/` so the visible project area stays clean
- project automations live under `.bootstrap/automations/`
- visible entry points live under `.scripts/`

## Internal Structure

- `templates/`: templates for final agent docs, automations, and skills
- `automations/`: project automation folders that belong to the bootstrap-managed area
- `scripts/`: bootstrap-internal initialization logic
- `lib/`: shared shell helpers
- `tool-installs/`: metadata for managed tool installations
- `skill-installs/`: metadata for managed skill installations
- `mcp-installs/`: metadata for managed MCP installations
- `skills-cache/`: isolated project-local skill collections
- `manifest.json`: machine-readable bootstrap metadata
