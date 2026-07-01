# Codex Bootstrap

This repository is intended to live as `.codex` inside a customer code folder.

Visible customer documents live one level above this repository:

- `../AGENTS.md`
- `../Memory.md`
- `../Decisions.md`

The hidden repository owns only the technical runtime:

```text
.codex/
  README.md
  project.yaml
  bin/
    codex
    codex.ps1
  bootstrap/
    commands/
    lib/
    templates/
    catalogs/
  state/
    tools/
    skills/
    mcps/
  runtime/
    tools/
    skills/
    mcps/
    automations/
```

## Main Flow

1. Clone this repository into the customer folder as `.codex`.
2. Run `./.codex/bin/codex init`.
3. Answer the project questions.
4. Manage extensions through the same CLI:
   - `./.codex/bin/codex add ...`
   - `./.codex/bin/codex list ...`
   - `./.codex/bin/codex update ...`

## Commands

```bash
./.codex/bin/codex setup
./.codex/bin/codex init
./.codex/bin/codex add tool <name> --scope global|project
./.codex/bin/codex add skill <name> --scope global|project
./.codex/bin/codex add mcp <name> --scope global|project
./.codex/bin/codex list [all|tools|skills|mcps] --scope global|project|both
./.codex/bin/codex update [all|tools|skills|mcps] [name...] --scope global|project|both
```

## Rules

- `setup` prepares only the shared global workbench.
- `init` creates the visible customer files in the parent folder.
- `state/` stores managed metadata only.
- `runtime/` stores project-local runtimes only.
- `bootstrap/` is internal implementation.
- Inventories are shown with `codex list`, not through generated blocks inside `AGENTS.md`.
