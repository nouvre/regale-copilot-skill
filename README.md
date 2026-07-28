Regale Studio Copilot Skill — Lightweight scaffold

What this repo contains (minimal, lightweight):

- manifest.json        - skill/extension metadata
- parser.py            - .docx (two-column) -> demo-definition YAML parser
- build_orchestrator.py - MCP-driven build orchestration template (tool-discovery-driven)
- example_demo.yaml    - example demo-definition conforming to the schema
- mcp.json             - Regale MCP server snippet (place in .vscode/mcp.json or your Copilot CLI config)

Quick setup (Windows):
1) Install Python deps (used only for parsing):
   python -m pip install python-docx pyyaml

2) Generate a demo from a plain-language prompt in Copilot (recommended):
   - Open this folder in VS Code and start a Copilot chat on the same PC as Regale Studio.
   - Start your demo with the exact token `/demo` followed by a short brief (for example: `/demo Pitch SharePoint to an executive. Keep it short and lead with business value.`).
   - The agent will enter DEFINITION mode, generate a compact, structured preview in-chat (card/outline), allow short inline edits via commands, and will only proceed to build after you issue the exact phrase `confirm build`.
   - NOTE: the agent will refuse to call Regale MCP tools or start any background build while in DEFINITION mode.
   - If Copilot answers with a normal pitch instead of a preview, confirm this repository is open as the VS Code workspace, then type `/` and verify the workspace prompt command `demo` appears. The command is defined in `.github/prompts/demo.prompt.md`.

3) (Optional) Parse a .docx (two-column "What to say" / "What to show"):
   python parser.py path\to\demo.docx -o output_demo.yaml
   The parser is available for teams who already maintain scripts; the default chat-first flow hides YAML from end users.

4) To run the build, use the Copilot CLI or an MCP-capable Copilot client on the SAME PC as Regale Studio. The build_orchestrator.py is a template that expects an MCP client adapter; it prints planned steps and includes TODOs where Regale MCP calls belong.

Important notes:
- The parser only supports the standard two-column table format (left = What to say, right = What to show).
- The build step must run locally (Regale MCP is local-only). Before building, open Regale Studio and enable Save/Publish permissions if you want disk save or portal publish.

Contact: provide feedback here and I can iterate the implementation into a runnable MCP client adapter.
