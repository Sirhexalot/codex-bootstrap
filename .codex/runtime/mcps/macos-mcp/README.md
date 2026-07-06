# macos-mcp

This managed MCP server uses the published `mcp-macos` package through `npx`.
Source repository: `https://github.com/krmj22/macos-mcp`

- `./run.sh` starts the MCP server
- `./check.sh` runs the upstream preflight checks
- `./verify-jxa.sh` runs the individual Automation permission probes
- `./reveal-node-for-fda.sh` helps grant Full Disk Access to the real Node binary
- `./setup.sh --open-permissions` opens the relevant macOS settings panes
