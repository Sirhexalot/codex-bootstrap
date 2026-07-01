# Bootstrap Internals

This file belongs to the hidden `.codex` bootstrap repository itself.

It is not one of the customer-facing files created by `codex init`.

## Separation

- Customer-facing files are created in the visible parent folder:
  - `../Agents.md`
  - `../Memory.md`
  - `../Decisions.md`
- Everything technical stays inside `.codex`.

## Structure Rules

- `bin/` is the command surface.
- `bootstrap/` contains internal commands, templates, and libraries.
- `state/` contains managed metadata for Tools, Skills, and MCPs.
- `runtime/` contains project-local runtimes and automations.
- Do not reintroduce customer-owned documents into the hidden runtime structure.
