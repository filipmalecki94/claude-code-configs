#!/usr/bin/env bash
# PostToolUse[Edit|Write] — uruchamia tsc --noEmit w odpowiednim workspace
set -euo pipefail

# Hooki Claude Code otrzymują JSON na stdin:
# { "tool_name": "Edit", "tool_input": { "file_path": "...", ... } }
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE" ]]; then
  exit 0
fi

# Uruchom typecheck tylko dla plików TypeScript
if [[ "$FILE" != *.ts && "$FILE" != *.tsx ]]; then
  exit 0
fi

if [[ "$FILE" == packages/server/* ]] || [[ "$FILE" == */packages/server/* ]]; then
  npx tsc --noEmit --project packages/server/tsconfig.json
elif [[ "$FILE" == packages/web/* ]] || [[ "$FILE" == */packages/web/* ]]; then
  npx tsc --noEmit --project packages/web/tsconfig.app.json
fi
