#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file')

# Only lint TS/TSX files
case "$FILE" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Run ESLint fix silently (don't block on lint warnings)
# Use eslint directly — `next lint --fix` does not pass --fix to ESLint
npx eslint --fix "$FILE" 2>/dev/null || true
exit 0
