# Tools and Access

This file documents which global workbench tools and project-specific systems matter for the eventual agent.

## Workbench Tools

- Tool bundles: `core`, `documents`, `pdf-images`, `diagrams`, `browser-automation`, `composio-cli`
- Scope model: tools and skills can be installed as `global` or `workspace`
- Native priority: system tools first, Python or Node only as targeted supplements
- Global Python workbench: `~/.codex/workbench/python`
- Global Python entrypoint: `codex-python`
- Global extractor entrypoint: `codex-markitdown`
- Global installations are also synchronized into `~/.codex/AGENTS.md` as compact reference blocks

## Bundle Capabilities

- `core`: Git, Curl, `rg`, base Python, base Node, `pipx`
- `documents`: Office and document extraction helpers, Pandoc, the Homebrew `pymupdf` formula on macOS, and Python document libraries including `pypdf` and `pymupdf`
- `pdf-images`: `ffmpeg`, ImageMagick, Ghostscript
- `diagrams`: Draw.io
- `browser-automation`: `pnpm`, Playwright
- `composio-cli`: Composio CLI for connected app tooling from the terminal

## Project-Relevant Systems

- Add the concrete systems, platforms, and channels for the initialized project here.

## Access Rules

- Tools and skills follow the same scope model.
- Installation scripts synchronize compact managed global references into `~/.codex/AGENTS.md` and managed project entries into `./AGENTS.md`.
- Credentials must not be stored in project files.
- External write actions require explicit approval.
