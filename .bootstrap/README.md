# Bootstrap-Interna

Dieser Ordner enthält die versteckte Bootstrap-Logik für dieses Repository.

## Zweck

- Initialisierung eines neuen Agentenprojekts
- Vorlagen für die finale `AGENTS.md` und Projektdokumente
- Metadaten über Bootstrap-Version und verwaltete Installationen
- Skill-Kataloge und Skill-Installationsstatus
- Vorlagen für Automatisierungen und Skills

## Für Agenten zuerst lesen

Wenn dieses Repository noch nicht initialisiert ist, lies mindestens in dieser Reihenfolge:

1. `.bootstrap/README.md`
2. `.bootstrap/templates/final-AGENTS.md`
3. `.bootstrap/scripts/bootstrap-project-init.sh` oder `.bootstrap/scripts/bootstrap-project-init.ps1`
4. `.bootstrap/lib/skill-catalog.sh`

## Wichtige Regeln

- Die sichtbare `AGENTS.md` ist nur der Bootstrap-Einstieg.
- Nach der Initialisierung gehört die sichtbare `AGENTS.md` dem konkreten Projekt.
- Tools sind global.
- Skills werden aus Original-Repositories geholt und pro Lauf als `global` oder `projektbezogen` installiert.
- Projektsammlungen liegen bevorzugt unter `.bootstrap/skills-cache/`, damit der sichtbare Projektbereich sauber bleibt.

## Interne Struktur

- `templates/`: Vorlagen für finale Agentendokumente, Automatisierungen und Skills
- `scripts/`: Bootstrap-interne Initialisierungslogik
- `lib/`: gemeinsam genutzte Shell-Helfer
- `skill-installs/`: Metadaten zu verwalteten Skill-Installationen
- `skills-cache/`: abgeschirmte projektbezogene Skill-Sammlungen
- `manifest.json`: maschinenlesbare Bootstrap-Metadaten
