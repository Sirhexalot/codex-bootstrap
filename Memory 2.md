# Projekt-Memory

Diese Datei ist das projektweite Arbeitsgedaechtnis fuer dieses Codex-Agent-Bootstrap-Projekt. Sie dokumentiert stabile Entscheidungen, wichtige Erkenntnisse, offene Punkte und den aktuellen Stand des Projekts.

## Zweck

- Zentrale Orientierung fuer Menschen und Codex-Agenten.
- Nachvollziehbare Dokumentation wichtiger Projektentscheidungen.
- Sammlung von offenen Punkten und naechsten Schritten.
- Bruecke zwischen `AGENTS.md`, Setup-Skripten, Skills, MCP-Servern und Automatisierungsvorlagen.

## Memory-Ebenen

Dieses Projekt nutzt drei Memory-Ebenen:

1. Memory-MCP-Server als Langzeitgedaechtnis fuer projektuebergreifend relevante Fakten, Praeferenzen und stabile Zusammenhaenge.
2. Projektweite `Memory.md` fuer Entscheidungen, Stand und offene Punkte dieses Bootstrap-Projekts.
3. `Memory.md` pro Automatisierung fuer laufbezogene Protokolle, Ergebnisse, Fehler und naechste Schritte.

## Stabile Projektentscheidungen

- Dieses Repository dient als Bootstrap-Vorlage fuer Codex-Agenten.
- Die Vorlage soll an Freunde, Bekannte, Teams und Unternehmen weitergegeben werden koennen.
- `AGENTS.md` ist die zentrale Agenten-Anweisung fuer das Projekt.
- Nach dem Kopieren soll der Ordner ueber `START_HERE.md` und `project.yaml` in einen konkreten Kunden-Agenten verwandelt werden.
- Neue Automatisierungen sollen aus `templates/automation-template/` kopiert werden.
- Konkrete Automatisierungen liegen unter `automations/`.
- Projektspezifische Skills liegen unter `skills/` und koennen aus `templates/skill-template/` entstehen.
- Jede Automatisierung muss bei jedem Lauf ihre eigene `Memory.md` aktualisieren.
- Langfristig relevante Erkenntnisse sollen zusaetzlich im Memory-MCP-Server gespeichert werden.

## Aktueller Stand

- Setup-Skripte fuer macOS und Windows sind vorhanden.
- README beschreibt Installation, Tools, MCP-Server und wichtige CLI-Pfade.
- `AGENTS.md` wurde als zentrale Bootstrap-Anweisung angelegt.
- Eine Automatisierungsvorlage wurde unter `templates/automation-template/` angelegt.
- Diese projektweite `Memory.md` wurde ergaenzt.
- `START_HERE.md` wurde als freundlicher Einstieg fuer neue Nutzer angelegt.
- `project.yaml` wurde als strukturierte Projektidentitaet angelegt.
- `.bootstrap/manifest.json` wurde als maschinenlesbares Bootstrap-Manifest angelegt.
- `docs/customer-context.md`, `docs/tools-and-access.md` und `docs/decisions.md` wurden angelegt.
- `automations/`, `skills/`, `templates/skill-template/` und `scripts/` wurden als Zielstruktur ergaenzt.
- `scripts/init-project.sh` und `scripts/init-project.ps1` legen beim Projektstart automatisch `automations/heartbeat/` an.
- Apple Music MCP wurde aus dem macOS-Setup entfernt.
- Microsoft Teams MCP via `floriscornel/teams-mcp` wurde als vorgesehener Coworker-Kanal aufgenommen.
- Playwright wird im Workstation-Setup fuer macOS und Windows global mit installiert, inklusive Browser-Binaries.
- Eine Root-`.gitignore` schuetzt das Projekt vor lokalen System-, Editor- und Build-Artefakten.

## Offene Punkte

