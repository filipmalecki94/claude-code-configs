#!/bin/bash
# PostToolUse hook: when PLAN.md is created, auto-generate PROGRESS.md and PROGRESS-PROMPT.md

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Trigger only on Write tool creating a PLAN.md file
if [ "$TOOL_NAME" != "Write" ] || [[ "$FILE_PATH" != */PLAN.md ]]; then
    exit 0
fi

DIR=$(dirname "$FILE_PATH")

# Create PROGRESS.md only if it doesn't already exist
if [ ! -f "$DIR/PROGRESS.md" ]; then
    cat > "$DIR/PROGRESS.md" << 'EOF'
# Progress

## ✅ Zrobione
<!-- Lista ukończonych etapów i zadań -->

## ⏭️ Pominięte
<!-- Lista pominiętych elementów wraz z uzasadnieniem -->

## 📋 Aktualny etap
Etap 1
EOF
fi

# Always regenerate PROGRESS-PROMPT.md when PLAN.md is (re)created
PLAN_CONTENT=$(cat "$FILE_PATH")

cat > "$DIR/PROGRESS-PROMPT.md" << HEREDOC
# Prompt dla Claude Code — Etap 1

Realizujesz **Etap 1** z planu zawartego w \`PLAN.md\`.

## Treść planu

\`\`\`markdown
$PLAN_CONTENT
\`\`\`

## Twoje zadanie

1. Zrealizuj **Etap 1** zgodnie z planem powyżej.
2. Po ukończeniu edytuj plik \`PROGRESS.md\`:
   - **Zrobione** — co zostało zrealizowane w tym etapie
   - **Pominięte** — co pominąłeś i dlaczego
   - **Aktualny etap** — zmień na "Etap 2"
3. Nadpisz \`PROGRESS-PROMPT.md\` nowym promptem dla Etapu 2 (skopiuj ten szablon, zmień numer etapu i dostosuj opis zadania).

## Uwagi
- Trzymaj się zakresu etapu — nie rób z góry kolejnych kroków
- Jeśli coś jest niejasne w planie, zapytaj przed realizacją
HEREDOC

echo "✅ Utworzono PROGRESS.md i PROGRESS-PROMPT.md w $DIR" >&2
