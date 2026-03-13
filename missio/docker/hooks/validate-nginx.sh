#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run for nginx config files
case "$FILE" in
  *nginx/*.conf|*nginx/conf.d/*|*nginx/nginx.conf) ;;
  *) exit 0 ;;
esac

# Check if nginx container is running
if ! docker compose ps nginx --format '{{.State}}' 2>/dev/null | grep -q 'running'; then
  exit 0  # Nginx not running, skip validation
fi

# Validate nginx config
if ! OUTPUT=$(docker compose exec -T nginx nginx -t 2>&1); then
  echo "Nginx config validation FAILED after editing $FILE:" >&2
  echo "$OUTPUT" >&2
else
  echo "Nginx config validation passed." >&2
fi

exit 0
