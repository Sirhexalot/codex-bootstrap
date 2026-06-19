# Bootstrap Einstieg

Dieses Repository ist eine Bootstrap-Vorlage für kluge Codex-Agenten.

Wenn dieses Projekt noch nicht für einen konkreten Nutzer initialisiert wurde, arbeite in genau dieser Reihenfolge:

1. Lies [START_HERE.md](/Users/adrian/Desktop/Codex%20Setup/START_HERE.md).
2. Lies [project.yaml](/Users/adrian/Desktop/Codex%20Setup/project.yaml).
3. Lies [Memory.md](/Users/adrian/Desktop/Codex%20Setup/Memory.md).
4. Lies [.bootstrap/README.md](/Users/adrian/Desktop/Codex%20Setup/.bootstrap/README.md).
5. Lies danach die in `.bootstrap/README.md` genannten Bootstrap-Dateien.

## Bootstrap-Regel

- Die generische Bootstrap-Logik lebt unter `.bootstrap/`.
- Die sichtbaren Skripte unter `scripts/` sind nur Einstiegspunkte.
- Während der Initialisierung sollst du den Nutzer interviewen und daraus das eigentliche Projekt erzeugen.
- Nach erfolgreicher Initialisierung wird diese Datei durch eine projektspezifische `AGENTS.md` ersetzt.

## Was Du Beim Onboarding Erheben Sollst

- Name des Nutzers
- Name des Agenten
- Projektname
- Zweck und Rolle des Agenten
- Land
- Zeitzone
- Sprache und Ton
- sensible Grenzen und No-Gos
- wichtige Tools, Systeme oder Kanäle

## Skill-Regel

- Tools gehören zur globalen Werkbank.
- Skills kommen immer aus Original-Repositories.
- Bei Skill-Installationen muss zwischen `global` und `projektbezogen` gewählt werden.

## Wichtige Skripte

- `./setup-mac.sh`
- `./setup-windows.ps1`
- `./scripts/init-project.sh`
- `./scripts/init-project.ps1`
- `./scripts/install_skills.sh`
- `./scripts/update_skills.sh`
- `./scripts/list_skills.sh`
