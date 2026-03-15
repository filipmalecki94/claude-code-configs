#!/usr/bin/env bash
# PreToolUse[Edit|Write] — wykrywa potencjalne sekrety w zapisywanej zawartości
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Dla Write sprawdź content, dla Edit sprawdź new_string
if [[ "$TOOL" == "Write" ]]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
elif [[ "$TOOL" == "Edit" ]]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
else
  exit 0
fi

if [[ -z "$CONTENT" ]]; then
  exit 0
fi

SECRET_PATTERNS=(
  'sk-ant-[a-zA-Z0-9]'
  'PRIVATE KEY'
  'ghp_[a-zA-Z0-9]'
  'npm_[a-zA-Z0-9]'
)

for PATTERN in "${SECRET_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE "$PATTERN"; then
    echo "BLOCKED: Plik może zawierać sekret pasujący do wzorca: '$PATTERN'" >&2
    exit 1
  fi
done
