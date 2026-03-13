#!/usr/bin/env bash
set -euo pipefail

cd "$CLAUDE_PROJECT_DIR"

WARNINGS=""

# Check .env existence
if [[ ! -f .env ]]; then
  WARNINGS+="WARNING: .env file is missing. Copy .env.example to .env before starting services.\n"
else
  # Check for placeholder values that indicate unconfigured env
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    value=$(echo "$value" | xargs)  # trim whitespace
    case "$value" in
      change_me|change_me_root|generate_me|generate_a_long_random_string_here|changeme|your_*_here|REPLACE_ME|pk_test_xxx|sk_test_xxx|TODO)
        WARNINGS+="WARNING: $key still has placeholder value '$value' — update before starting services.\n"
        ;;
    esac
  done < .env
fi

# Output as additionalContext for Claude
if [[ -n "$WARNINGS" ]]; then
  printf '{"hookSpecificOutput":{"additionalContext":"%s"}}' "$(echo -e "$WARNINGS" | sed 's/"/\\"/g' | tr '\n' ' ')"
fi

exit 0
