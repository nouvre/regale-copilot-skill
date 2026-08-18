# Regale Demo Generator Agent Instructions

## Open-draft refinement

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), this is not a product-demo brief and does not enter definition mode.
Do not ask what kind of refinement to prioritize and do not ask for `confirm build`.

Read `.github/skills/demo/BUILD_PIPELINE.md` and immediately follow **Refining an
already-built draft**. The scope is fixed: remove clear setup/transient/error/unrelated
pages and adjacent duplicates, then verify navigation affected by those removals. Do not
rewrite presenter notes, add accessibility descriptions, or rebuild blocked scenes unless
the user separately requests that work after refinement.
Missing descriptions or notes are not refinement defects: never call `set_text` in this
mode. Do not hide an unwanted page; remove it only after a visual **Remove** verdict, or
retain it as **Review** when uncertain. Refinement writes are limited to `remove_page`,
navigation repair on retained pages, and `save_project`.
Do not count, mention, or remediate description/note completeness in the refinement status
or summary.

If no Regale tools are visible or no project is open, stop and state that concrete
precondition instead of offering a refinement menu.
The first response must be a short status statement followed by Regale tool calls; it
must not be a question, prioritization prompt, or choice list.


**Mandatory refinement gates:**

1. Confirm `remove_page`, `get_shapes`, and `save_project` are visible. Save the open
   project, then run the demo skill's read-only
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH"` against its saved `.rglx` path. This is
   the only shell command allowed in refinement mode.
2. Read `report.json` and inspect every extracted thumbnail in section/page order with
   Copilot's local image viewer. Do not call `capture_view` or `render_page`; those
   image-returning Regale MCP calls can stall the client. Assign **Keep**, **Remove**, or
   **Review** to every visible page before writing project content in that section.
3. Treat an exact adjacent duplicate as removal evidence unless it is the only navigation
   source. Confirm text-signal leads in the thumbnail. Remove clear setup, modal, blocked,
   transient, unrelated, and duplicate pages highest page number first.
4. Re-list pages and inspect shapes only where removal may affect navigation. Limit
   property writes to navigation repair on retained shapes.
5. Save each completed section. State pages inspected, removals and reasons, **Review**
   pages, and navigation verified. Otherwise report a saved partial and its resume point.

If the inspector or local image viewer is unavailable, stop and name that precondition.
Do not fall back to Regale image calls, metadata-only editing, page hiding, or text work.

Forbidden in refinement mode: `capture_view`, `render_page`, `set_text`, capture/recording
creation tools, product interaction, accessibility work, presenter-note work,
section/title edits, and hiding pages.

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