- Beispiele fuer konkrete Automatisierungen ergaenzen.
- Optional pruefen, ob Setup-Skripte die Vorlagen oder Memory-Konventionen explizit erwaehnen sollten.
- Optional ein echtes Update-Skript bauen, das bestehende Kundenprojekte anhand `.bootstrap/manifest.json` auf eine neue Bootstrap-Version hebt.

## Laufprotokoll

### 2026-06-04

- Ausloeser: Manuelle Projektinitialisierung.
- Ziel: Bootstrap-Struktur fuer Codex-Agenten mit Agenten-Anweisungen und Automatisierungsvorlage anlegen.
- Ergebnisse:
  - `AGENTS.md` angelegt.
  - `templates/automation-template/README.md` angelegt.
  - `templates/automation-template/Memory.md` angelegt.
  - `templates/automation-template/Runbook.md` angelegt.
  - Projektweite `Memory.md` angelegt.
- Naechste Schritte:
  - README bei Bedarf um die neue Projektstruktur erweitern.
  - Erste konkrete Beispielautomatisierung aus der Vorlage ableiten.

### 2026-06-04 - Umbau Zum Kunden-Agent-Bootstrap

- Ausloeser: Wunsch, dass sich der Ordner nach dem Kopieren in einen konkreten Kunden-Agenten verwandelt.
- Ziel: Klare Struktur fuer Onboarding, Projektidentitaet, Kundendokumentation, Automatisierungen und Skills schaffen.
- Ergebnisse:
  - `START_HERE.md` angelegt.
  - `project.yaml` angelegt.
  - `docs/customer-context.md` angelegt.
  - `docs/tools-and-access.md` angelegt.
  - `docs/decisions.md` angelegt.
  - `automations/README.md` angelegt.
  - `skills/README.md` angelegt.
  - `templates/skill-template/SKILL.md` angelegt.
  - `scripts/README.md` angelegt.
  - `AGENTS.md` und README auf die neue Struktur angepasst.
- Naechste Schritte:
  - Optional ein `init-project`-Skript bauen.
  - Optional eine Beispielautomatisierung erstellen.

### 2026-06-04 - Trennung Von Workstation-Setup Und Projektinitialisierung

- Ausloeser: Klaerung, dass nicht alles global in `~/.codex` installiert werden sollte.
- Ziel: Root-Setup-Skripte als Rechner-Setup behalten und projektlokale Init-Skripte fuer Kunden-Agenten ergaenzen.
- Entscheidung:
  - `setup-mac.sh` und `setup-windows.ps1` sind fuer die Codex-Werkbank und duerfen globale Tools, MCP-Server und Skills installieren.
  - `scripts/init-project.sh` und `scripts/init-project.ps1` sind fuer das konkrete Kundenprojekt und duerfen nur Dateien im Projektordner veraendern.
- Ergebnisse:
  - `scripts/init-project.sh` angelegt.
  - `scripts/init-project.ps1` angelegt.
  - README, `AGENTS.md`, `START_HERE.md` und `scripts/README.md` auf die neue Trennung angepasst.
- Root-Setup-Skripte mit einem Hinweis auf ihren globalen Zweck versehen.
- Init-Skripte per Syntaxcheck und Probelauf in einer temporaeren Kopie geprueft.
- Naechste Schritte:
  - Optional eine Beispielautomatisierung erstellen.
  - Optional ein Validierungsskript fuer Pflichtdateien und Memory-Regeln ergaenzen.

### 2026-06-04 - Bootstrap-Manifest Und Heartbeat-Automatisierung

