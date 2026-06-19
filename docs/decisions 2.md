# Entscheidungen

Diese Datei haelt wichtige Projektentscheidungen fest.

## Entscheidungsvorlage

### YYYY-MM-DD - `<Titel>`

- Entscheidung: `<Was wurde entschieden?>`
- Grund: `<Warum?>`
- Alternativen: `<Was wurde verworfen?>`
- Auswirkungen: `<Was aendert sich dadurch?>`
- Status: `<aktiv, offen, ersetzt>`

## Entscheidungen

### 2026-06-04 - Bootstrap Wird Zum Kunden-Agenten

- Entscheidung: Diese Vorlage soll nach dem Kopieren in einen konkreten Kunden-Agenten umgewandelt werden.
- Grund: Nutzer sollen schneller von einer generischen Vorlage zu einem arbeitsfaehigen Agenten kommen.
- Alternativen: Reine Setup-Vorlage ohne Onboarding-Struktur.
- Auswirkungen: Es gibt `START_HERE.md`, `project.yaml`, `docs/`, `automations/`, `skills/` und klare Memory-Ebenen.
- Status: `aktiv`

### 2026-06-04 - Zielbild AI-Coworker

- Entscheidung: Dieses Projekt wird auf einen AI-Coworker ausgerichtet, nicht nur auf einen Chat- oder Prompt-Assistenten.
- Grund: Der Nutzer moechte am Ende "quasi einen Coworker" haben. Das Zielbild betont Toolnutzung, echte Outputs, Automatisierungen, Recherche, App-/Code-Arbeit und Teamfaehigkeit.
- Alternativen: Reiner persoenlicher Chat-Assistent oder reine Setup-Vorlage ohne konkretes Zielbild.
- Auswirkungen: Projektidentitaet, Kundenkontext und Tool-Dokumentation betonen Memory, Integrationen, Artefakte, Automatisierungen und klare Freigabegrenzen fuer externe Aktionen.
- Status: `aktiv`

### 2026-06-04 - Microsoft Teams MCP Aufnehmen

- Entscheidung: `floriscornel/teams-mcp` wird als Microsoft-Teams- und Microsoft-Graph-MCP in das Workstation-Setup aufgenommen.
- Grund: Microsoft Teams ist ein naheliegender Coworker-Kanal und soll direkt aus Codex heraus angebunden werden koennen.
- Alternativen: Nur Composio fuer Teams nutzen oder Teams erst spaeter manuell konfigurieren.
- Auswirkungen: `setup-mac.sh` und `setup-windows.ps1` registrieren `teams_mcp` in `~/.codex/config.toml`; die Microsoft-Anmeldung bleibt lokal im Nutzerkonto und wird nicht im Repository gespeichert.
- Status: `aktiv`
