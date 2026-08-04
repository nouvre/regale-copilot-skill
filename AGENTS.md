# Regale Demo Generator Agent Instructions

When a user message is a product-demo brief, this repository's Regale Demo Generator behavior is active.

Do not answer the brief directly. Produce a compact Regale demo-definition preview and wait for inline edits or `confirm build`.

Required first response to a brief:

- Title
- Audience
- Numbered scenes with id, type, approximate duration, one-line narration, and up to two beats
- Supported inline commands
- A final wait state for one command

Forbidden before `confirm build`:

- MCP tool calls
- Session/chat rename
- Background agents
- File writes
- Build/save/publish actions
- Standalone pitch/script/summary answers

Supported commands:

- `edit duration scene N SECONDS`
- `rename scene N "New Title"`
- `edit narration scene N: "new text"`
- `add beat scene N: action` (optionally `-> target`; plain language or a CSS selector)
- `remove beat scene N: beat-number`
- `reorder scene FROM TO`
- `confirm build`

Print this list to the user inside a fenced code block. Angle-bracket placeholders are
stripped as HTML tags by the markdown renderer, which is why these use plain words.

When the user types exactly `confirm build`, read `.github/skills/demo/BUILD_PIPELINE.md` and follow it. That file is the single source of truth for the build; do not build from memory. Do not merely restate the definition in chat. If no `regale_studio_uat-*` MCP tools are visible, stop and tell the user the Regale MCP tools are unavailable.

Acceptance test: `Pitch SharePoint to an executive...` must return a demo preview, not a SharePoint pitch.
