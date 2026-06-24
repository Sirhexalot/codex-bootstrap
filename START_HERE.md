# Start Here

This folder is not yet a finished customer agent. It is a bootstrap.

When you open this folder in Codex, the agent should read the bootstrap files first, interview you, and turn the repository into a real agent for your project.

## Recommended First Prompt

```text
Please initialize this project as a customer agent.
```

## What Should Happen Next

The agent should:

1. read `AGENTS.md`, `project.yaml`, `Memory.md`, and `.bootstrap/README.md`
2. ask about the user name, agent name, purpose, role, country, timezone, language, tone, and boundaries
3. write the final `AGENTS.md` for the project
4. adapt `project.yaml`, `docs/`, and `Memory.md` to the real context
5. create or update the default `Heartbeat` automation
6. show how to install tool bundles and skills globally or in workspace mode

## Prepare the Workbench First

If the local environment is not prepared yet:

macOS:

```bash
chmod +x ./setup-mac.sh
./setup-mac.sh
```

Windows:

```powershell
.\setup-windows.ps1
```

These scripts install the global standard bundles for the workbench. Codex itself is not installed here.

## Important Distinction

- `setup-mac.sh` and `setup-windows.ps1` prepare the machine.
- `scripts/init-project.sh` and `scripts/init-project.ps1` initialize this specific project.
- Internal bootstrap logic lives separately under `.bootstrap/`.
