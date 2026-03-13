#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Nothing to check if no command
[[ -z "$COMMAND" ]] && exit 0

# Block: docker compose down -v / --volumes
if echo "$COMMAND" | grep -qE 'docker\s+compose\s+down\s+.*((-v\b)|(--volumes))'; then
  echo "BLOCKED: 'docker compose down -v' destroys all named volumes (database, uploads). Ask the user for explicit confirmation first." >&2
  exit 2
fi

# Block: git push --force (or --force-with-lease) to master
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f|--force|--force-with-lease)' && echo "$COMMAND" | grep -qE '\bmaster\b'; then
  echo "BLOCKED: Force-pushing to master can destroy remote history. This requires explicit user approval." >&2
  exit 2
fi

# Block: git reset --hard (without user intent)
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: 'git reset --hard' discards uncommitted changes permanently. Ask the user first." >&2
  exit 2
fi

# Block: catastrophic rm (root, current dir, parent dir, wildcard)
if echo "$COMMAND" | grep -qE 'rm\s+-[rR]f\s+(/($|\s)|\.($|\s)|\.\.($|\s)|\*($|\s))'; then
  echo "BLOCKED: Catastrophic delete detected (target: /, ., .., or *). This would remove critical files." >&2
  exit 2
fi

exit 0
