# Codex Agent Bootstrap

Diese Vorlage ist ein Startpunkt, um schnell verlaessliche Codex-Agenten fuer eigene Projekte, Teams oder Kunden aufzusetzen. Sie beschreibt, wie Agenten arbeiten sollen, welche Grundausstattung erwartet wird und wie Wissen dauerhaft dokumentiert wird.

## Ziel

- Neue Codex-Projekte schnell initialisieren.
- Diese Vorlage in einen konkreten Kunden-Agenten verwandeln.
- Wiederkehrende Agenten-Regeln zentral festhalten.
- Skills, MCP-Server, lokale Tools und Automatisierungen konsistent nutzbar machen.
- Arbeit so dokumentieren, dass andere Personen oder spaetere Agenten den Stand sofort verstehen.

<!-- CUSTOMER-AGENT-BOOTSTRAP:START -->
## Kunden-Agent Bootstrap

- Bootstrap: `codex-agent-bootstrap`
- Version: `0.1.0`
- Projektprofil: `project.yaml`
- Manifest: `.bootstrap/manifest.json`
- Projekt-Memory: `Memory.md`
- Standard-Heartbeat: `automations/heartbeat/`

Dieser Block darf von den Init- und Update-Skripten verwaltet werden. Manuelle projektbezogene Hinweise gehoeren ausserhalb dieses Blocks.
<!-- CUSTOMER-AGENT-BOOTSTRAP:END -->

## Onboarding-Ablauf

Wenn dieses Projekt frisch aus der Vorlage kopiert wurde, soll der Agent zuerst `START_HERE.md`, `project.yaml`, `Memory.md` und `docs/customer-context.md` lesen.

Der normale Startbefehl fuer Nutzer lautet:

```text
Bitte initialisiere dieses Projekt als Kunden-Agent.
```

Danach soll der Agent:

1. Den Zweck des Kunden-Agenten klaeren.
2. `project.yaml` mit Projektname, Kunde, Zweck, Sprache, Risiko und Status fuellen.
3. `README.md` von der generischen Setup-Beschreibung zur kundenbezogenen Projektbeschreibung weiterentwickeln.
4. `Memory.md` mit dem Initialisierungsstand aktualisieren.
5. `docs/customer-context.md`, `docs/tools-and-access.md` und `docs/decisions.md` ausfuellen oder offene Punkte markieren.
6. Die Standard-Automatisierung `Heartbeat` unter `automations/heartbeat/` anlegen, wenn sie noch fehlt.
7. Bei Bedarf weitere Automatisierungen aus `templates/automation-template/` nach `automations/<automation-name>/` kopieren.
8. Falls projektspezifische Arbeitsweisen wiederholt gebraucht werden, eine Skill-Vorlage aus `templates/skill-template/` nach `skills/<skill-name>/` kopieren.

## Grundprinzipien

- Lies zuerst die vorhandenen Projektdateien, bevor du Annahmen triffst.
- Arbeite mit bestehenden Konventionen statt neue Muster zu erfinden.
- Halte Aenderungen klein, nachvollziehbar und direkt am Ziel orientiert.
- Dokumentiere Entscheidungen, offene Fragen und naechste Schritte.
- Wenn du Dateien veraenderst, pruefe danach soweit moeglich, ob die Aenderung funktioniert.
- Gehe sorgsam mit bestehenden Nutzer- oder Team-Aenderungen um und ueberschreibe sie nicht ungefragt.

## Installation

Dieses Repository unterscheidet zwischen Rechner-Setup und Projektinitialisierung.

### Rechner-Setup

Die Root-Skripte richten die lokale Codex-Arbeitsumgebung ein. Sie duerfen globale Tools installieren und Codex-Konfiguration unter `~/.codex`, `~/.agents` oder aehnlichen Nutzerordnern veraendern.

macOS:

```bash
chmod +x ./setup-mac.sh
./setup-mac.sh
```

Windows:

```powershell
.\setup-windows.ps1
```

Nach der Installation:

1. Terminal oder PowerShell neu starten.
2. Codex neu starten.
3. Optional Tools pruefen:

```bash
codex --version
node --version
npm --version
composio whoami
```

### Projektinitialisierung

Die Skripte unter `scripts/` verwandeln den kopierten Ordner in einen konkreten Kunden-Agenten. Sie duerfen nur Dateien im aktuellen Projektordner veraendern.

macOS/Linux:

```bash
chmod +x ./scripts/init-project.sh
./scripts/init-project.sh
```

Windows:

```powershell
.\scripts\init-project.ps1
```

Regel:

- `setup-*` ist fuer die Werkbank.
- `scripts/init-project.*` ist fuer das Werkstueck.
- Kundenkontext, Automatisierungen und projektlokale Skills gehoeren in diesen Projektordner, nicht global nach `~/.codex`.

## Skills

Skills erweitern Codex um wiederverwendbare Arbeitsweisen. Dieses Bootstrap-Projekt installiert unter anderem Skills fuer Automatisierung, Composio, Design, Brand-Arbeit und Remotion.

Empfehlung fuer neue Projekte:

- Lege projektspezifische Skills nur an, wenn eine Arbeitsweise mehrfach gebraucht wird.
- Beschreibe in jedem Skill den Zweck, Ausloeser, Eingaben, Ablauf und erwartete Ergebnisse.
- Halte Skills knapp und praktisch. Ein Skill soll Arbeit fuehren, nicht ein Handbuch ersetzen.
- Verweise auf Skripte, Assets oder Vorlagen, statt grosse Code- oder Textbloecke zu duplizieren.

## MCP-Server

