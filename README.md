Regale Studio Copilot Skill — Lightweight scaffold

What this repo contains (minimal, lightweight):

- manifest.json        - skill/extension metadata
- .github/skills/demo/BUILD_PIPELINE.md - CANONICAL build pipeline; the only copy
- .github/agents/regale-demo.agent.md - GitHub Copilot app custom agent for native demo sessions
- .github/skills/demo/SKILL.md - Copilot Agent Skill exposed as `/demo`
- .github/prompts/demo.prompt.md - VS Code prompt-file slash command fallback for `/demo`
- .mcp.json            - GitHub Copilot local MCP configuration for Regale Studio UAT
- scripts/install-copilot-user-assets.ps1 - Windows installer for personal Copilot agent/skill/MCP setup
- scripts/install-from-github.ps1 - one-command installer that downloads the latest setup from GitHub
- install-regale-demo.cmd - double-click installer for users who already have this folder
- WINDOWS_COPILOT_APP.md - non-developer setup and daily-use guide
- skill.md             - human-facing overview: purpose, v1 scope, how a demo maps onto Regale
- parser.py            - .docx (two-column) -> demo-definition YAML parser
- build_orchestrator.py - MCP-driven build orchestration template (tool-discovery-driven)
- examples/example_demo.yaml - example demo-definition conforming to the schema
- .mcp.json            - Regale MCP server snippet (place in .vscode/mcp.json or your Copilot CLI config)

Editing behaviour: change `.github/skills/demo/BUILD_PIPELINE.md` and nothing else. The
definition-mode rules are duplicated across five runtime files because Copilot's skill,
agent, and prompt formats each load their own; the build pipeline deliberately is not.

Quick setup (Windows):
1) For the GitHub Copilot app or Copilot CLI, use the installer from PowerShell:

   $u = 'https://raw.githubusercontent.com/nouvre/regale-copilot-skill/main/scripts/install-from-github.ps1'
   $p = Join-Path $env:TEMP 'install-regale-demo.ps1'
   Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $p
   powershell -NoProfile -ExecutionPolicy Bypass -File $p

   Or, if this folder is already downloaded, double-click `install-regale-demo.cmd`.

   Advanced/local install:

   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-copilot-user-assets.ps1

   See WINDOWS_COPILOT_APP.md for the non-developer setup and daily-use flow.

2) Set up the Python environment (needed for .docx parsing):
   py -m venv .venv
   .\.venv\Scripts\Activate.ps1
   python -m pip install -r requirements.txt

3) Generate a demo from a plain-language prompt in Copilot (recommended):
   - In the GitHub Copilot app, open this repository as the project, type `/agent`, and select `Regale Demo`.
   - Then enter a short brief, such as: `Pitch SharePoint to an executive. Keep it short and lead with business value.`
   - In VS Code or another IDE that supports prompt files, you can also use `/demo Pitch SharePoint to an executive. Keep it short and lead with business value.`
   - The agent will enter DEFINITION mode, generate a compact, structured preview in-chat (card/outline), allow short inline edits via commands, and will only proceed to build after you issue the exact phrase `confirm build`.
   - NOTE: the agent will refuse to call Regale MCP tools or start any background build while in DEFINITION mode.
   - If Copilot answers with a normal pitch instead of a preview, confirm the `Regale Demo` custom agent is selected. The custom agent is defined in `.github/agents/regale-demo.agent.md`; the portable skill is defined in `.github/skills/demo/SKILL.md`.

4) (Optional) Parse a .docx (two-column "What to say" / "What to show"):
   python parser.py path\to\demo.docx -o output_demo.yaml
   The parser is available for teams who already maintain scripts; the default chat-first flow hides YAML from end users.

5) To run the build, use the Copilot app, Copilot CLI, or an MCP-capable Copilot client on the SAME PC as Regale Studio. The build_orchestrator.py is a template that expects an MCP client adapter; it prints planned steps and includes TODOs where Regale MCP calls belong.

Important notes:
- The parser only supports the standard two-column table format (left = What to say, right = What to show).
- The build step must run locally (Regale MCP is local-only). Before building, open Regale Studio and enable Save/Publish permissions if you want disk save or portal publish.

Contact: provide feedback here and I can iterate the implementation into a runnable MCP client adapter.
