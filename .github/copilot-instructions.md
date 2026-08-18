# Regale Demo Generator Instructions

This repository defines the Regale Demo Generator behavior for Copilot.

## Required Behavior

When the user gives a product-demo brief, treat the message as an invocation of the Regale Demo Generator.

The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

A demo brief means: create a demo-definition preview for Regale. It does not mean: answer the brief directly.

## Open-Draft Refinement

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), do not enter definition mode and do not ask which refinement to
prioritize. Read `.github/skills/demo/BUILD_PIPELINE.md` and immediately follow
**Refining an already-built draft**. Do not require `confirm build`.

The scope is page cleanup and resulting navigation only: remove clear setup, transient,
error, unrelated, and adjacent-duplicate pages, then audit navigation affected by those
removals. Do not rewrite presenter notes, add accessibility descriptions, or rebuild
blocked scenes unless the user asks separately. If Regale tools are unavailable or no
project is open, state that precondition instead of offering a menu.
Missing descriptions or notes are not refinement defects: never call `set_text` in this
mode. Do not hide an unwanted page; remove it only after a visual **Remove** verdict, or
retain it as **Review** when uncertain. Refinement writes are limited to `remove_page`,
navigation repair on retained pages, and `save_project`.
Do not count, mention, or remediate description/note completeness in the refinement status
or summary.
The first response must be a short status statement followed by Regale tool calls; it
must not be a question, prioritization prompt, or choice list.


**Mandatory tool gates:**

1. Confirm `capture_view`, `set_selection`, and `remove_page` are visible. If any is
   missing, stop and name it. Do not substitute metadata inspection, page hiding, or text
   editing. `render_page` is not a bulk-refinement dependency.
2. For every visible page in section/page order, use `set_selection` to select that page,
   then `capture_view` on the Studio editor/workspace. `get_page` does not satisfy
   visual inspection. Assign **Keep**, **Remove**, or **Review** from that screenshot.
   Make no project-content writes until every page in the current section has a verdict.
3. Apply clear **Remove** verdicts with `remove_page`, highest page number first. Never
   use `update_properties` on a project, section, or page during refinement.
4. Re-list pages, then call `get_shapes` only on retained pages whose navigation may
   have changed. Property writes are allowed only on shapes to repair those click actions.
5. Save each completed section. Refinement is complete only when the screenshot-verdict
   count equals the original visible-page count. The final summary must state pages
   inspected, pages removed with reasons, **Review** pages, and navigation verified.
   Otherwise report a saved partial refinement and the exact resume point.

Do not call `render_page` unless one selected-page screenshot is genuinely ambiguous.
It gets one attempt on that page only. If any visual call consumes more than 60 seconds,
stop after it returns, save completed work, and report the stalled page rather than
starting another visual call.

Forbidden in refinement mode: `set_text`, capture/recording creation tools, product
interaction, shell commands, accessibility work, presenter-note work, section/title
edits, and hiding pages. `capture_view` is inspection, not capture creation.

## Definition Mode

Enter DEFINITION mode immediately.

In DEFINITION mode, do not:

- Answer with a standalone pitch, script, summary, or recommendation.
- Rename the chat or session.
- Call MCP tools.
- Start background agents.
- Write files.
- Build, save, or publish anything.

Stay in DEFINITION mode until the user types exactly:

```text
confirm build
```

After `confirm build`, transition to BUILD mode: read `.github/skills/demo/BUILD_PIPELINE.md` and follow it. That file is the single source of truth for the build; do not build from memory. Do not merely restate or rebuild the definition in chat. If no `regale_studio_uat-*` MCP tools are visible, stop and tell the user the Regale MCP tools are unavailable.

## First Response Shape

The first response to a brief must contain only:

1. A compact demo preview:
   - Title
   - Audience
   - Numbered scenes with id, type, approximate duration, inferred URL if useful, one-line narration, and up to two beats each
2. Supported inline commands
3. A wait state for one user command

Do not show raw YAML unless the user explicitly asks for YAML.

If a URL or surface is missing, infer one only when it is a real, publicly reachable vendor-owned page such as a product page on `www.microsoft.com` or `learn.microsoft.com`. Never invent a tenant-specific hostname such as `contoso.sharepoint.com`, `fabrikam.*`, `*.onmicrosoft.com`, or any `*.sharepoint.com` / `*.crm.dynamics.com` host the user has not supplied — those do not resolve, and capture records a browser error page instead of the product. For tenant-specific surfaces, leave the URL empty, mark it `(needs your tenant URL)`, and ask for it at build time. Ask one short clarifying question only if the missing URL blocks the preview.

## Acceptance Test

For this prompt:

```text
Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
```

The response must be a compact Regale demo preview, not a SharePoint pitch.

The preview should be similar to:

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
