# Skills

This folder is the local skill runtime for this bootstrap.

## Rules

- Managed upstream skills are fetched from Git into this local runtime.
- Large upstream collections such as `marketingskills`, `financial-services`, and `composio-skills` live under `cache/` as reproducible working copies.
- Remote-installed skills are not versioned in this bootstrap by default.
- Updates come from the installer and update flow, not from committing fetched skill files.
- Only explicitly adopted project-owned skills should be committed here.
- Managed upstream sources are controlled through `./.scripts/install_skills.sh`, `./.scripts/update_skills.sh`, and `./.scripts/list_skills.sh`.

## Typical Contents

- cached upstream skill checkouts for local use
- intentionally adopted project-owned `SKILL.md` files only when that visibility is wanted
