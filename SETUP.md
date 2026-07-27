# Setup Guide

## Prerequisites
- **Regale Studio** installed on your PC (download from [regale.app](https://regale.app))
- **GitHub Copilot CLI** or **VS Code with Copilot** (with agent mode enabled)
- **Python 3.8+** (for parsing .docx files)

## Installation

### 1. Clone this repo
```bash
git clone https://github.com/nouvre/regale-copilot-skill.git
cd regale-copilot-skill
```

### 2. Install Python dependencies
```bash
pip install python-docx pyyaml
```

### 3. Configure VS Code (if using VS Code agent mode)
- Open this folder in VS Code
- The .vscode/mcp.json is already configured to point to your local Regale Studio MCP server
- Make sure Regale Studio is running on the same PC

### 4. Enable Regale permissions
- Open **Regale Studio**
- Click **AI & Agents** button in the ribbon
- Go to **Permissions** tab
- Toggle **ON**: "Save project files" and "Publish to the Regale portal"

## Usage

### Option A: From a plain-language demo goal
In your Copilot chat, describe what you want:
\\\
Pitch SharePoint to an executive. Keep it short and lead with business value.
Build this demo.
\\\

### Option B: From a Word document
1. Prepare a .docx with a two-column table: "What to say" | "What to show"
   - Left column: presenter narration with numbered steps
   - Right column: UI surface descriptions
2. Run the parser:
   \\\ash
   python parser.py your_demo.docx -o my_demo.yaml
   \\\
3. Review the generated YAML (in chat or locally)
4. In your Copilot chat:
   \\\
   I have a demo YAML file. Build this demo.
   \\\
   (Then paste or upload the YAML)

## Troubleshooting

**"Regale Studio is not responding"**
- Make sure Regale Studio is open with a project loaded

**"SaveProject permission is OFF"**
- Open Regale Studio → AI & Agents → Permissions → toggle "Save project files" ON

**"Python module not found"**
- Run: \pip install python-docx pyyaml\

**Demo built but not saved**
- Enable "Save project files" in Regale permissions (see step 4 above)

## Examples

See \examples/example_demo.yaml\ for a template. Edit it to customize:
- Title and audience
- Scenes (open/beat/close)
- Surface URLs
- Narration and presenter notes
- Interactive beats (target selectors)

For help with CSS selectors, open the page in your browser, right-click → Inspect, and copy the element's ID, class, or aria-label.

## Questions or Issues?

Open an issue on GitHub or contact your team lead.
