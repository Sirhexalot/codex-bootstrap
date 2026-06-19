# Tools Und Zugriffe

Diese Datei dokumentiert, welche Tools, Apps, Konten und MCP-Server fuer den Kunden-Agenten relevant sind.

## MCP-Server

- Memory MCP Server: `erforderlich fuer Langzeitgedaechtnis`
- MarkItDown MCP: `optional fuer Dokumentenverarbeitung`
- Weitere MCP-Server:
  - `Apple Calendar MCP: optional fuer Termine, Erinnerungen und Planung auf macOS`
  - `Apple Mail MCP: optional fuer E-Mail-bezogene Arbeitsablaeufe auf macOS`
  - `Teams MCP: vorgesehen fuer Microsoft-Teams- und Microsoft-Graph-Zugriff ueber floriscornel/teams-mcp`
  - `App- oder projektspezifische MCP-Server werden erst nach konkretem Use Case ergaenzt`

## Apps Und Externe Dienste

- Composio: `offen; wahrscheinlich zentrale Integrationsschicht fuer den Coworker`
- Google Workspace: `offen`
- Microsoft 365: `offen`
- Microsoft Teams: `vorgesehen; Teams MCP wird im Workstation-Setup registriert, Anmeldung erfolgt lokal per Microsoft Graph`
- Slack: `offen; moeglicher alternativer Coworker-Kanal`
- Weitere:
  - `GitHub: offen; relevant fuer Code-Aenderungen, Branches, Pull Requests und Reviews`
  - `CRM, Ads, Analytics, Kalender, Dokumente: offen; je nach erstem Coworker-Use-Case auswaehlen`

## Lokale Tools

- Codex CLI: `vermutlich installiert oder ueber Setup-Skripte installierbar`
- Node.js: `ueber Setup-Skripte installierbar`
- Python: `ueber Setup-Skripte installierbar`
- FFmpeg: `ueber Setup-Skripte installierbar`
- Weitere:
  - `Composio CLI: ueber Setup-Skripte installierbar`
  - `Meta Ads CLI: optional, falls Ads-Workflows gebraucht werden`

## Zugriffsregeln

- Externe Aktionen mit Wirkung auf Kunden, Daten oder Systeme muessen vorab bestaetigt werden.
- Zugangsdaten werden nicht in Projektdateien gespeichert.
- Offene Zugriffe werden in dieser Datei dokumentiert.
- Toolzugriffe sollen nach dem Prinzip "erst lesen, dann schreiben" eingefuehrt werden.
- Jede produktive Automatisierung muss dokumentieren, welche Quellen sie liest, welche Aktionen sie ausfuehrt und wann sie stoppen soll.

## Offene Zugriffe

- Coworker-Kanal klaeren: Codex-only, Slack, Microsoft Teams, E-Mail oder Kombination.
- Erste Toolgruppe klaeren: GitHub, Google Workspace, Slack, CRM, Ads, Analytics oder Kalender.
- Composio-Login und konkrete Toolkits pruefen, sobald der erste Use Case feststeht.
- Microsoft-Teams-Anmeldung abschliessen und klaeren, ob der Coworker nur lesen oder nach Freigabe auch schreiben soll.
