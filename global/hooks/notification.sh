#!/usr/bin/env bash
TITLE="Claude Code"
MESSAGE="Czeka na Twoją odpowiedź"

if command -v notify-send >/dev/null 2>&1; then
  notify-send -i dialog-information "$TITLE" "$MESSAGE"
elif command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms;
    \$n = New-Object System.Windows.Forms.NotifyIcon;
    \$n.Icon = [System.Drawing.SystemIcons]::Information;
    \$n.Visible = \$true;
    \$n.ShowBalloonTip(3000, '$TITLE', '$MESSAGE', [System.Windows.Forms.ToolTipIcon]::Info);
    Start-Sleep -Milliseconds 3500;
    \$n.Dispose()
  " 2>/dev/null || true
fi

exit 0
