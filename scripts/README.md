# Skripte

Diese sichtbaren Skripte sind Nutzerbefehle. Die eigentliche Bootstrap-Logik liegt unter `.bootstrap/`.

## Verfügbare Skripte

- `init-project.sh`: Sichtbarer Startbefehl für die Projekt-Initialisierung auf macOS/Linux
- `init-project.ps1`: Sichtbarer Startbefehl für die Projekt-Initialisierung unter Windows
- `install_skills.sh`: Installiert Skills aus Original-Repositories und fragt nach `global` oder `projektbezogen`
- `update_skill.sh`: Aktualisiert bereits installierte Skills anhand des gespeicherten Modus und der gespeicherten Quelle
- `update_skills.sh`: Alias für dieselbe Aktualisierungslogik
- `list_skills.sh`: Zeigt die von diesem Bootstrap verwalteten Skill-Installationen

## Aktuell unterstützte Quellen

- `financial-services`
- `marketingskills`
- `frontend-design`
- `humanizer`
- `ui-ux-pro-max`
- `drawio-diagrams-enhanced`
- `svg-precision`
- `pptx`
- `senior-architect`
- `brand-voice`
- `infographic-creation`
- `jira-expert`
- `confluence`

## Prinzip

- Werkbank-Tools sind global.
- Skills sind bewusst wählbar: `global` oder `projektbezogen`.
- Projektsammlungen werden versteckt unter `.bootstrap/skills-cache/` abgelegt, damit die sichtbare Struktur sauber bleibt.
- Die internen Bootstrap-Skripte heißen bewusst anders als die sichtbaren Startbefehle, damit Nutzeroberfläche und Implementierung leichter unterscheidbar bleiben.