- Ausloeser: Wunsch, sinnvolle Muster aus `gstack-codex` zu uebernehmen und beim Projektbeginn eine regelmaessige Pflege-Automatisierung anzulegen.
- Ziel: Projektinitialisierung versionierbar machen und automatisch einen Heartbeat fuer Memory- und Dokumentationspflege vorbereiten.
- Entscheidungen:
  - `project.yaml` bekommt einen `bootstrap`-Block mit Name, Version, Initialisierungszeit und Manifest-Pfad.
  - `.bootstrap/manifest.json` dokumentiert Bootstrap-Version, verwaltete Dateien und den verwalteten `AGENTS.md`-Block.
  - `AGENTS.md` enthaelt einen verwalteten Block zwischen `CUSTOMER-AGENT-BOOTSTRAP:START` und `CUSTOMER-AGENT-BOOTSTRAP:END`.
  - `scripts/init-project.sh` und `scripts/init-project.ps1` legen beim Projektstart `automations/heartbeat/` an.
  - Der Heartbeat soll wochentags jede Stunde von 09:00 bis 17:00 lokaler Zeit laufen.
  - Apple Music MCP wird nicht mehr im macOS-Setup installiert.
- Ergebnisse:
  - `.bootstrap/manifest.json` angelegt.
  - `project.yaml` um `bootstrap` und `heartbeat` ergaenzt.
  - `AGENTS.md` um verwalteten Bootstrap-Block und Heartbeat-Regeln ergaenzt.
  - Init-Skripte aktualisieren Manifest, Managed Block und legen Heartbeat-Dateien an.
  - README, `START_HERE.md` und `scripts/README.md` angepasst.
  - Apple-Music-Installationsfunktionen und Aufrufe aus `setup-mac.sh` entfernt.
  - Shell- und PowerShell-Syntaxchecks sowie Init-Probelauf fuer macOS/Linux und Windows bestanden.
- Naechste Schritte:
  - In einem echten Kundenprojekt den Heartbeat als Codex-Automation oder externen Scheduler aktivieren.
  - Optional ein `validate-project`-Skript fuer Pflichtdateien und Memory-Regeln bauen.

### 2026-06-04 - Zielbild AI-Coworker Gesetzt

- Ausloeser: Nutzer sagte: "ich will quasi einen coworker am ende haben".
- Ziel: Das Bootstrap-Projekt in Richtung eines produktneutralen AI-Coworkers ausrichten.
- Erkenntnis aus der Zielreferenz:
  - Der Zielzustand ist kein reiner Chatbot, sondern ein Coworker, der Tools nutzt, echte Outputs liefert, Automatisierungen ausfuehrt oder vorbereitet und in Teamkanaelen arbeiten kann.
  - Wichtige Faehigkeiten: Integrationen, Reports, Recherche, Browser-Automation, App-/Code-Arbeit, geplante Aufgaben, Memory und sichere Freigaben.
- Ergebnisse:
  - `project.yaml` auf `AI Coworker Agent` initialisiert.
  - `docs/customer-context.md` mit Zielbild, Verhalten, Grenzen und offenen Fragen ergaenzt.
  - `docs/tools-and-access.md` auf Coworker-relevante Toolgruppen und Zugriffsregeln angepasst.
  - `docs/decisions.md` um die Coworker-Entscheidung ergaenzt.
- Naechste Schritte:
  - Ersten konkreten Coworker-Use-Case waehlen.
  - Danach passende Tools/Zugriffe dokumentieren.
  - Erste Automatisierung aus `templates/automation-template/` ableiten, sobald ein wiederkehrender Ablauf feststeht.

### 2026-06-04 - Teams MCP Aufgenommen

- Ausloeser: Nutzer bat darum, `floriscornel/teams-mcp` aufzunehmen und lokal zu installieren.
- Ziel: Microsoft Teams als konkreten Coworker-Kanal vorbereiten.
- Entscheidung:
  - `teams_mcp` wird als user-level Codex-MCP registriert.
  - Die Konfiguration nutzt `npx -y @floriscornel/teams-mcp@latest`.
  - Microsoft-Graph-Anmeldung und Token bleiben lokal im Home-Verzeichnis und werden nicht im Repository gespeichert.
