#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file')

case "$FILE" in
  *.env|*.env.*|*/.env|*/.env.*) echo "Blocked: cannot edit env file $FILE" >&2; exit 2 ;;
  */package-lock.json)   echo "Blocked: package-lock.json is auto-generated" >&2; exit 2 ;;
  */.git/*)              echo "Blocked: cannot edit .git internals" >&2; exit 2 ;;
  */node_modules/*)      echo "Blocked: cannot edit node_modules" >&2; exit 2 ;;
esac
exit 0
