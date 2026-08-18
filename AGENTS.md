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


**Mandatory tool gates:**

1. Confirm both `render_page` and `remove_page` are visible. If either is missing, stop
   and name the missing tool. Do not substitute metadata inspection, page hiding, or text
   editing.
2. Call `render_page` once for every visible page, in section/page order, without the
   objects overlay. `get_page` does not satisfy visual inspection. Make no writes until
   every page in the current section has a rendered **Keep**, **Remove**, or **Review**
   verdict.
3. Apply clear **Remove** verdicts with `remove_page`, highest page number first. Never
   use `update_properties` on a project, section, or page during refinement.
4. Re-list pages, then call `get_shapes` only on retained pages whose navigation may
   have changed. Property writes are allowed only on shapes to repair those click actions.
5. Save each completed section. Refinement is complete only when the number of rendered
   verdicts equals the original visible-page count. The final summary must state pages
   rendered, pages removed with reasons, **Review** pages, and navigation verified.
   Otherwise report a saved partial refinement and the exact resume point.

Forbidden in refinement mode: `set_text`, capture/recording tools, product interaction,
shell commands, accessibility work, presenter-note work, section/title edits, and hiding
pages.

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
