#!/bin/bash
# prompt-editor.sh — UserPromptSubmit hook
# Przechwytuje prompty użytkownika i zleca Claude ich redakcję + potwierdzenie.
# Wyłącz: touch ~/.claude/prompt-editor-disabled
# Włącz:  rm ~/.claude/prompt-editor-disabled

set -euo pipefail

input=$(cat)
original_prompt=$(echo "$input" | jq -r '.prompt')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# 1. Wyłączony flagą
[[ -f "$HOME/.claude/prompt-editor-disabled" ]] && exit 0

# 2. Slash commands — przepuszczamy bez zmian
[[ "$original_prompt" == /* ]] && exit 0

# 3. Bardzo krótkie odpowiedzi (odpowiedź na pytanie Claude) — pomijamy
word_count=$(echo "$original_prompt" | wc -w)
if [[ "$word_count" -le 3 ]]; then
    lower=$(echo "$original_prompt" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
    case "$lower" in
        tak|nie|yes|no|ok|okay|y|n|1|2|"tak ok"|"nie ok"|"tak zgadzam"|"nie dzieki")
            exit 0
            ;;
    esac
fi

# 4. Sprawdź czy ostatnia wiadomość Claude zawiera nasz marker potwierdzenia
#    (żeby nie przechwycić odpowiedzi użytkownika na pytanie o akceptację)
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    # Szukamy markera w ostatniej wiadomości asystenta
    last_assistant_content=$(
        jq -r 'select(.role == "assistant") | .content' "$transcript_path" 2>/dev/null \
        | tail -1
    )
    if echo "$last_assistant_content" | grep -q "PROMPT_EDITOR_CONFIRM"; then
        exit 0
    fi
fi

# 5. Budujemy meta-prompt — Claude wykona redakcję i zapyta o potwierdzenie
meta_prompt=$(cat <<METAPROMPT
[PROMPT_EDITOR_ACTIVE]

Twoje zadanie PRZED wykonaniem właściwego polecenia:

**Krok 1 — Zredaguj prompt**
Zredaguj poniższy ORYGINALNY PROMPT tak, aby był bardziej precyzyjny, zrozumiały i skuteczny dla Claude Code. Zachowaj intencję, ale:
- popraw gramatykę i styl
- dodaj brakujący kontekst (jeśli jest oczywisty)
- rozbij na wyraźne kroki jeśli prompt jest złożony
- usuń niejasności

**Krok 2 — Pokaż obie wersje**
Wyświetl w czytelnym formacie:
- 📝 ORYGINALNY: (wklej oryginalny prompt)
- ✨ ZREDAGOWANY: (wklej zredagowaną wersję)

**Krok 3 — Zapytaj o akceptację**
Napisz dokładnie: "PROMPT_EDITOR_CONFIRM: Czy akceptujesz zredagowaną wersję? Odpowiedz **tak** (wykonam zredagowany) lub **nie** (wykonam oryginalny)."

**Krok 4 — Poczekaj na odpowiedź i wykonaj**
Na podstawie odpowiedzi użytkownika wykonaj odpowiednią wersję promptu.

---
ORYGINALNY PROMPT:
$original_prompt
METAPROMPT
)

# Zwracamy zmodyfikowany prompt jako JSON
printf '%s' "$meta_prompt" | jq -Rs '{"prompt": .}'
