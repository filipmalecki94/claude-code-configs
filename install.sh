#!/usr/bin/env bash
# Usage: ./install.sh --mode <config> [--mode <config>...] [TARGET_DIR]
#
# Available configs:
#   global          — user-level hooks (~/.claude/), no TARGET_DIR needed
#   node-monorepo   — npm workspaces monorepo (CLAUDE.md to root, rest to .claude/)
#   nextjs          — Next.js frontend (.claude/)
#   wordpress       — WordPress backend (.claude/)
#   docker          — Docker/infra root config (.claude/)
#
# Examples:
#   ./install.sh --mode global
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
      sed -n '2,15p' "$0" | sed 's/^# //'
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
  echo "Usage: ./install.sh --mode <config> [--mode <config>...] [TARGET_DIR]"
  echo "Configs: global | node-monorepo | nextjs | wordpress | docker"
  exit 1
fi

# global mode doesn't require a TARGET_DIR
NEEDS_TARGET=true
for mode in "${MODES[@]}"; do
  [[ "$mode" == "global" ]] && NEEDS_TARGET=false
done

if [[ "$NEEDS_TARGET" == "true" && -z "$TARGET" ]]; then
  echo "Error: TARGET_DIR is required for non-global modes"
  echo "Usage: ./install.sh --mode <config> [--mode <config>...] TARGET_DIR"
  exit 1
fi

if [[ -n "$TARGET" ]]; then
  [[ -d "$TARGET" ]] || { echo "Error: target directory '$TARGET' does not exist"; exit 1; }
fi

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

install_global() {
  local src="$SCRIPT_DIR/global"
  local dst="$HOME/.claude"

  [[ -d "$src" ]] || { echo "Error: $src does not exist"; exit 1; }

  echo "Installing global → $dst"

  # Copy hook scripts
  mkdir -p "$dst/hooks"
  cp -r "$src/hooks/." "$dst/hooks/"
  chmod +x "$dst/hooks/"*.sh
  echo "  hooks → $dst/hooks/"

  # Merge settings.json using jq if available, otherwise show manual instructions
  local global_settings="$src/settings.json"
  local user_settings="$dst/settings.json"

  if command -v jq &>/dev/null; then
    if [[ -f "$user_settings" ]]; then
      # Deep-merge: combine hooks arrays from both files
      local merged
      merged=$(jq -s '
        .[0] as $existing | .[1] as $new |
        $existing * $new |
        .hooks = (
          ($existing.hooks // {}) as $eh |
          ($new.hooks // {}) as $nh |
          ($eh | keys) + ($nh | keys) | unique |
          reduce .[] as $k (
            {};
            . + { ($k): (($eh[$k] // []) + ($nh[$k] // [])) }
          )
        )
      ' "$user_settings" "$global_settings")
      echo "$merged" > "$user_settings"
      echo "  settings.json merged into $user_settings"
    else
      cp "$global_settings" "$user_settings"
      echo "  settings.json → $user_settings"
    fi
  else
    echo ""
    echo "  NOTE: jq not found — cannot auto-merge settings.json."
    echo "  Manually add the following hooks to $user_settings:"
    echo "  (see $global_settings for the snippet)"
  fi
}

# --- Install each mode ---

for mode in "${MODES[@]}"; do
  case "$mode" in
    global)
      install_global
      ;;
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
      echo "Error: unknown mode '$mode'. Valid: global | node-monorepo | nextjs | wordpress | docker"
      exit 1
      ;;
  esac
done

echo ""
echo "✓ Done. Fill in tokens in any .mcp.json files you created."
echo "  (settings.local.json and .mcp.json are gitignored — never commit them)"
