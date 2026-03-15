#!/usr/bin/env bash
# Claude Code Configs — installer
#
# INTERACTIVE (wizard):
#   ./install.sh
#   ./install.sh --wizard
#
# SCRIPTED (Claude Code / CI):
#   ./install.sh --mode global
#   ./install.sh --mode node-monorepo /path/to/project
#   ./install.sh --mode nextjs --mode docker /path/to/project
#   ./install.sh --mode nextjs --mode wordpress --mode docker /path/to/project
#
# Available modules:
#   global          — user-level hooks (~/.claude/), no TARGET_DIR needed
#   node-monorepo   — npm workspaces monorepo (CLAUDE.md to root, rest to .claude/)
#   nextjs          — Next.js frontend (.claude/)
#   wordpress       — WordPress backend (.claude/)
#   docker          — Docker/infra root config (.claude/)

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MODES=()
TARGET=""
WIZARD=false

# ── Argument parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODES+=("$2")
      shift 2
      ;;
    --wizard)
      WIZARD=true
      shift
      ;;
    --help|-h)
      sed -n '2,20p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

# No args → wizard mode
[[ ${#MODES[@]} -eq 0 && -z "$TARGET" ]] && WIZARD=true

# ── Helpers ───────────────────────────────────────────────────────────────────

bold()  { printf '\033[1m%s\033[0m' "$*"; }
green() { printf '\033[32m%s\033[0m' "$*"; }
cyan()  { printf '\033[36m%s\033[0m' "$*"; }
dim()   { printf '\033[2m%s\033[0m' "$*"; }

MODULE_NAMES=(global node-monorepo nextjs wordpress docker)

describe_module() {
  case "$1" in
    global)       echo "User-level hooks & commands (~/.claude/) — install once per machine" ;;
    node-monorepo) echo "npm workspaces monorepo root (CLAUDE.md + .claude/)" ;;
    nextjs)       echo "Next.js / React frontend (.claude/)" ;;
    wordpress)    echo "WordPress backend (.claude/)" ;;
    docker)       echo "Docker & infrastructure config (.claude/)" ;;
  esac
}

# ── Wizard ────────────────────────────────────────────────────────────────────

