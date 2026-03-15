# claude-code-configs

Reusable Claude Code configurations — hooks, slash commands, and agents — for common project types. Install once globally and per-project to get consistent AI-assisted workflows everywhere.

---

## What's inside

- **`global/`** — user-level config (`~/.claude/`), active for all projects
- **`nextjs/`** — Next.js frontend projects
- **`node-monorepo/`** — npm workspaces monorepos
- **`wordpress/`** — WordPress (Bedrock) backends
- **`docker/`** — Docker/infrastructure roots

---

## Quick start

```bash
git clone git@github.com:filipmalecki94/claude-code-configs.git
cd claude-code-configs

# 1. Install global hooks and commands (all projects)
./install.sh --mode global

# 2. Install project-level config
./install.sh --mode nextjs /path/to/my-project
./install.sh --mode node-monorepo /path/to/monorepo
./install.sh --mode nextjs --mode docker /path/to/project
```

After installing, copy `.mcp.json.example` → `.mcp.json` and fill in your tokens.

---

## Global hooks

Installed to `~/.claude/hooks/` — active for every project.

| Script | Event | What it does | Deps |
|--------|-------|-------------|------|
| `terminal-state.sh` | All events | Changes terminal background color by session state | `OSC` escape codes |
| `model-selector.sh` | `UserPromptSubmit` | Injects model-tier guidance (Opus/Sonnet/Haiku); supports `!opus` force prefix | — |
| `validate-bash.sh` | `PreToolUse[Bash]` | Blocks destructive commands: `rm -rf`, `sudo rm`, `docker compose down -v`, force push to main, `chmod 777` | `jq` |
| `protect-files.sh` | `PreToolUse[Edit\|Write]` | Blocks edits to `.env*`, `package-lock.json`, `.git/*`, `node_modules/*` | `jq` |
| `check-secrets.sh` | `PreToolUse[Edit\|Write]` | Blocks writes containing secret patterns: `sk-ant-`, `PRIVATE KEY`, `ghp_`, `npm_` | `jq` |
| `plan-companion.sh` | `PostToolUse[Write]` | Auto-generates `PROGRESS.md` + `PROGRESS-PROMPT.md` when a `PLAN.md` is written | `jq` |
| `post-write.sh` | `PostToolUse[Edit\|Write]` | Runs linters after file writes: ESLint (JS/TS), Black (Python), jq validation (JSON), shellcheck (shell) | optional: `npx`, `black`, `jq`, `shellcheck` |
| `notification.sh` | `Notification` | Desktop notification when Claude is waiting for input | `notify-send` / `osascript` / `powershell.exe` |
| `prompt-editor.sh` | *(via `/edit` command)* | Intercepts prompts, proposes an improved version, asks for confirmation | `jq` |
| `statusline.sh` | *(statusLine)* | Shows three plan usage bars below the prompt: 5h session, 7d all models, 7d Sonnet only. Uses unofficial OAuth endpoint, cached 60s. | `jq`, `curl` |

### Terminal colors

| State | Color | Trigger |
|-------|-------|---------|
| `working` | dark blue `#0d1b2e` | Claude generating a response |
| `tool` | dark violet `#1a0a30` | Claude executing a tool |
| `waiting` | dark green `#0a2218` | Waiting for user input |
| `idle` | *(reset)* | Session end |

Compatible with: kitty, GNOME Terminal, WezTerm, iTerm2, Alacritty, tmux.

---

## Global commands

Installed to `~/.claude/commands/` — available as `/command` in every project.

| Command | Description |
|---------|-------------|
| `/search <query>` | Web search — fetches top results, returns structured summary with sources |
| `/summarize <text\|url>` | Summarize text, article, document, or URL |
| `/translate <text>` | Translate PL↔EN (auto-detect), or prefix with `DE:`, `FR:` etc. for other languages |
| `/explain <code\|concept>` | Explain code or a technical concept in plain language with analogies |
| `/edit <prompt>` | Rewrite a prompt to be more precise, then ask for confirmation before executing |
| `/no-edit` | Disable the prompt-editor hook (toggle off) |

---

## Config matrix

| Feature | global | nextjs | node-mono | wordpress | docker |
|---------|--------|--------|-----------|-----------|--------|
| Terminal state colors | ✓ | – | – | – | – |
| Model selector | ✓ | ✓ | – | ✓ | – |
| Bash safety guards | ✓ | ✓ | ✓ | ✓ | – |
| File protection | ✓ | ✓ | ✓ | ✓ | – |
| Secret detection | ✓ | ✓ | ✓ | – | – |
| Plan companion | ✓ | – | – | – | – |
| Usage limits statusline | ✓ | – | – | – | – |
| Post-write linters | ✓ | ✓ | – | ✓ | – |
| Desktop notifications | ✓ | – | – | – | – |
| npm publish guard | – | – | ✓ | – | – |
| PHP lint | – | – | – | ✓ | – |
| Docker compose validation | – | – | – | – | ✓ |
| Nginx validation | – | – | – | – | ✓ |

---

## Project configs

| Config | What it covers |
|--------|----------------|
| `nextjs` | ESLint auto-fix, secret detection, file protection, model selector, bash guards |
| `node-monorepo` | Workspace-aware TypeScript checks, secret detection, package publish guard, CLAUDE.md |
| `wordpress` | PHP lint, WP-CLI safety guards, SQL guards, Bedrock file protection, model selector |
| `docker` | Compose syntax/architecture validation, nginx config validation, model selector |

---

## Directory structure (`global/`)

```
global/
├── settings.json          # all hooks wired
├── hooks/
│   ├── terminal-state.sh  # session state → terminal background color
│   ├── model-selector.sh  # opus/sonnet/haiku guidance + !force prefix
│   ├── validate-bash.sh   # destructive command guard
│   ├── protect-files.sh   # env/lock/git file protection
│   ├── check-secrets.sh   # secret pattern detection
│   ├── plan-companion.sh  # PLAN.md → auto-generate PROGRESS.md
│   ├── post-write.sh      # linters after file writes
│   ├── notification.sh    # desktop notification on Stop
│   ├── prompt-editor.sh   # prompt rewriter (via /edit, not auto-wired)
│   └── statusline.sh      # usage limits: 5h session, 7d all, 7d sonnet
└── commands/
    ├── edit.md            # /edit — rewrite + confirm prompt
    ├── no-edit.md         # /no-edit — disable prompt editor
    ├── search.md          # /search — web search with summary
    ├── summarize.md       # /summarize — summarize text or URL
    ├── translate.md       # /translate — PL↔EN and other languages
    └── explain.md         # /explain — plain-language code/concept explainer
```

---

## Secrets

`.mcp.json` files contain API tokens — **never commit them**. Use `.mcp.json.example` as a template.
Both `.mcp.json` and `settings.local.json` are blocked by `.gitignore`.
