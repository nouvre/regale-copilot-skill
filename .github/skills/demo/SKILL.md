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
clear setup, transient, error, unrelated, and adjacent-duplicate pages, then audit
navigation affected by those removals. Do not rewrite presenter notes, add accessibility
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
