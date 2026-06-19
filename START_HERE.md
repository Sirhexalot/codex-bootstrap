# Start Hier

Dieser Ordner ist noch kein fertiger Kunden-Agent. Er ist ein Bootstrap.

Wenn du diesen Ordner in Codex öffnest, soll der Agent zuerst die Bootstrap-Dateien lesen, dann dich interviewen und daraus einen echten Agenten für dein Projekt machen.

## Empfohlener erster Prompt

```text
Bitte initialisiere dieses Projekt als Kunden-Agent.
```

## Was dann passieren soll

Der Agent soll:

1. `AGENTS.md`, `project.yaml`, `Memory.md` und `.bootstrap/README.md` lesen
2. dich zu Nutzername, Agentenname, Zweck, Rolle, Land, Zeitzone, Sprache, Ton und Grenzen befragen
3. die finale `AGENTS.md` für dein Projekt schreiben
4. `project.yaml`, `docs/` und `Memory.md` auf deinen Kontext anpassen
5. die Standard-Automatisierung `Heartbeat` anlegen oder aktualisieren
6. dir zeigen, wie du Skills global oder projektbezogen installierst

## Werkbank zuerst

Falls die lokale Umgebung noch nicht vorbereitet ist:

macOS:

```bash
chmod +x ./setup-mac.sh
./setup-mac.sh
```

Windows:

```powershell
.\setup-windows.ps1
```

Diese Skripte installieren nur globale Werkbank-Tools. Codex selbst wird hier nicht installiert.
