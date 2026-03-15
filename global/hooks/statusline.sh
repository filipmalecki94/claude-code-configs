#!/bin/bash
# Claude Code Statusline — Usage Limits
# Displays: 5h session | 7d all models | 7d Sonnet only

CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=60  # refresh every 60 seconds

# Refresh cache if stale
NOW=$(date +%s)
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( NOW - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
else
    CACHE_AGE=9999
fi

if [ "$CACHE_AGE" -gt "$CACHE_TTL" ]; then
    TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' ~/.claude/.credentials.json 2>/dev/null)
    if [ -n "$TOKEN" ]; then
        curl -sf "https://api.anthropic.com/api/oauth/usage" \
            -H "Authorization: Bearer $TOKEN" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -o "$CACHE_FILE" 2>/dev/null
    fi
fi

# Parse values
if [ -f "$CACHE_FILE" ]; then
    FIVE_H=$(jq '.five_hour.utilization // 0 | floor' "$CACHE_FILE" 2>/dev/null || echo 0)
    SEVEN_D=$(jq '.seven_day.utilization // 0 | floor' "$CACHE_FILE" 2>/dev/null || echo 0)
    SONNET=$(jq '(.seven_day_sonnet.utilization // 0) | floor' "$CACHE_FILE" 2>/dev/null || echo 0)
else
    FIVE_H=0; SEVEN_D=0; SONNET=0
fi

# Progress bar: 10 chars wide
bar() {
    local pct=$1
    local width=10
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
}

# Color by percentage
color() {
    local pct=$1
    if   [ "$pct" -ge 80 ]; then printf '\033[31m'   # red
    elif [ "$pct" -ge 50 ]; then printf '\033[33m'   # yellow
    else                         printf '\033[32m'   # green
    fi
}

R='\033[0m'

c5=$(color "$FIVE_H")
c7=$(color "$SEVEN_D")
cs=$(color "$SONNET")

printf "${c5}5h $(bar $FIVE_H) ${FIVE_H}%%${R}  ${c7}7d $(bar $SEVEN_D) ${SEVEN_D}%%${R}  ${cs}son $(bar $SONNET) ${SONNET}%%${R}\n"
