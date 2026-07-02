#!/usr/bin/env bash
set -euo pipefail

node_path="$(node -e 'console.log(process.execPath)')"
echo "Node binary: $node_path"
open -R "$node_path"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
