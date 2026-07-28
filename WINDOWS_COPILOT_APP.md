# Regale Demo Setup for GitHub Copilot on Windows

Use this flow for the GitHub Copilot app or Copilot CLI on the same Windows machine where Regale Studio is running.

## One-Time Setup

1. Install and sign in to GitHub Copilot.
2. Install Regale Studio UAT.
3. Open PowerShell.
4. Run the one-command installer:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/nouvre/regale-copilot-skill/main/scripts/install-from-github.ps1 | iex"
```

If this repository is already downloaded, you can instead double-click:

```text
install-regale-demo.cmd
```

Advanced/local install:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install-copilot-user-assets.ps1
```

This installs:

- `Regale Demo` as a personal Copilot custom agent in `$HOME\.copilot\agents`.
- `demo` as a personal Copilot skill in `$HOME\.copilot\skills`.
- The Regale Studio UAT MCP server in `$HOME\.copilot\mcp-config.json`.

If Regale Studio is installed somewhere else, pass the bridge path:

```powershell
.\scripts\install-copilot-user-assets.ps1 -RegaleMcpBridgePath "C:\Path\To\regale-mcp-bridge.exe"
```

## Daily Use

1. Start Regale Studio UAT.
2. Open or create a Regale project.
3. Open the GitHub Copilot app.
4. Type `/agent` and select `Regale Demo`.
5. Enter a plain brief:

```text
Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
```

The agent should return a compact preview and wait for edits.

When ready, type:

```text
confirm build
```

Only then should the agent call Regale MCP tools.

Expected build behavior:

- The agent should check Regale permissions, open project state, and Capturer state.
- The agent should navigate/capture scenes in Regale Studio.
- The agent should report slide capture progress.

If the agent only prints another preview or says it "built demo-definition", it did not reach Regale Studio. Restart GitHub Copilot and confirm the Regale MCP server is configured:

```powershell
Get-Content "$HOME\.copilot\mcp-config.json"
```

## Quick Troubleshooting

- If `Regale Demo` does not appear under `/agent`, restart GitHub Copilot after running the installer.
- If Regale tools are unavailable, confirm `$HOME\.copilot\mcp-config.json` contains `regale-studio-uat`.
- If the agent answers with a normal pitch, make sure `Regale Demo` is selected before entering the brief.
- If the MCP bridge cannot start, verify the path to `regale-mcp-bridge.exe`.
