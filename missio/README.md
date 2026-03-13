# missio

Claude Code configs for the missio-docker project — headless e-commerce platform (WordPress Bedrock + WooCommerce + Next.js 15).

## Install

```bash
# From the claude-code-configs root:
./install.sh /path/to/missio-docker
```

## Subdirectories

| Dir | Target | Contents |
|-----|--------|----------|
| `docker/` | `missio-docker/.claude/` | Docker hooks, dc-* commands, infra agents |
| `nextjs/` | `missio-docker/nextjs/.claude/` | Next.js hooks, page/component commands, frontend agents |
| `wordpress/` | `missio-docker/wordpress/.claude/` | PHP hooks, WP commands, DDD/WooCommerce agents |

## Post-install

Copy and fill in secrets:

```bash
cp missio/docker/.mcp.json.example /path/to/missio-docker/.mcp.json
cp missio/nextjs/.mcp.json.example /path/to/missio-docker/nextjs/.mcp.json
cp missio/wordpress/.mcp.json.example /path/to/missio-docker/wordpress/.mcp.json
```

Required tokens:
- `GITHUB_PERSONAL_ACCESS_TOKEN` — GitHub PAT (generate at https://github.com/settings/tokens)
- `MYSQL_PASS` — matches `DB_PASSWORD` in your `.env`
- `mcp-server-mysql` path — adjust to your local install path
