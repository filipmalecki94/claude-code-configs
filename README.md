# claude-code-configs

Personal Claude Code configuration files (`.claude/`) — agents, hooks, and slash commands.

## Installation

```bash
git clone git@github.com:filipmalecki94/claude-code-configs.git
cd claude-code-configs
./install.sh --mode <config> [TARGET_DIR]
```

### Global config (user-level, all projects)

```bash
./install.sh --mode global
```

Installs hooks to `~/.claude/hooks/` and merges settings into `~/.claude/settings.json`.
Requires `jq` for automatic settings merge — otherwise shows a manual snippet to add.

### Project-level configs

```bash
./install.sh --mode node-monorepo /path/to/my-project
./install.sh --mode nextjs --mode docker /path/to/project
./install.sh --mode nextjs --mode wordpress --mode docker /path/to/project
```

After installing, create `.mcp.json` files from the `.mcp.json.example` templates and fill in your tokens.

## Structure

```
global/        → ~/.claude/           (user-level, applies to all projects)
docker/        → <project>/.claude/
nextjs/        → <project>/.claude/
node-monorepo/ → <project>/.claude/ + CLAUDE.md
wordpress/     → <project>/.claude/
```

Each directory contains:
- `settings.json` — hooks configuration
- `hooks/` — shell scripts run by Claude Code hooks
- `commands/` — custom slash commands (`/command-name`)
- `agents/` — specialized agent definitions

## Global hooks

| Hook | State | Color | When |
|------|-------|-------|------|
| `terminal-state.sh` | `working` | dark blue `#0d1b2e` | Claude generating a response |
| `terminal-state.sh` | `tool` | dark violet `#1a0a30` | Claude executing a tool |
| `terminal-state.sh` | `waiting` | dark green `#0a2218` | Waiting for user input |
| `terminal-state.sh` | `idle` | *(reset)* | Session start/end |

Terminal background changes via OSC escape sequences. Compatible with kitty, GNOME Terminal, WezTerm, iTerm2, Alacritty, and tmux.

## Secrets

`.mcp.json` files contain tokens — **never commit them**. Use `.mcp.json.example` as a template. Both `.mcp.json` and `settings.local.json` are blocked by this repo's `.gitignore`.
