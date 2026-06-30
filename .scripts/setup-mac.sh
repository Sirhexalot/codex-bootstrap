#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/.bootstrap/lib/tool-catalog.sh"

echo "Setting up the global Codex workbench on macOS."
echo "This script installs shared tooling only."
echo "It does not install Codex or any skills."
echo
bootstrap_install_tools --mode global all
