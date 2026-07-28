# Setup Guide

## Prerequisites
- Windows PC with Regale Studio installed and running.
- VS Code with GitHub Copilot agent mode (or Copilot CLI) on the same PC as Regale Studio.
- Python 3.8+ (optional; only needed for .docx parsing).
- Git and a GitHub account (to clone this repo).

## Quick configuration

1. Clone the repo:

```
git clone https://github.com/nouvre/regale-copilot-skill.git
cd regale-copilot-skill
```

2. (Optional) Install Python dependencies for .docx parsing:

```
python -m pip install python-docx pyyaml
```

3. Configure VS Code for MCP (already included):
- The file `.vscode/mcp.json` is preconfigured to point to the Regale MCP bridge as shipped with Regale Studio.
- No additional edits should be necessary if Regale Studio is installed in the default location.

4. Ensure Regale Studio settings & permissions:
- Open Regale Studio on the same PC.
- Open **AI & Agents** → **Permissions**.
- Toggle ON **Save project files** if you want the agent to save projects automatically.
- Toggle ON **Publish to the Regale portal** if you want automatic publishing (optional).

5. SSH / Git authentication (recommended):
- Set up an SSH key and add it to GitHub for push/pull convenience:

```
ssh-keygen -t ed25519 -C "your_email@example.com"
# then copy your public key and add it to GitHub > Settings > SSH and GPG keys
```

Alternative: use `gh auth login` or a Personal Access Token (PAT) for HTTPS pushes.

## Using the chat-first flow (recommended)
- Start your demo with an exact `/demo` line, for example:

```
/demo Pitch SharePoint to an executive. Keep it short and lead with business value.
```

- Agent enters DEFINITION mode and returns a compact preview. Use the provided inline-edit commands to refine the plan. When ready, type the exact phrase `confirm build` to let the agent proceed to build.

- Safety note: The agent will refuse to call Regale tools or start builds until `confirm build` is issued.

## Optional: Parse existing Word demo scripts
- The repo includes `parser.py` (for teams that still author Word scripts).
- It expects a two-column table with headings "What to say" and "What to show".
- Run:

```
python parser.py path\to\your.docx -o demo.yaml
```

## Troubleshooting
- If the agent says "Capturer not open": Open Regale Studio → View → Open Capturer.
- If Save/Publish operations fail: re-check Regale Studio → AI & Agents → Permissions.
- If git push fails: ensure SSH key is added to your GitHub account or run `gh auth login`.

## Questions
Open an issue in the repo or contact the adapter owner.
