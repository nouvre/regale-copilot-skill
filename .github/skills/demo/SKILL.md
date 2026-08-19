---
name: demo
description: Create a Regale demo-definition preview from a short user brief. Use when the user wants a Regale demo, or needs a short product-demo storyboard before building in Regale Studio.
---

# Regale Demo Generator

When this skill is invoked, treat the user's text as a Regale demo brief.

The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

A demo brief means: create a compact Regale demo-definition preview. It does not mean: answer the brief directly.

## Open-Draft Refinement

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), this is not a demo brief. Do not enter definition mode, ask what to
prioritize, or require `confirm build`.

Read `BUILD_PIPELINE.md`, in this skill's folder, and immediately follow **Refining an
already-built draft**. The scope is page cleanup and resulting navigation only: remove
clear setup, transient, error, unrelated, and package-equivalent duplicate pages, then
verify the retained demo flow. Do not rewrite presenter notes, add accessibility
descriptions, or rebuild blocked scenes unless the user asks separately. If Regale tools
are unavailable or no project is open, state that precondition instead of offering a menu.
Missing descriptions or notes are not refinement defects: never call `set_text` in this
mode. Do not hide an unwanted page; remove it only after a visual **Remove** verdict, or
retain it as **Review** when uncertain. Refinement writes are limited to `remove_page`,
navigation repair on retained pages, and `save_project`.
Do not count, mention, or remediate description/note completeness in the refinement status
or summary.
The first response must be a short status statement followed by Regale tool calls; it
must not be a question, prioritization prompt, or choice list.


**Mandatory refinement gates:**

1. Confirm `remove_page`, `get_shapes`, and `save_project` are visible. Save once, then run
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH" -CreateBackup`. Do not remove anything
   unless the report contains an existing `backupPath`.
2. Inspect every thumbnail as a starting frame, not the whole page. Also read its build
   timeline, HTML/baseline fingerprints, narration, and navigation roles. A matching
   thumbnail is never removal evidence. Assign **Keep**, **Remove**, or **Review** to every
   visible page before writes. Do not call `capture_view` or `render_page`.
3. Define each section's retained entry, action/transition, and audience-facing outcome.
   If all three cannot be identified, make no deletions in that section. Preserve build
   timelines, navigation sources/targets, entry/outcome pages, and unique narration unless
   another retained page demonstrably fulfills the same role.
4. Automatically remove at most `max(1, floor(original pages * 0.25))` pages per section,
   never two consecutive pages, and never leave a multi-page section with fewer than two.
   Larger plans require explicit user approval. Remove approved pages highest number first.
5. Re-list and inspect shapes on every retained page in the changed section, repair
   dangling navigation, save, rerun the inspector without `-CreateBackup`, and verify the
   entry/action/outcome flow remains intact. Report the backup path and flow check.

If the project has no saved path, save it and read the path again. If the inspector or
local image viewer is unavailable, stop and report that exact precondition; do not fall
back to Regale screenshot calls, metadata-only editing, hiding pages, or text polishing.

Forbidden in refinement mode: `capture_view`, `render_page`, `set_text`, capture/recording
creation tools, product interaction, accessibility work, presenter-note work,
section/title edits, and hiding pages.

## Definition Mode

Enter DEFINITION mode immediately.

Before the user types exactly `confirm build`, do not:

- Answer with a standalone pitch, script, summary, or recommendation.
- Rename the chat or session.
- Call MCP tools.
- Start background agents.
- Write files.
- Build, save, or publish anything.

## First Response

Return only:

1. A compact demo preview with title, audience, and numbered scenes.
2. For each scene: id, type, approximate duration, inferred URL if useful, one-line narration, and up to two beats.
3. Supported inline commands.
4. A final wait state for one user command.

