#!/usr/bin/env bash
set -euo pipefail

exec npx -y "mcp-macos" --check "$@"
