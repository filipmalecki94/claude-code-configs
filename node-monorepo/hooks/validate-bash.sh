#!/usr/bin/env bash
# PreToolUse[Bash] — blokuje niebezpieczne komendy
set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$CMD" ]]; then
  exit 0
fi

BLOCKED_PATTERNS=("rm -rf" "git push --force" "npm publish" "chmod -R 777")

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$CMD" | grep -qF "$PATTERN"; then
    echo "BLOCKED: Komenda zawiera niedozwolony wzorzec: '$PATTERN'" >&2
    exit 1
  fi
done
