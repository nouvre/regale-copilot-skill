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
- `add beat scene <n>: <action> -> <selector>`
- `remove beat scene <n>: <beat-number>`
- `reorder scene <from> <to>`
- `confirm build`

Acceptance test: `/demo Pitch SharePoint to an executive...` must return a demo preview, not a SharePoint pitch.

