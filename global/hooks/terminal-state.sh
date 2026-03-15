#!/bin/bash
# terminal-state.sh — Dynamically changes terminal background color based on Claude Code state
#
# Usage: terminal-state.sh <state>
# States: working | tool | waiting | idle
#
# working  → dark blue     (Claude is generating a response)
# tool     → dark purple   (Claude is executing a tool)
# waiting  → dark green    (Claude finished, waiting for user)
# idle     → reset default (session start/end)
#
# Compatible with: kitty, GNOME Terminal, WezTerm, iTerm2, Alacritty, and tmux.

STATE="${1:-idle}"

write_to_tty() {
    local seq="$1"
    # Open /dev/tty explicitly — works even when stdin/stdout are redirected (as in hooks)
    { exec 3>/dev/tty && printf "%s" "$seq" >&3 && exec 3>&-; } 2>/dev/null || true
}

set_terminal_bg() {
    local color="$1"
    local seq

    if [ -n "$TMUX" ]; then
        # tmux: wrap OSC sequence with DCS passthrough
        seq=$'\033Ptmux;\033\033]11;'"$color"$'\007\033\\'
    else
        seq=$'\033]11;'"$color"$'\007'
    fi

    write_to_tty "$seq"
}

reset_terminal_bg() {
    local seq

    if [ -n "$TMUX" ]; then
        seq=$'\033Ptmux;\033\033]111;\007\033\\'
    else
        seq=$'\033]111;\007'
    fi

    write_to_tty "$seq"
}

case "$STATE" in
    "working")
        # Dark navy blue — Claude is thinking / generating a response
        set_terminal_bg "#0d1b2e"
        ;;
    "tool")
        # Dark violet/purple — Claude is executing a tool (Bash, Read, Edit...)
        set_terminal_bg "#1a0a30"
        ;;
    "waiting")
        # Dark green — Claude finished, waiting for user input
        set_terminal_bg "#0a2218"
        ;;
    "idle"|*)
        # Restore the original terminal background color
        reset_terminal_bg
        ;;
esac

exit 0
