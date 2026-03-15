#!/usr/bin/env bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty')

[[ -z "$FILE" ]] && exit 0

case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
    if command -v npx >/dev/null 2>&1; then
      npx eslint --fix "$FILE" 2>/dev/null || true
    fi
    ;;
  *.py)
    if command -v black >/dev/null 2>&1; then
      black --quiet "$FILE" 2>/dev/null || true
    fi
    ;;
  *.json)
    if ! jq empty "$FILE" 2>/dev/null; then
      echo "Ostrzeżenie: $FILE zawiera nieprawidłowy JSON" >&2
    fi
    ;;
  *.sh)
    if command -v shellcheck >/dev/null 2>&1; then
      shellcheck "$FILE" 2>/dev/null || true
    fi
    ;;
esac

exit 0