- Ergebnisse:
  - `setup-mac.sh` und `setup-windows.ps1` registrieren den Teams MCP kuenftig automatisch.
  - README, `project.yaml`, `docs/tools-and-access.md` und `docs/decisions.md` wurden ergaenzt.
- Naechste Schritte:
  - Lokal Microsoft-Teams-Authentifizierung abschliessen.
  - Codex nach der Anmeldung neu starten, damit der MCP-Server in neuen Sitzungen geladen wird.

### 2026-06-19 - Playwright Im Workstation-Setup Ergaenzt

- Ausloeser: Wunsch, Playwright auch unter macOS und Windows direkt ueber die Root-Setup-Skripte zu installieren.
- Ziel: Browser-Automation und lokale Browser-Tests ohne zusaetzliche manuelle Nachinstallation vorbereiten.
- Entscheidung:
  - `setup-mac.sh` und `setup-windows.ps1` installieren global das npm-Paket `playwright`.
  - Direkt danach werden mit `npx playwright install` die benoetigten Browser-Binaries eingerichtet.
- Ergebnisse:
  - `setup-mac.sh` aktualisiert.
  - `setup-windows.ps1` aktualisiert.
- Naechste Schritte:
  - Optional README um einen expliziten Hinweis auf Playwright erweitern.
  - Bei Bedarf spaeter pruefen, ob zusaetzlich systemweite Abhaengigkeiten fuer Linux dokumentiert werden sollen.

### 2026-06-19 - Root-.gitignore Ergaenzt

- Ausloeser: Pruefung der Ignore-Regeln fuer das Bootstrap-Projekt.
- Ziel: Lokale Systemdateien, Editor-Einstellungen und typische Build-Artefakte aus dem Repository fernhalten.
- Entscheidung:
  - Im Repo-Root wird eine eigene `.gitignore` gepflegt.
  - Sie ignoriert nur lokale und generierte Artefakte, nicht aber projektrelevante Bootstrap-Dateien oder Dokumentation.
- Ergebnisse:
  - Root-`.gitignore` angelegt.
  - Vorhandene `.DS_Store` aus dem Projekt entfernt.
- Naechste Schritte:
  - Optional spaeter projektspezifische Ignore-Regeln ergaenzen, falls einzelne Skills oder Automatisierungen weitere Build-Artefakte erzeugen.

### 2026-06-19 - Projektlokale Skill-Quellen Fuer Vier Externe Pakete

- Ausloeser: Wunsch, `financial-services`, `marketingskills`, `frontend-design` und `humanizer` direkt im Projekt zu verwalten.
- Ziel: Projektlokale Installation und spaetere Updates ueber einfache Shell-Skripte ermoeglichen.
- Entscheidung:
  - Direkte Einzel-Skills werden direkt unter `skills/<name>/` abgelegt.
  - Skill-Sammlungen und Plugin-Bundles werden unter `skills/upstream/<name>/` versionierbar abgelegt.
  - Installation und Update laufen ueber `scripts/install_skills.sh` und `scripts/update_skill.sh`.
- Ergebnisse:
  - `scripts/install_skills.sh` angelegt.
  - `scripts/update_skill.sh` angelegt.
  - `scripts/skill_catalog.sh` als gemeinsamer Quellenkatalog angelegt.
  - `skills/README.md` und `scripts/README.md` auf die neue Struktur erweitert.
  - `frontend-design` als direkter Projekt-Skill unter `skills/frontend-design/` installiert.
  - `humanizer` als direkter Projekt-Skill unter `skills/humanizer/` installiert.
  - `financial-services` als Sammlung unter `skills/upstream/financial-services/` installiert.
  - `marketingskills` als Sammlung unter `skills/upstream/marketingskills/` installiert.
- Naechste Schritte:
  - Entscheiden, ob einzelne Inhalte aus den Sammlungen als direkte Projekt-Skills nach oben gezogen werden sollen.
