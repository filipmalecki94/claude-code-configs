#!/usr/bin/env bash
# PreToolUse[Edit|Write] — blokuje modyfikację chronionych plików
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE" ]]; then
  exit 0
fi

PROTECTED=("PLAN.md" "PLAN-CLAUDE-CODE-CONFIGS.md" "LICENSE" "package-lock.json")

for PROTECTED_FILE in "${PROTECTED[@]}"; do
  if [[ "$FILE" == *"$PROTECTED_FILE" ]]; then
    echo "BLOCKED: $FILE jest plikiem chronionym i nie może być modyfikowany przez Claude." >&2
    exit 1
  fi
done