run_wizard() {
  echo ""
  bold "  Claude Code Configs — Setup Wizard"; echo ""
  dim   "  Configures Claude Code for a new project or user environment."; echo ""
  echo ""

  # Step 1 — scope
  echo "$(bold "Step 1/3") — What are you setting up?"
  echo "  1) Global user environment  $(dim "(~/.claude/ hooks, once per machine)")"
  echo "  2) A project directory"
  echo ""
  local scope
  while true; do
    read -rp "  Choice [1/2]: " scope
    case "$scope" in
      1) MODES=("global"); break ;;
      2) break ;;
      *) echo "  Please enter 1 or 2." ;;
    esac
  done

  # Step 2 — if project, pick path and modules
  if [[ "$scope" == "2" ]]; then
    echo ""
    echo "$(bold "Step 2a/3") — Target directory"
    local default_target
    default_target=$(pwd)
    read -rp "  Path [$(dim "$default_target")]: " TARGET
    TARGET="${TARGET:-$default_target}"
    TARGET="${TARGET/#\~/$HOME}"
    if [[ ! -d "$TARGET" ]]; then
      echo ""
      read -rp "  Directory '$TARGET' does not exist. Create it? [y/N]: " create_dir
      if [[ "${create_dir,,}" == "y" ]]; then
        mkdir -p "$TARGET"
      else
        echo "Aborted."
        exit 1
      fi
    fi

    echo ""
    echo "$(bold "Step 2b/3") — Which modules to install? $(dim "(space = toggle, enter = confirm)")"
    echo ""

    local project_modules=(node-monorepo nextjs wordpress docker)
    local selected=()

    if command -v fzf &>/dev/null; then
      # fzf multi-select
      local fzf_input=""
      for m in "${project_modules[@]}"; do
        fzf_input+="$m — $(describe_module "$m")"$'\n'
      done
      local fzf_out
      fzf_out=$(printf '%s' "$fzf_input" | fzf \
        --multi \
        --prompt="  Module > " \
        --height=10 \
        --border=rounded \
        --marker="●" \
        --pointer="▶" \
        --header="TAB to select, ENTER to confirm" \
        --color="header:dim" \
        | awk -F' — ' '{print $1}') || true
      while IFS= read -r line; do
        [[ -n "$line" ]] && selected+=("$line")
      done <<< "$fzf_out"
    else
      # Fallback: numbered toggle menu
      local toggled=()
      for m in "${project_modules[@]}"; do toggled+=(false); done

      while true; do
        echo ""
        for i in "${!project_modules[@]}"; do
          local m="${project_modules[$i]}"
          local mark="  [ ]"
          [[ "${toggled[$i]}" == "true" ]] && mark="  [$(green "✓")]"
          printf "%s %d) %-16s $(dim "%s")\n" "$mark" "$((i+1))" "$m" "$(describe_module "$m")"
        done
        echo ""
        echo "  $(dim "Type a number to toggle, or ENTER when done.")"
        read -rp "  Toggle [1-${#project_modules[@]}] or ENTER: " pick
        if [[ -z "$pick" ]]; then
          for i in "${!project_modules[@]}"; do
            [[ "${toggled[$i]}" == "true" ]] && selected+=("${project_modules[$i]}")
          done
          break
        elif [[ "$pick" =~ ^[1-9][0-9]*$ ]] && (( pick >= 1 && pick <= ${#project_modules[@]} )); then
          local idx=$((pick-1))
          [[ "${toggled[$idx]}" == "true" ]] && toggled[$idx]=false || toggled[$idx]=true
        else
          echo "  Invalid choice."
        fi
      done
    fi

    if [[ ${#selected[@]} -eq 0 ]]; then
      echo ""
      echo "  No modules selected. Aborted."
      exit 1
    fi

    MODES=("${selected[@]}")
  else
    echo "$(bold "Step 2/3") — $(dim "Global mode — no target directory needed.")"
  fi

  # Step 3 — summary + confirm
  echo ""
  echo "$(bold "Step 3/3") — Summary"
  echo ""
  if [[ -n "$TARGET" ]]; then
    printf "  %-12s %s\n" "Target:" "$(cyan "$TARGET")"
  fi
  printf "  %-12s %s\n" "Modules:" "$(cyan "${MODES[*]}")"
  echo ""

  # Show equivalent scripted command
  local cmd="./install.sh"
  for m in "${MODES[@]}"; do cmd+=" --mode $m"; done
  [[ -n "$TARGET" ]] && cmd+=" $TARGET"
  dim "  Equivalent command: $cmd"; echo ""
  echo ""

  read -rp "  Proceed with installation? [Y/n]: " confirm
  if [[ "${confirm,,}" == "n" ]]; then
    echo "Aborted."
    exit 0
  fi
  echo ""
}

# ── Validation (scripted mode) ────────────────────────────────────────────────

validate_scripted() {
  if [[ ${#MODES[@]} -eq 0 ]]; then
    echo "Error: at least one --mode is required"
    echo "Usage: ./install.sh --mode <config> [--mode <config>...] [TARGET_DIR]"
    echo "Configs: global | node-monorepo | nextjs | wordpress | docker"
    exit 1
  fi

  local needs_target=true
  for mode in "${MODES[@]}"; do
    [[ "$mode" == "global" ]] && needs_target=false
  done

  if [[ "$needs_target" == "true" && -z "$TARGET" ]]; then
    echo "Error: TARGET_DIR is required for non-global modes"
    echo "Usage: ./install.sh --mode <config> [--mode <config>...] TARGET_DIR"
    exit 1
  fi

  if [[ -n "$TARGET" ]]; then
    [[ -d "$TARGET" ]] || { echo "Error: target directory '$TARGET' does not exist"; exit 1; }
  fi
}

# ── Install functions ─────────────────────────────────────────────────────────

install_to_claude_dir() {
  local src="$1" dst="$TARGET/.claude" label="$2"
  echo "  Installing $label → $dst"
  mkdir -p "$dst"
  cp -r "$src/." "$dst/"
  find "$dst" -name '.mcp.json.example' -delete
  [[ -d "$dst/hooks" ]] && find "$dst/hooks" -name '*.sh' -exec chmod +x {} +
  echo "    .mcp.json template: cp $src/.mcp.json.example $TARGET/.mcp.json"
}

install_node_monorepo() {
  local src="$SCRIPT_DIR/node-monorepo"
  [[ -d "$src" ]] || { echo "Error: $src does not exist"; exit 1; }

  echo "  Installing node-monorepo → $TARGET"
  cp "$src/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "    CLAUDE.md → $TARGET/CLAUDE.md"

  local dst="$TARGET/.claude"
  mkdir -p "$dst"
  for item in settings.json hooks agents commands; do
    [[ -e "$src/$item" ]] && cp -r "$src/$item" "$dst/"
  done
  find "$dst" -name '.mcp.json.example' -delete
  [[ -d "$dst/hooks" ]] && chmod +x "$dst/hooks/"*.sh
  echo "    .mcp.json template: cp $src/.mcp.json.example $TARGET/.mcp.json"
}

install_global() {
  local src="$SCRIPT_DIR/global"
  local dst="$HOME/.claude"
  [[ -d "$src" ]] || { echo "Error: $src does not exist"; exit 1; }

  echo "  Installing global → $dst"

  mkdir -p "$dst/hooks"
  cp -r "$src/hooks/." "$dst/hooks/"
  find "$dst/hooks" -name '*.sh' -exec chmod +x {} +
  echo "    hooks → $dst/hooks/"

  if [[ -d "$src/commands" ]]; then
    mkdir -p "$dst/commands"
    cp -r "$src/commands/." "$dst/commands/"
    echo "    commands → $dst/commands/"
  fi

  local global_settings="$src/settings.json"
  local user_settings="$dst/settings.json"

  if command -v jq &>/dev/null; then
    if [[ -f "$user_settings" ]]; then
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
      echo "    settings.json merged into $user_settings"
    else
      cp "$global_settings" "$user_settings"
      echo "    settings.json → $user_settings"
    fi
  else
    echo ""
    echo "    NOTE: jq not found — cannot auto-merge settings.json."
    echo "    Manually add hooks from: $global_settings"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

if [[ "$WIZARD" == "true" ]]; then
  run_wizard
else
  validate_scripted
fi

echo "Installing..."
echo ""

for mode in "${MODES[@]}"; do
  case "$mode" in
    global)       install_global ;;
    node-monorepo) install_node_monorepo ;;
    nextjs)       install_to_claude_dir "$SCRIPT_DIR/nextjs" "nextjs" ;;
    wordpress)    install_to_claude_dir "$SCRIPT_DIR/wordpress" "wordpress" ;;
    docker)       install_to_claude_dir "$SCRIPT_DIR/docker" "docker" ;;
    *)
      echo "Error: unknown module '$mode'. Valid: global | node-monorepo | nextjs | wordpress | docker"
      exit 1
      ;;
  esac
done

echo ""
green "✓ Done."; echo " Fill in tokens in any .mcp.json files you created."
dim   "  (settings.local.json and .mcp.json are gitignored — never commit them)"; echo ""
