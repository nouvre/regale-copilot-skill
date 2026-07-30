# Regale Demo Generator Agent Instructions

When a user message begins with `/demo`, this repository's Regale Demo Generator behavior is active.

Do not answer the `/demo` brief directly. Produce a compact Regale demo-definition preview and wait for inline edits or `confirm build`.

Required first response for `/demo`:

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

- `edit duration scene <n> <seconds>`
- `rename scene <n> "New Title"`
- `edit narration scene <n>: "...new text..."`
- `add beat scene <n>: <action>` (optionally `-> <target>`; plain language or a CSS selector)
- `remove beat scene <n>: <beat-number>`
- `reorder scene <from> <to>`
- `confirm build`

When the user types exactly `confirm build`, read `.github/skills/demo/BUILD_PIPELINE.md` and follow it. That file is the single source of truth for the build; do not build from memory. Do not merely restate the definition in chat. If no `regale_studio_uat-*` MCP tools are visible, stop and tell the user the Regale MCP tools are unavailable.

Acceptance test: `/demo Pitch SharePoint to an executive...` must return a demo preview, not a SharePoint pitch.
