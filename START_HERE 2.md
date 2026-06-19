# Willkommen

Schoen, dass du da bist. Dieser Ordner ist eine Vorlage fuer einen Codex-Kunden-Agenten.

Die Idee: Du kopierst diesen Ordner in ein neues Projekt, oeffnest ihn in Codex und laesst ihn in einen konkreten Agenten fuer einen Kunden, ein Team oder einen Use Case verwandeln.

## Schnellstart

Oeffne diesen Ordner in Codex und schreibe:

```text
Bitte initialisiere dieses Projekt als Kunden-Agent.
```

Codex soll dann die vorhandenen Dateien lesen und dich nur nach den Dingen fragen, die nicht aus dem Kontext erkennbar sind.

Alternativ kannst du die lokale Initialisierung starten:

macOS/Linux:

```bash
chmod +x ./scripts/init-project.sh
./scripts/init-project.sh
```

Windows:

```powershell
.\scripts\init-project.ps1
```

Diese Skripte veraendern nur Dateien in diesem Projektordner. Sie installieren keine globalen Tools und schreiben nicht in `~/.codex`.

## Was Danach Passiert

Der Agent sollte:

1. `project.yaml` ausfuellen.
2. `.bootstrap/manifest.json` aktualisieren.
3. Den verwalteten Bootstrap-Block in `AGENTS.md` aktualisieren.
4. `README.md` an den Kunden-Agenten anpassen.
5. `Memory.md` aktualisieren.
6. Kundendokumente unter `docs/` ergaenzen.
7. Die Standard-Automatisierung `automations/heartbeat/` anlegen.
8. Bei Bedarf weitere Automatisierungen unter `automations/` anlegen.
9. Bei Bedarf eigene Skills unter `skills/` vorbereiten.

## Standard-Heartbeat

Beim Projektstart wird eine Automatisierung namens `Heartbeat` vorbereitet.

Sie soll wochentags jede Stunde von 09:00 bis 17:00 lokaler Zeit laufen und pruefen, ob Projekt-Memory, Automatisierungs-Memories, Entscheidungen, offene Punkte und Dokumentation gepflegt sind.

Die Projektdateien fuer den Heartbeat liegen nach der Initialisierung unter:

```text
automations/heartbeat/
```

Die Vorlage legt die Automatisierung lokal an. Die tatsaechliche wiederkehrende Ausfuehrung muss anschliessend in Codex oder einem externen Scheduler aktiviert werden.

## Empfohlene Antworten Fuer Das Onboarding

Bereite, wenn moeglich, diese Informationen vor:

- Name des Kunden, Teams oder Projekts.
- Wobei der Agent helfen soll.
- Welche Tools oder Apps genutzt werden duerfen.
- Welche Daten sensibel sind.
- Welche Aufgaben zuerst automatisiert werden sollen.
- Welche Sprache und welcher Ton gewuenscht sind.

## Wichtig

Dieser Ordner fuehrt keine Aktionen automatisch beim Oeffnen aus. Das ist Absicht. Der Start passiert kontrolliert ueber deinen Auftrag an Codex.
