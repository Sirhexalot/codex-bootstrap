# Decisions

This file records important decisions for the concrete agent project.

## Bootstrap Decisions

### 2026-06-19 - Workbench split into bundles, tools, and selectable skills

- Decision: manage tools as bundles and install them, like skills, in `global` or `workspace` mode where that bundle meaningfully supports it.
- Rationale: keep the workbench reproducible across platforms without duplicating system-level tools unnecessarily.
- Status: `active`

### 2026-06-24 - Global AGENTS synchronization added for managed installs

- Decision: synchronize managed global tools and skills into `~/.codex/AGENTS.md`, and synchronize managed project entries into `./AGENTS.md`.
- Rationale: make the actual installed state visible where agents already look for operating context.
- Status: `active`