**Always print the command list inside a fenced code block.** Chat renders your reply as
markdown, so angle-bracket placeholders written as bare text are treated as HTML tags
and silently deleted — `edit duration scene <n> <seconds>` reaches the user as
`edit duration scene`, and they cannot see where the values go. Use the plain
placeholders shown in the acceptance test (`N`, `SECONDS`, `FROM`, `TO`) and keep the
whole block fenced.

Do not show raw YAML unless the user explicitly asks for YAML.

Each scene becomes a section in Regale, and each beat becomes a page the viewer clicks through. Write beats as discrete states, not as long summaries.

If a URL or surface is missing, infer one only when it is a real, publicly reachable page owned by the vendor, such as a product marketing or documentation page on `www.microsoft.com` or `learn.microsoft.com`.

Never invent a tenant, org, or account-specific hostname. Those do not resolve, and capture will record a browser error page instead of the product. Specifically, never use:

- Placeholder tenants such as `contoso.*`, `fabrikam.*`, `adventureworks.*`, `example.com`, or any `*.example` host.
- Any `*.sharepoint.com`, `*.crm.dynamics.com`, `*.onmicrosoft.com`, `*.service-now.com`, or similar tenant host that the user has not given you.

When a scene needs a tenant-specific surface, leave the URL empty and mark it `URL: (needs your tenant URL)`. Do not guess one. Ask for it once at build time, not during the preview.

Only the first URL of a scene is needed. The build reaches every later screen by clicking inside the live app, so do not try to supply a URL per beat.

Ask one short clarifying question only if the missing URL blocks the preview.

## Supported Commands

- `edit duration scene N SECONDS`
- `rename scene N "New Title"`
- `edit narration scene N: "new text"`
- `add beat scene N: action` — optionally `-> target`, where the target may be plain
  language ("the Sign in button") or a CSS selector. The build finds the element
  itself, so the target is a hint, not a requirement.
- `remove beat scene N: beat-number`
- `reorder scene FROM TO`
- `confirm build`

Accept the angle-bracket form too if a user types it, but never print it.

## Build Mode

When the user types exactly `confirm build`, transition to BUILD mode.

**Read `BUILD_PIPELINE.md`, in this skill's folder, and follow it.** It is the single
source of truth for the build and is kept deliberately out of this file so it cannot
drift between copies. Do not build from memory or from an older copy of these steps.

Two things that apply before you read it:

- Do not merely restate or rebuild the demo-definition in chat. BUILD mode means
  pushing the approved preview into Regale Studio through the `regale-studio-uat` MCP
  server.
- If no `regale_studio_uat-*` tools are available, stop and say:

  ```text
  I am ready to build, but I cannot see the Regale Studio MCP tools yet. Confirm Regale Studio UAT is running, the MCP bridge is configured in %USERPROFILE%\.copilot\mcp-config.json, and restart GitHub Copilot.
  ```

## Acceptance Test

For this prompt:

```text
Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
```

Do not provide a SharePoint pitch. Provide a compact Regale demo preview similar to:

```text
Title: SharePoint Executive Intranet Pitch
Audience: Executive

1. business-value / Hook / ~20s
   Narration: Open with scattered files as a business speed and governance problem.
   Beats:
   - Frame scattered content as a decision-speed risk.
   - Position SharePoint as the governed intranet foundation.

2. single-governed-intranet / Value / ~35s
   Narration: Show how one governed intranet gives teams a trusted place to find, share, and act on content.
   Beats:
   - Highlight one authoritative content home.
   - Connect governance to lower risk and less duplicate work.

3. faster-decisions / Outcome / ~30s
   Narration: Close on less search time, clearer ownership, and faster cross-org decisions.
   Beats:
   - Tie findability to faster decision cycles.
   - Recommend a focused pilot with measurable outcomes.

Supported commands:
- edit duration scene N SECONDS
- rename scene N "New Title"
- edit narration scene N: "new text"
- add beat scene N: action
- remove beat scene N: beat-number
- reorder scene FROM TO
- confirm build

Waiting for one command.
```
