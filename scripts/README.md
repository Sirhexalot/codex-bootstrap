# Skripte

Diese sichtbaren Skripte sind Einstiegspunkte. Die eigentliche Bootstrap-Logik liegt unter `.bootstrap/`.

## Verfügbare Skripte

- `init-project.sh`: Initialisiert den Ordner auf macOS/Linux als konkreten Agenten
- `init-project.ps1`: Initialisiert den Ordner unter Windows
- `install_skills.sh`: Installiert Skills aus Original-Repositories und fragt nach `global` oder `projektbezogen`
- `update_skill.sh`: Aktualisiert bereits installierte Skills anhand des gespeicherten Modus und der gespeicherten Quelle
- `update_skills.sh`: Alias für dieselbe Aktualisierungslogik
- `list_skills.sh`: Zeigt die von diesem Bootstrap verwalteten Skill-Installationen

## Prinzip

- Werkbank-Tools sind global.
- Skills sind bewusst wählbar: `global` oder `projektbezogen`.
- Projektsammlungen werden versteckt unter `.bootstrap/skills-cache/` abgelegt, damit die sichtbare Struktur sauber bleibt.
