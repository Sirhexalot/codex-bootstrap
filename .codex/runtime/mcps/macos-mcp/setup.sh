#!/usr/bin/env bash
set -euo pipefail

open_permissions() {
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
}

case "${1:-}" in
  --open-permissions)
    open_permissions
    ;;
  --check)
    exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check.sh"
    ;;
  --verify-jxa)
    exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/verify-jxa.sh"
    ;;
  --reveal-node)
    exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/reveal-node-for-fda.sh"
    ;;
esac

cat <<'MSG'
macos-mcp setup helpers:

- ./run.sh
  Startet den MCP-Server via npx.

- ./check.sh
  Führt den eingebauten Preflight von macos-mcp aus.

- ./verify-jxa.sh
  Führt die einzelnen osascript-Checks für Contacts, Calendar, Reminders, Mail und Notes aus.
  Das ist der Schritt, bei dem macOS bei fehlenden Automation-Rechten die Dialoge anzeigen kann.

- ./reveal-node-for-fda.sh
  Zeigt das echte Node-Binary im Finder und öffnet Full Disk Access.

- ./setup.sh --open-permissions
  Öffnet die relevanten macOS-Einstellungsseiten.

Wichtig:
- Automation-Dialoge können nur in einer lokalen GUI-Session erscheinen.
- Wenn ein osascript-Aufruf hängt, wartet macOS meist auf einen nicht sichtbaren Dialog.
- Full Disk Access muss für das echte Node-Binary oder die Terminal-App gesetzt sein.
MSG
