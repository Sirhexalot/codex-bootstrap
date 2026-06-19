# Projekt-Memory

Diese Datei ist das projektweite Arbeitsgedächtnis dieser Bootstrap-Vorlage.

## Zweck

- Bootstrap-Entscheidungen nachvollziehbar halten
- den aktuellen Stand des Repositories dokumentieren
- spätere Anpassungen für andere Agenten oder Maintainer erleichtern

## Aktueller Stand

- Dieses Repository ist eine Bootstrap-Vorlage für Codex-Agenten.
- Die globale Werkbank wird über `setup-mac.sh` und `setup-windows.ps1` vorbereitet.
- Bootstrap-Interna liegen unter `.bootstrap/`.
- Sichtbare Skripte unter `scripts/` delegieren an Bootstrap-Logik.
- Skills werden aus Original-Repositories installiert.
- Skill-Installationen unterscheiden zwischen `global` und `projektbezogen`.
- Nach der Initialisierung wird die sichtbare `AGENTS.md` durch eine projektspezifische Fassung ersetzt.

## Stabile Entscheidungen

- Tools gehören zur globalen Werkbank.
- Codex wird nicht durch dieses Repository installiert.
- Skills dürfen global oder projektbezogen installiert werden.
- Größere projektspezifische Skill-Sammlungen sollen die sichtbare Projektstruktur nicht verschmutzen.
- Die Standard-Automatisierung `Heartbeat` wird beim Initialisieren angelegt.

## Offene Punkte

- Optional später zusätzliche Skill-Quellen in den Katalog aufnehmen
- Optional später weitere Bootstrap-Skripte wie Validierung oder Upgrade ergänzen

## Laufprotokoll

### 2026-06-19 - Bootstrap auf globale Werkbank und versteckte Interna umgestellt

- Auslöser: Wunsch, das Repository sauber an Freunde weitergeben zu können.
- Ziel: globale Werkbank, Bootstrap-Interna unter `.bootstrap/`, projektbezogene Übergabe über Onboarding und wählbare Skill-Modi.
- Ergebnisse:
  - Root-`AGENTS.md` zum Bootstrap-Einstieg vereinfacht.
  - Setup-Skripte auf globale Werkbank reduziert.
  - Skill-Verwaltung auf `global` oder `projektbezogen` mit Metadaten umgestellt.
  - Initialisierung auf echtes Nutzerinterview und finale `AGENTS.md` ausgerichtet.
- Nächste Schritte:
  - Auf macOS und mit Bash/PowerShell per Syntaxcheck und Probelauf prüfen.

### 2026-06-19 - Remote-Skills aus Git herausgenommen

- Auslöser: Klärung, dass aus Remote-Repositories installierte Skills nicht als lokale Projekt-Änderungen mitgeführt werden sollen.
- Ziel: Reproduzierbare Skill-Installationen erlauben, ohne das Repository mit Upstream-Kopien zu füllen.
- Ergebnisse:
  - Root-`.gitignore` um Regeln für remote-verwaltete Skill-Kopien erweitert.
  - `skills/README.md` und `scripts/README.md` auf den neuen Workflow angepasst.
- Nächste Schritte:
  - Bei Bedarf einzelne wirklich projektspezifische Skills aus Upstream-Sammlungen bewusst als eigene Repo-Dateien übernehmen.
