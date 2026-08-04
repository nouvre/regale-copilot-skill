# Setup Guide

## Prerequisites
- Windows PC with Regale Studio installed and running.
- GitHub Copilot (the app, the CLI, or VS Code agent mode) on the same PC as Regale Studio.

Git and Python are not needed to install or use this. They are only needed for the
optional `.docx` parser at the bottom of this page.

## Install

Open PowerShell and paste one line:

```powershell
irm https://raw.githubusercontent.com/nouvre/regale-copilot-skill/main/scripts/install-from-github.ps1 | iex
```

If you already have this folder on disk, double-click `install-regale-demo.cmd` instead.

The installer checks your machine, installs the `Regale Demo` agent and `demo` skill into
`%USERPROFILE%\.copilot`, registers the Regale MCP server, verifies what it wrote, and
offers to restart Copilot. Say yes to the restart — Copilot only reads these files at
startup.

See [WINDOWS_COPILOT_APP.md](WINDOWS_COPILOT_APP.md) for what it installs, non-default
Regale install paths, and troubleshooting.

### VS Code

The repo's `.vscode/mcp.json` already points at the Regale MCP bridge as shipped with
Regale Studio. No edits are needed if Regale Studio is in the default location.

## Ensure Regale Studio settings & permissions
- Open Regale Studio on the same PC.
- Open **AI & Agents** → **Permissions**.
- Toggle ON **Save project files** if you want the agent to save projects automatically.
- Toggle ON **Publish to the Regale portal** if you want automatic publishing (optional).

## Using the chat-first flow (recommended)
- Start your demo with an exact `/demo` line, for example:

```
/demo Pitch SharePoint to an executive. Keep it short and lead with business value.
```

- Agent enters DEFINITION mode and returns a compact preview. Use the provided inline-edit commands to refine the plan. When ready, type the exact phrase `confirm build` to let the agent proceed to build.

- Safety note: The agent will refuse to call Regale tools or start builds until `confirm build` is issued.

## Troubleshooting
- If the agent says "Capturer not open": Open Regale Studio → View → Open Capturer.
- If Save/Publish operations fail: re-check Regale Studio → AI & Agents → Permissions.
- Anything about the install itself: [WINDOWS_COPILOT_APP.md](WINDOWS_COPILOT_APP.md#quick-troubleshooting).

## Optional: parse existing Word demo scripts

Only for teams that still author demos as Word documents. This is the one part that needs
Python 3.8+ and a clone of the repo.

```powershell
git clone https://github.com/nouvre/regale-copilot-skill.git
cd regale-copilot-skill
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

On macOS/Linux use `python3 -m venv .venv` and `source .venv/bin/activate`. Run
`deactivate` to leave the environment; `.venv` is git-ignored.

`parser.py` expects a two-column table with headings "What to say" and "What to show":

```
python parser.py path\to\your.docx -o demo.yaml
```

## Questions
Open an issue in the repo or contact the adapter owner.
