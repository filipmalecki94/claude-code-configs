# claude-code-configs

Personal Claude Code configuration files (`.claude/`) — agents, hooks, and slash commands.

## Installation

```bash
git clone git@github.com:filipmalecki94/claude-code-configs.git
cd claude-code-configs
./install.sh /path/to/project
```

After installing, create `.mcp.json` files from the `.mcp.json.example` templates and fill in your tokens.

## Structure

```
docker/        → <project>/.claude/
nextjs/        → <project>/nextjs/.claude/
wordpress/     → <project>/wordpress/.claude/
```

Each directory contains:
- `settings.json` — hooks configuration
- `hooks/` — shell scripts run by Claude Code hooks
- `commands/` — custom slash commands (`/command-name`)
- `agents/` — specialized agent definitions

## Secrets

`.mcp.json` files contain tokens — **never commit them**. Use `.mcp.json.example` as a template. Both `.mcp.json` and `settings.local.json` are blocked by this repo's `.gitignore`.
