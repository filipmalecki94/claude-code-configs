#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run for compose files
case "$FILE" in
  *docker-compose*.yml|*docker-compose*.yaml) ;;
  *) exit 0 ;;
esac

# Validate compose syntax
if ! OUTPUT=$(docker compose config --quiet 2>&1); then
  echo "docker-compose validation FAILED after editing $FILE:" >&2
  echo "$OUTPUT" >&2
  exit 0  # Non-blocking — Claude sees the feedback
fi

# Check for port exposure violations (non-nginx services)
PORTS_VIOLATIONS=$(docker compose config 2>/dev/null | grep -B5 'ports:' | grep -E '^\s+\w+:' | grep -v 'nginx' | grep -v 'mailpit' || true)
if [[ -n "$PORTS_VIOLATIONS" ]]; then
  echo "WARNING: Non-nginx/mailpit services have external ports exposed. Only nginx should expose ports (80/443). Check: $PORTS_VIOLATIONS" >&2
fi

exit 0
