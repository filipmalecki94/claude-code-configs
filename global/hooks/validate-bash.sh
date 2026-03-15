#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# Block destructive rm patterns
if echo "$CMD" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?(/|\.{1,2}(/|$))'; then
  echo "Blocked: destructive rm command" >&2; exit 2
fi

# Block sudo rm
if echo "$CMD" | grep -qE 'sudo\s+rm'; then
  echo "Blocked: sudo rm is not allowed" >&2; exit 2
fi

# Block docker compose down -v (destroys named volumes)
if echo "$CMD" | grep -qiE 'docker\s+compose\s+down\s+-v'; then
  echo "Blocked: 'docker compose down -v' destroys volumes. Confirm with user first." >&2; exit 2
fi

# Block force push to main/master
if echo "$CMD" | grep -qE 'git\s+push\s+.*--force.*(main|master)'; then
  echo "Blocked: force push to main/master" >&2; exit 2
fi

# Block chmod 777
if echo "$CMD" | grep -qE 'chmod\s+(-R\s+)?777'; then
  echo "Blocked: chmod 777 is insecure" >&2; exit 2
fi

exit 0
