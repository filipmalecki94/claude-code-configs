#!/usr/bin/env bash
# Blokuj edycję plików zarządzanych przez Composer i plików z sekretami
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

# Normalizuj ścieżkę do relatywnej
REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"

BLOCKED=false
REASON=""

case "$REL_PATH" in
  vendor/*)
    BLOCKED=true
    REASON="vendor/ is Composer-managed. Run 'composer require' to change dependencies."
    ;;
  web/wp/*)
    BLOCKED=true
    REASON="web/wp/ is WordPress core (Composer-managed). Never edit directly."
    ;;
  web/app/plugins/*)
    BLOCKED=true
    REASON="web/app/plugins/ contains Composer-managed plugins. Edit mu-plugins instead: web/app/mu-plugins/"
    ;;
  composer.lock)
    BLOCKED=true
    REASON="composer.lock is auto-generated. Run 'composer update' to regenerate."
    ;;
  .env)
    BLOCKED=true
    REASON="Do not edit .env directly via Claude. Edit .env.example for templates, or ask the user to update .env manually."
    ;;
esac

if [ "$BLOCKED" = true ]; then
  echo "BLOCKED: $REASON" >&2
  exit 2
fi

exit 0
