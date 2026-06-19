# Skripte

Hier koennen Hilfsskripte fuer Initialisierung, Validierung oder wiederkehrende lokale Aufgaben liegen.

Vorhandene Skripte:

- `init-project.sh`: macOS/Linux-Initialisierung eines Kunden-Agenten.
- `init-project.ps1`: Windows-Initialisierung eines Kunden-Agenten.
- `install_skills.sh`: Holt ausgewaehlte externe Skills oder Skill-Sammlungen projektlokal in `skills/`.
- `update_skill.sh`: Aktualisiert bereits genutzte externe Skills oder Skill-Sammlungen erneut aus dem Upstream.
- `skill_catalog.sh`: Gemeinsame Funktionen und Quellenkatalog fuer die Skill-Skripte.

Diese Skripte arbeiten projektlokal. Sie schreiben nicht nach `~/.codex`, `~/.agents` oder in globale Tool-Konfigurationen.

Beim Init werden unter anderem aktualisiert oder angelegt:

- `project.yaml`
- `.bootstrap/manifest.json`
- verwalteter Bootstrap-Block in `AGENTS.md`
- `docs/customer-context.md`
- Root-`Memory.md`
- `automations/heartbeat/`

Der Heartbeat wird als Projektdatei angelegt. Die wiederkehrende Ausfuehrung muss danach in Codex oder einem Scheduler aktiviert werden.

Moegliche Skripte fuer spaeter:

- `validate-project.sh`: Prueft, ob Pflichtdateien und Memory-Dateien vorhanden sind.
