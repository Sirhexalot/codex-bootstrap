# Decisions

This file records important decisions for the concrete agent project and the active bootstrap structure.

## Bootstrap Decisions

### 2026-06-19 - Workbench split into bundles, tools, and selectable skills

- Decision: manage tools as bundles and install them, like skills, in `global` or `workspace` mode where that bundle meaningfully supports it.
- Rationale: keep the workbench reproducible across platforms without duplicating system-level tools unnecessarily.
- Status: `active`

### 2026-06-24 - Global AGENTS synchronization added for managed installs

- Decision: synchronize compact managed global references into `~/.codex/AGENTS.md`, and synchronize managed project entries into `./AGENTS.md`.
- Rationale: make the actual installed state visible where agents already look for operating context.
- Status: `active`

### 2026-06-30 - Root project docs reduced to AGENTS, Memory, and Decisions

- Decision: keep customer context in `AGENTS.md`, keep durable project facts in `Memory.md`, and keep decision history in `Decisions.md`.
- Rationale: remove duplicate sources of truth and make the bootstrap easier to scan.
- Status: `active`

### 2026-06-30 - Visible commands moved to `.scripts` and project automations moved into `.bootstrap`

- Decision: store all visible command entry points in `.scripts/` and keep project automations in `.bootstrap/automations/`.
- Rationale: keep the root focused on the core project files while operational scaffolding stays grouped together.
- Status: `active`

### 2026-06-30 - MCPs are managed separately from tools and skills

- Decision: add MCP installation as its own managed surface with `global` and `workspace` scope, project-local files in `.mcp/`, and metadata in `.bootstrap/mcp-installs/`.
- Rationale: MCP servers behave more like runtime integrations than like tools or pure skill content, so they need their own lifecycle and metadata.
- Status: `active`
