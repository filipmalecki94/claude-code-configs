#!/usr/bin/env bash
# Usage: ./install.sh [PATH_TO_MISSIO_DOCKER]
# Default: current directory

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TARGET="${1:-$PWD}"

# Validate target
[[ -d "$TARGET/nextjs" ]] || { echo "Error: $TARGET/nextjs does not exist"; exit 1; }
[[ -d "$TARGET/wordpress" ]] || { echo "Error: $TARGET/wordpress does not exist"; exit 1; }

copy_configs() {
  local src="$1" dst="$2" label="$3"
  echo "Installing $label → $dst"
  mkdir -p "$dst"
  cp -r "$src/." "$dst/"
  # Remove example files from destination — they're templates only
  find "$dst" -name '.mcp.json.example' -delete
}

copy_configs "$SCRIPT_DIR/missio/docker"    "$TARGET/.claude"             "docker (root)"
copy_configs "$SCRIPT_DIR/missio/nextjs"    "$TARGET/nextjs/.claude"      "nextjs"
copy_configs "$SCRIPT_DIR/missio/wordpress" "$TARGET/wordpress/.claude"   "wordpress"

echo ""
echo "✓ Configs installed."
echo "  Create .mcp.json in each location from the .mcp.json.example template:"
echo "    cp $(basename $SCRIPT_DIR)/missio/docker/.mcp.json.example $TARGET/.mcp.json"
echo "    cp $(basename $SCRIPT_DIR)/missio/nextjs/.mcp.json.example $TARGET/nextjs/.mcp.json"
echo "    cp $(basename $SCRIPT_DIR)/missio/wordpress/.mcp.json.example $TARGET/wordpress/.mcp.json"
echo "  Then fill in your tokens."
echo "  (settings.local.json and .mcp.json are gitignored — never commit them)"
