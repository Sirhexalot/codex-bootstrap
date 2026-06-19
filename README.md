# Codex Agent Bootstrap

Dieses Repository ist ein Startpaket, das du einem Freund, Team oder Kunden geben kannst, damit daraus ein sauber aufgesetzter Codex-Agent entsteht.

Die Idee ist bewusst zweistufig:

1. Die Root-Setup-Skripte richten die Werkbank global ein.
2. Die Projektinitialisierung verwandelt diesen Ordner in einen konkreten Agenten mit eigener Identität, eigener `AGENTS.md` und eigenen Projektdokumenten.

## Was Dieses Repository Leisten Soll

- Einen neuen Agenten schnell startklar machen
- globale Werkbank-Tools auf macOS und Windows vorbereiten
- ein strukturiertes Onboarding für den eigentlichen Agenten liefern
- Skills aus Original-Repositories installierbar und updatebar machen
- die spätere Projektstruktur sauber halten, indem Bootstrap-Interna unter `.bootstrap/` liegen

## Schnellstart

### 1. Werkbank global vorbereiten

macOS:

```bash
chmod +x ./setup-mac.sh
./setup-mac.sh
```

Windows:

```powershell
.\setup-windows.ps1
```

Diese Skripte installieren nur globale Werkbank-Tools. Sie installieren **kein Codex**, keine projektbezogenen Dateien und keine Skills.

### 2. Projekt in Codex öffnen

Öffne den Ordner in Codex und schreibe:

```text
Bitte initialisiere dieses Projekt als Kunden-Agent.
```

Der Agent soll dann:

- zuerst die Bootstrap-Dateien lesen
- ein Interview führen
- die Projektidentität erfassen
- die finale `AGENTS.md` schreiben
- `project.yaml`, `Memory.md`, `docs/` und `automations/heartbeat/` passend ausfüllen

### 3. Skills bewusst installieren

Die Skill-Skripte fragen immer nach dem Zielmodus:

- `global`
- `projektbezogen`

Verfügbare Befehle:

```bash
./scripts/install_skills.sh
./scripts/update_skills.sh
./scripts/list_skills.sh
```

## Struktur

```text
bootstrap-agent/
├─ .bootstrap/
├─ AGENTS.md
├─ Memory.md
├─ README.md
├─ START_HERE.md
├─ project.yaml
├─ automations/
├─ docs/
├─ scripts/
├─ skills/
├─ setup-mac.sh
└─ setup-windows.ps1
```

## Trennung der Verantwortlichkeiten

### Globale Werkbank

- `setup-mac.sh`
- `setup-windows.ps1`

Installieren globale Werkzeuge wie Python, Node, Git, FFmpeg, ImageMagick, Ghostscript, `pipx`, `pnpm` und Playwright.

### Bootstrap-Interna

- `.bootstrap/`

Enthält Vorlagen, Metadaten, Skill-Kataloge und Hilfslogik für Initialisierung und Skill-Verwaltung.

### Sichtbare Projekt-Skripte

- `scripts/init-project.sh`
- `scripts/init-project.ps1`
- `scripts/install_skills.sh`
- `scripts/update_skills.sh`
- `scripts/list_skills.sh`

Das sind schlanke Einstiegspunkte. Die eigentliche Logik liegt unter `.bootstrap/`.

## Skill-Prinzip

- Skills immer aus Original-Repositories
- Tools immer global
- Skills pro Installationslauf ausdrücklich `global` oder `projektbezogen`
- größere projektspezifische Skill-Sammlungen landen versteckt unter `.bootstrap/skills-cache/`, damit der sichtbare Projektordner sauber bleibt

## Nach der Initialisierung

Nach dem ersten Onboarding gehört die sichtbare `AGENTS.md` vollständig dem konkreten Agentenprojekt.

Die Bootstrap-Regeln bleiben nur noch unter `.bootstrap/`, damit der neue Nutzer einen klaren, nicht überladenen Projektarbeitsbereich hat.
