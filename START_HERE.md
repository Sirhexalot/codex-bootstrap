# Start Here

Use this repo as a hidden `.codex` bootstrap inside a customer or project folder.

## Quick start

1. Clone or place this repository as `.codex` inside the target project folder.
2. Optional on a fresh machine: run `./.codex/bin/cdx setup`.
3. Initialize the visible project files with `./.codex/bin/cdx init`.
4. Answer the setup questions.

After `cdx init`, the visible project files are created one level above this repo:

- `../Agents.md`
- `../Memory.md`
- `../Decisions.md`

## Next useful commands

```bash
./.codex/bin/cdx add tool documents --scope project
./.codex/bin/cdx add skill drawio-diagrams-enhanced --scope project
./.codex/bin/cdx add mcp macos-mcp --scope global
./.codex/bin/cdx list all --scope both
```

`README.md` explains the full structure and command surface.
