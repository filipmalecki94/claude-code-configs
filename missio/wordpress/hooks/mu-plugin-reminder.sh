#!/usr/bin/env bash
# Przypomnienie o testach po edycji mu-pluginów
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

# Tylko pliki w mu-plugins
if echo "$FILE_PATH" | grep -q 'mu-plugins/.*\.php$'; then
  echo "mu-plugin modified: consider running /test to generate/update tests and /review for code review."
fi

exit 0