MCP-Server geben Codex Zugriff auf zusaetzliche Werkzeuge und Datenquellen. Dieses Bootstrap-Projekt richtet je nach Plattform mehrere MCP-Server ein, zum Beispiel Memory, MarkItDown und auf macOS Apple Mail und Apple Calendar.

Wichtige Regel:

- Nutze MCP-Server fuer echte externe Faehigkeiten oder dauerhaftes Wissen.
- Dokumentiere projektkritische MCP-Abhaengigkeiten in der README oder in projektspezifischen Agent-Anweisungen.

## Memory-Konzept

Wir nutzen drei Memory-Ebenen mit unterschiedlichen Aufgaben.

### 1. Memory-MCP-Server

Der Memory-MCP-Server ist das Langzeitgedaechtnis fuer wiederverwendbare Informationen. Er eignet sich fuer Fakten, Praeferenzen, stabile Projektkontexte und Beziehungen, die ueber einzelne Automatisierungen oder Arbeitssitzungen hinaus relevant bleiben.

Typische Inhalte:

- Stabile Nutzer- oder Team-Praeferenzen.
- Wiederkehrende Projektregeln.
- Wichtige System- oder Tool-Entscheidungen.
- Langfristig relevante Kontakte, Rollen oder Abhaengigkeiten.

### 2. Projektweite `Memory.md`

Die projektweite `Memory.md` ist das lokale Arbeitsgedaechtnis des konkreten Kunden-Agenten. Sie dokumentiert Projektstand, Entscheidungen, offene Punkte und wichtige Erkenntnisse dieses Ordners.

Typische Inhalte:

- Kundenkontext und Projektziel.
- Aktueller Setup-Status.
- Entscheidungen und Gruende.
- Offene Fragen, Risiken und naechste Schritte.
- Uebersicht ueber angelegte Automatisierungen und Skills.

### 3. `Memory.md` pro Automatisierung

Jede Automatisierung bekommt zusaetzlich eine eigene `Memory.md`. Diese Datei ist das laufbezogene Arbeitsgedaechtnis der Automatisierung und dokumentiert jeden Lauf.

Typische Inhalte:

- Laufdatum, Ausloeser und Ziel.
- Eingaben, Filter und verwendete Quellen.
- Entscheidungen und Zwischenergebnisse.
- Fehler, Warnungen und offene Fragen.
- Veraenderte Dateien, erstellte Artefakte oder ausgefuehrte Aktionen.
- Naechste Schritte fuer den folgenden Lauf.

Regeln fuer Memory:

- Die projektweite `Memory.md` wird bei jeder relevanten Projektveraenderung aktualisiert.
- Bei jedem Automatisierungslauf muss die jeweilige Automatisierungs-`Memory.md` aktualisiert werden.
- Der aktuelle Stand muss so dokumentiert sein, dass ein anderer Agent ohne Rueckfragen fortsetzen kann.
- Wichtige langfristige Erkenntnisse werden zusaetzlich im Memory-MCP-Server gespeichert, wenn sie ueber diese einzelne Automatisierung oder dieses Projekt hinaus relevant sind.

## Automatisierungsvorlagen

Neue Automatisierungen sollen aus `templates/automation-template/` kopiert werden. Die Vorlage enthaelt:

- `README.md`: Zweck, Voraussetzungen und Bedienung der Automatisierung.
- `Memory.md`: laufende Dokumentation und Arbeitsgedaechtnis.
- `Runbook.md`: Standardablauf, Checks, Fehlerbehandlung und Abschlusskriterien.

Vor jedem produktiven Einsatz sollte die Vorlage projektspezifisch angepasst werden.

Konkrete Automatisierungen liegen unter `automations/`.

## Standard-Heartbeat

Beim Projektstart soll eine Automatisierung namens `Heartbeat` angelegt werden.

- Pfad: `automations/heartbeat/`
- Takt: wochentags jede Stunde von 09:00 bis 17:00 lokaler Zeit.
- Zweck: pruefen, ob Root-`Memory.md`, Automatisierungs-Memories, Entscheidungen, offene Punkte, Runbooks und Projektdokumentation gepflegt wurden.
- Ergebnis: Heartbeat-`Memory.md` aktualisieren und bei projektweiten Erkenntnissen auch Root-`Memory.md` fortschreiben.
- Grenze: keine externen Aktionen, keine Tool-Installation, keine Schreibzugriffe nach `~/.codex` oder `~/.agents`.

## Projektstruktur

```text
customer-agent/
├─ AGENTS.md
├─ Memory.md
├─ README.md
├─ START_HERE.md
├─ project.yaml
├─ automations/
├─ docs/
├─ skills/
├─ templates/
└─ scripts/
```

## Agenten-Checkliste

Vor der Arbeit:

- Ziel und Kontext aus `START_HERE.md`, README, `AGENTS.md`, `project.yaml`, `Memory.md`, relevanten Skills und vorhandenen Dateien lesen.
- Pruefen, welche Tools, MCP-Server oder externen Apps wirklich gebraucht werden.
- Bestehenden Stand respektieren.

Waehrend der Arbeit:

- Kleine, nachvollziehbare Schritte machen.
- Wichtige Entscheidungen dokumentieren.
- Bei relevanten Projektveraenderungen die projektweite `Memory.md` fortschreiben.
- Bei Automatisierungen die jeweilige `Memory.md` fortschreiben.
- Langfristig relevante Informationen im Memory-MCP-Server sichern.

Nach der Arbeit:

- Ergebnis pruefen.
- Geaenderte Dateien und naechste Schritte benennen.
- Offene Risiken oder fehlende Tests klar notieren.
