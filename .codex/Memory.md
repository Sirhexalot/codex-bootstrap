# Codex Workspace Memory

## 2026-06-24 - Lokale Runtime-Einschränkungen

- Der Workspace ist nicht vorkonfiguriert mit einem Workspace-Office-Runtime-Bundle.
- Python ist über die normale Konsole aktuell nicht verfügbar.
- Die folgenden Node-Pakete sind aktuell nicht installiert: `mammoth`, `docx`, `xlsx`, `pptxgenjs`, `pdf-parse`.
- Folge für spätere Arbeit: Dokument- und Office-Automation darf nicht als sofort verfügbar angenommen werden und muss vor Nutzung explizit eingerichtet oder ersetzt werden.

## 2026-06-24 - `documents`-Bundle erweitert

- `install_tools` installiert im Bundle `documents` jetzt zusätzlich die Node-Pakete `mammoth`, `docx`, `xlsx`, `pptxgenjs` und `pdf-parse`.
- Das gilt für `global` und `project` Mode.
- Hintergrund: Diese Pakete waren im Projektlauf nicht vorkonfiguriert und sollen gezielt über den Bootstrap installierbar sein.

## 2026-06-24 - Windows-`pipx` ohne Leerzeichen festgelegt

- Das Windows-Bootstrap setzt für das `core`-Bundle jetzt standardmäßig `PIPX_HOME=C:\pipx` und `PIPX_BIN_DIR=C:\pipx\bin`, falls diese Variablen noch nicht gesetzt sind.
- Hintergrund: Benutzerprofile mit Leerzeichen wie `C:\Users\Andrea Kielmann\...` erzeugen bei `pipx ensurepath` irreführende Warnungen und können zu Inkompatibilitäten führen.

## 2026-06-24 - Install-CLI für Tools und Skills vereinheitlicht

- `install_tools` und `install_skills` verwenden jetzt öffentlich konsistent die Modi `global` und `project`.
- Auf macOS und Windows funktionieren für beide Install-Skripte dieselben offiziellen Formen: `global ...`, `project ...`, `--mode global ...`, `--mode project ...`.
- Unter PowerShell akzeptieren die Wrapper zusätzlich `-Mode ...`.
- Windows-`install_tools.ps1` fragt jetzt wie die Shell-Skripte nach dem Modus, wenn keiner übergeben wurde, statt still `global` zu wählen.
