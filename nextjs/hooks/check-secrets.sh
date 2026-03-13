#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')

# Only check client-facing files
case "$FILE" in
  */components/*|*/app/*) ;; # check these
  *) exit 0 ;;               # skip server-only files like lib/api/
esac

# Allow Server Actions and server-only files (actions.ts, route.ts)
case "$FILE" in
  */actions.ts|*/actions.tsx|*/route.ts|*/route.tsx) exit 0 ;;
esac
# If the content being written contains 'use server', it's a Server Action — allow
if echo "$CONTENT" | grep -qE "^['\"]use server['\"]"; then
  exit 0
fi
# If the file already contains 'use server', allow
if [ -f "$FILE" ] && head -5 "$FILE" | grep -qE "^['\"]use server['\"]"; then
  exit 0
fi

# Check for secret env var references in content being written
# Catch: process.env.SECRET, process.env["SECRET"], { SECRET } = process.env, bare SECRET_NAME
SECRETS="STRIPE_SECRET_KEY|JWT_AUTH_SECRET_KEY|NEXTAUTH_SECRET|STRIPE_WEBHOOK_SECRET"
if echo "$CONTENT" | grep -qE "(process\.env[\.\[\"'\`]*(${SECRETS})|[\{\s,](${SECRETS})\s*[,\}\s].*process\.env|\b(${SECRETS})\b)"; then
  # Double-check: skip if it's in a comment or type definition
  if echo "$CONTENT" | grep -qE "^\s*//" || echo "$CONTENT" | grep -qE "^\s*\*"; then
    exit 0
  fi
  echo "Blocked: secret env var reference in client-accessible file $FILE" >&2
  exit 2
fi

exit 0
