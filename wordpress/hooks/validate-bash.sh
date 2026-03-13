#!/usr/bin/env bash
# Blokuj destrukcyjne komendy Bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# Destrukcyjne wzorce Docker
if echo "$COMMAND" | grep -qE 'docker compose down\s+.*-v|docker compose down\s+-v'; then
  echo "BLOCKED: 'docker compose down -v' destroys named volumes (database data!). Use 'docker compose down' without -v, or confirm with the user first." >&2
  exit 2
fi

# Destrukcyjne SQL
if echo "$COMMAND" | grep -qiE '(DROP\s+(TABLE|DATABASE)|TRUNCATE\s+TABLE)'; then
  echo "BLOCKED: Destructive SQL operation detected. Confirm with the user before running DROP/TRUNCATE." >&2
  exit 2
fi

# Katastrofalne usunięcia
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/|~|\$HOME|\.)(\s|$)'; then
  echo "BLOCKED: Catastrophic rm -rf detected. This would delete critical files." >&2
  exit 2
fi

# Force push do main/master
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force.*\s+(main|master)|git\s+push\s+--force\s+origin\s+(main|master)'; then
  echo "BLOCKED: Force push to main/master is not allowed. Use a feature branch." >&2
  exit 2
fi

# WP-CLI reset bazy
if echo "$COMMAND" | grep -qE 'wp\s+db\s+reset'; then
  echo "BLOCKED: 'wp db reset' destroys the entire database. Use 'wp db export' first, then confirm with the user." >&2
  exit 2
fi

exit 0
