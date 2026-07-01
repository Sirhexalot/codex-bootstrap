# Bootstrap Repo

This repository is the hidden `.codex` technical layer for a customer folder.

## Repo Role

- Keep the customer-facing truth outside this repository in `../AGENTS.md`, `../Memory.md`, and `../Decisions.md`.
- Keep technical implementation inside `bin/`, `bootstrap/`, `state/`, and `runtime/`.
- Use `README.md` as the single technical entrypoint.

## Structure Rules

- `bin/` is the only visible command surface.
- `bootstrap/` contains internal commands, templates, and libraries.
- `state/` contains managed metadata for Tools, Skills, and MCPs.
- `runtime/` contains project-local runtimes and automations.
- Do not reintroduce managed inventory blocks into project `AGENTS.md`.
