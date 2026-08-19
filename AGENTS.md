# Regale Demo Generator Agent Instructions

## Open-draft refinement

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), this is not a product-demo brief and does not enter definition mode.
Do not ask for `confirm build`. Ask the user to choose `conservative` (recommended;
uncertain pages become Review) or `aggressive` (edits a separate copy and may leave broken
navigation). Make no tool calls before the choice. Accept the mode appended to the
original prompt or as the immediate reply.

After mode selection, read `.github/skills/demo/BUILD_PIPELINE.md` and follow **Refining
an already-built draft**. The scope is fixed: remove clear setup/transient/error/unrelated
pages and package-equivalent duplicates, then verify navigation affected by removals. Do not
rewrite presenter notes, add accessibility descriptions, or rebuild blocked scenes unless
the user separately requests that work after refinement.
Missing descriptions or notes are not refinement defects: never call `set_text` in this
mode. Do not hide an unwanted page; remove it only after a visual **Remove** verdict, or
retain it as **Review** when uncertain. Refinement writes are limited to `remove_page`,
navigation repair on retained pages, and `save_project`.
Do not count, mention, or remediate description/note completeness in the refinement status
or summary.

After mode selection, if no Regale tools are visible or no project is open, stop and state
that concrete precondition. Otherwise start with a short status statement and tool calls.


**Mandatory refinement gates:**

1. Save the open project, then run
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH" -CreateBackup`. Do not remove anything
   unless the report contains an existing `backupPath`.
2. Treat each thumbnail as a starting frame. Also inspect its build timeline, HTML state,
   narration, and navigation roles. Matching thumbnails are never removal evidence.
   Review each predecessor/current/successor trio and make a defect ledger for onboarding,
   setup/sign-in, valueless intermediate, and visibly redundant adjacent states. Record
   the section/page ids and retained predecessor/successor for each candidate.
3. Preserve a retained entry, action/transition, and audience-facing outcome per section.
   Preserve build timelines, navigation sources/targets, and unique narration unless
   another retained page fulfills the same role.
4. Automatically remove at most `max(1, floor(original pages * 0.25))` pages per section,
   never two consecutive pages, and never leave a multi-page section below two pages.
   Larger plans require explicit user approval.
5. For locked/theme-controlled inbound navigation, unlock and retarget the shape to the
   retained successor and verify it **before** deletion. One failed repair makes that page
   **Review** with no deletion or retry. Re-inspect after all verified changes.

Review is a successful conservative verdict. Finish `complete with review items` when all
pages were inspected and flow is valid; use `blocked` only when the audit or restoration
itself cannot complete.

In aggressive mode, create and open the inspector's `aggressiveCopyPath`; never modify the
original. Visual evidence is still required, but deletion limits and failed-navigation
protection are waived in the copy. Resolve the defect ledger before unrelated cleanup.
Unique timeline data does not protect a confirmed onboarding, valueless intermediate, or
visually redundant page when its neighbors retain the action and outcome. If a section has
no audience-facing outcome, retain it as **Review** instead of shortening it into a false
story. Reinspect every ledger item, retain one visible page per section, list all broken
navigation, identify `aggressiveCopyPath` as the project currently open in Regale, label
the copy not presentation-ready, and never publish it.

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
