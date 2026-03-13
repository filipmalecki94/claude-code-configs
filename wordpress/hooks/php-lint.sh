#!/usr/bin/env bash
# PHP syntax check po zapisie/edycji pliku
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

# Tylko pliki PHP
if ! echo "$FILE_PATH" | grep -q '\.php$'; then
  exit 0
fi

# Sprawdź czy plik istnieje
[ ! -f "$FILE_PATH" ] && exit 0

# Sprawdź czy PHP jest dostępne na hoście i w wymaganej wersji (>= 8.4)
if ! command -v php &>/dev/null; then
  echo "WARNING: php not found on host — skipping syntax check. Run lint inside the Docker container." >&2
  exit 0
fi

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;' 2>/dev/null || echo "0.0")
PHP_MAJOR="${PHP_VERSION%%.*}"
PHP_MINOR="${PHP_VERSION#*.}"

if [ "$PHP_MAJOR" -lt 8 ] || { [ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 4 ]; }; then
  echo "WARNING: Host PHP version $PHP_VERSION < 8.4 — skipping syntax check. Project requires PHP 8.4." >&2
  exit 0
fi

# PHP lint
LINT_OUTPUT=$(php -l "$FILE_PATH" 2>&1)
LINT_EXIT=$?

if [ $LINT_EXIT -ne 0 ]; then
  echo "PHP SYNTAX ERROR in $FILE_PATH:" >&2
  echo "$LINT_OUTPUT" >&2
  exit 2
fi

exit 0
