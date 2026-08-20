# Regale Demo Generator Instructions

This repository defines the Regale Demo Generator behavior for Copilot.

## Required Behavior

When the user gives a product-demo brief, treat the message as an invocation of the Regale Demo Generator.

The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

A demo brief means: create a demo-definition preview for Regale. It does not mean: answer the brief directly.

## Open-Draft Refinement

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), do not enter definition mode or require `confirm build`. Ask the user
to choose `conservative` (recommended; uncertain pages become Review) or `aggressive`
(edits a separate copy and may leave broken navigation). Make no tool calls before the
choice. Accept the mode appended to the original prompt or as the immediate reply. Then
read `.github/skills/demo/BUILD_PIPELINE.md` and follow **Refining an already-built draft**.

The scope is page cleanup and resulting navigation only: remove clear setup, transient,
error, unrelated, and package-equivalent duplicate pages, then verify the retained demo
flow. Do not rewrite presenter notes, add accessibility descriptions, or rebuild
blocked scenes unless the user asks separately. If Regale tools are unavailable or no
project is open, state that precondition instead of offering a menu.
Missing descriptions or notes are not refinement defects: never call `set_text` in this
mode. Do not hide an unwanted page; remove it only after a visual **Remove** verdict, or
retain it as **Review** when uncertain. Refinement writes are limited to `remove_page`,
navigation repair on retained pages, and `save_project`.
Do not count, mention, or remediate description/note completeness in the refinement status
or summary.
After mode selection, start with a short status statement followed by Regale tool calls.


**Mandatory refinement gates:**

1. Save the open project, then run
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH" -CreateBackup`. Do not remove anything
   unless the report contains an existing `backupPath`.
2. Treat each thumbnail as a starting frame. Do not bulk-view all thumbnails as one
   gallery. Use `report.json.sequenceWindows` in section/page order and view each labeled
   previous/current/next trio together. Record whether current follows previous, next
   follows current, and removing current makes previous -> next more coherent without
   losing a stable outcome. Mark current **SequenceBreak** when that last test is true.
   Also inspect its build timeline, HTML state, narration, and navigation roles. Matching
   thumbnails are never removal evidence. Make a defect ledger for onboarding,
   setup/sign-in, valueless intermediate, prompt-only composer without visible context,
   and visibly redundant adjacent states. Record the section/page ids and retained
   predecessor/successor for each candidate.
   For generative-chat sections, transcribe a short visible prompt excerpt per page, mark
   whether a response is visible, and identify which prior prompt it answers. Flag a new
   prompt inserted before the prior prompt's response and a response preceded by a
   different prompt. Timeline metadata and page titles do not establish this continuity.
   Treat a stable response as the protected outcome, never as the continuity-removal
   candidate. For prompt A -> contextless prompt B -> response A, preserve prompt A and
   response A, remove only prompt B, and record both survivor page ids before writing.
   The ordered screenshot story controls the coherence verdict. Metadata may verify or
   block an edit but cannot make an incoherent middle screenshot part of the story.
   Sequence thumbnails are starting states. Do not mark a page with a distinct nonempty
   timeline **SequenceBreak** from starting thumbnails alone. Read timeline duration,
   segment/event counts, HTML fingerprints, and `surfaceKey`; preserve it unless terminal
   evidence confirms setup, error, onboarding, or a redundant outcome.
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
original. Refuse an open project whose filename contains `.aggressive-refine-` or whose
path is inside `Regale\Aggressive Refinements`; the user must reopen the original before
another run. Visual evidence is still required, but deletion limits and failed-navigation
protection are waived in the copy. Resolve the defect ledger before unrelated cleanup.
In aggressive mode, a visually confirmed **SequenceBreak** is **Remove** when previous ->
next is more coherent and current is not a stable outcome. Timeline, click, narration, or
navigation metadata alone cannot protect it.
A starting-thumbnail match is not terminal evidence. For each `surfaceKey` with at least
two original pages, retain its entry and strongest non-error outcome; absent terminal
evidence, default to the distinct page with the longest timeline. Aggressive mode still
requires separate approval to remove more than half of a section's original pages.
In aggressive mode, an exact adjacent thumbnail match is **Remove** unless objective
final-state evidence proves a distinct visible outcome; timeline data or a claimed outcome
role alone is insufficient. Remove an in-flight page between a request and stable response
unless its thumbnail communicates a unique audience-facing fact. Remove a prompt-only
composer between a retained request and response even when its prompt text differs. Keep
iterative prompting only when the page visibly includes the prior response and leads to a
separate retained outcome; different prompt text alone is not audience value.
Unique timeline data does not protect a confirmed onboarding, valueless intermediate, or
visually redundant page when its neighbors retain the action and outcome. A missing
section outcome does not protect unrelated confirmed junk when removal does not worsen
that gap; retain the gap as **Review** and do not delete other pages merely because the
section is incomplete. Reinspect every ledger item, retain one visible page per section,
list all broken navigation, rerun and review refreshed `sequenceWindows`, identify
`aggressiveCopyPath` as the project currently open in Regale, label
the copy not presentation-ready, and never publish it.
If all intended outcomes are missing after editing, or a multi-page original surface has
no outcome-capable retained page, discard the copy and report failed refinement.

If the inspector or local image viewer is unavailable, stop and name that precondition.
Do not fall back to Regale image calls, metadata-only editing, page hiding, or text work.

Forbidden in refinement mode: `capture_view`, `render_page`, `set_text`, capture/recording
creation tools, product interaction, accessibility work, presenter-note work,
section/title edits, and hiding pages.

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
