#!/usr/bin/env bash
# Usage: ./install.sh --mode <config> [--mode <config>...] TARGET_DIR
#
# Available configs:
#   node-monorepo   — npm workspaces monorepo (CLAUDE.md to root, rest to .claude/)
#   nextjs          — Next.js frontend (.claude/)
#   wordpress       — WordPress backend (.claude/)
#   docker          — Docker/infra root config (.claude/)
#
# Examples:
#   ./install.sh --mode node-monorepo /path/to/my-project
#   ./install.sh --mode nextjs --mode docker /path/to/project
#   ./install.sh --mode nextjs --mode wordpress --mode docker /path/to/project

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MODES=()
TARGET=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODES+=("$2")
      shift 2
      ;;
    --help|-h)
      sed -n '2,14p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

# Validate
if [[ ${#MODES[@]} -eq 0 ]]; then
  echo "Error: at least one --mode is required"
  echo "Usage: ./install.sh --mode <config> [--mode <config>...] TARGET_DIR"
  echo "Configs: node-monorepo | nextjs | wordpress | docker"
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  echo "Error: TARGET_DIR is required"
  echo "Usage: ./install.sh --mode <config> [--mode <config>...] TARGET_DIR"
  exit 1
fi

[[ -d "$TARGET" ]] || { echo "Error: target directory '$TARGET' does not exist"; exit 1; }

# --- Helpers ---

install_to_claude_dir() {
  local src="$1" dst="$TARGET/.claude" label="$2"
  echo "Installing $label → $dst"
  mkdir -p "$dst"
  cp -r "$src/." "$dst/"
  find "$dst" -name '.mcp.json.example' -delete
  echo "  .mcp.json template: cp $src/.mcp.json.example $TARGET/.mcp.json"
}

install_node_monorepo() {
  local src="$SCRIPT_DIR/node-monorepo"
  [[ -d "$src" ]] || { echo "Error: $src does not exist"; exit 1; }

  echo "Installing node-monorepo → $TARGET"

  # CLAUDE.md goes to project root
  cp "$src/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  CLAUDE.md → $TARGET/CLAUDE.md"

  # Everything else to .claude/
  local dst="$TARGET/.claude"
  mkdir -p "$dst"
  for item in settings.json hooks agents commands; do
    [[ -e "$src/$item" ]] && cp -r "$src/$item" "$dst/"
  done
  find "$dst" -name '.mcp.json.example' -delete

  # Make hooks executable
  [[ -d "$dst/hooks" ]] && chmod +x "$dst/hooks/"*.sh

  echo "  .mcp.json template: cp $src/.mcp.json.example $TARGET/.mcp.json"
}

# --- Install each mode ---

for mode in "${MODES[@]}"; do
  case "$mode" in
    node-monorepo)
      install_node_monorepo
      ;;
    nextjs)
      install_to_claude_dir "$SCRIPT_DIR/nextjs" "nextjs"
      ;;
    wordpress)
      install_to_claude_dir "$SCRIPT_DIR/wordpress" "wordpress"
      ;;
    docker)
      install_to_claude_dir "$SCRIPT_DIR/docker" "docker"
      ;;
    *)
      echo "Error: unknown mode '$mode'. Valid: node-monorepo | nextjs | wordpress | docker"
      exit 1
      ;;
  esac
done

echo ""
echo "✓ Done. Fill in tokens in any .mcp.json files you created."
echo "  (settings.local.json and .mcp.json are gitignored — never commit them)"
