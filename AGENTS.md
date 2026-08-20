# Regale Demo Generator Agent Instructions

## Open-draft refinement

Support these focused read-only commands: `audit duplicates`, `audit screenshot order`,
`audit setup and errors`, `audit demo flow`, and `show refinement plan`. They do not ask
for conservative/aggressive and never modify Regale. Map them to
`scripts\run-refinement-audits.ps1 -Audits duplicates|sequence|setup-errors|flow|all` and
report its findings and protected successors. `apply refinement plan` asks for a mode,
reruns all audits with a fresh backup/copy, rejects a stale `projectSha256`, validates the
flow contracts, and executes only merged **Remove** verdicts.
Treat that merged plan as authoritative: never invent removals during execution or let one
pass promote another pass's **Review** item. Ambiguous pages require explicit page-level
approval in a later pass.

When the user's trimmed message is `refine the open draft` or `refine open draft`
(case-insensitive), this is not a product-demo brief and does not enter definition mode.
Do not ask for `confirm build`. Ask the user to choose `conservative` (recommended;
uncertain pages become Review) or `aggressive` (edits a separate copy and may leave broken
navigation). Make no tool calls before the choice. Accept the mode appended to the
original prompt or as the immediate reply.

After mode selection, read `.github/skills/demo/BUILD_PIPELINE.md` and follow **Refining
an already-built draft**. Run all focused audits and merge their plan before writes. The
scope is fixed: remove clear setup/transient/error/unrelated
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
   `scripts\run-refinement-audits.ps1 -ProjectPath "PATH" -Audits all -CreateBackup`.
   Read `refinement-plan.json`; do not remove anything unless it contains an existing
   `backupPath` and a merged **Remove** verdict.
2. Treat each thumbnail as a starting frame. Do not bulk-view all thumbnails as one
   gallery. Use `report.json.sequenceWindows` in section/page order and view each
   `sequenceWindowPath` contact sheet as one image. Its panels are labeled PREVIOUS,
   CURRENT (DECIDE), and NEXT; never substitute three separately viewed thumbnails. Record
   whether current follows previous, next
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
   Treat `redundantLeadInCandidate` as a narrow exception: visually confirm that the short
   predecessor and its reported same-surface successor start identically and that the
   successor contains the substantially stronger self-contained action/outcome. Remove
   only the predecessor when entry, successor, and outcome remain. Never remove the
   reported successor, and retarget inbound navigation directly to it.
   Treat `promptHandoffCandidate` as a concrete removal candidate. Its terminal composer
   prompt is already present in the reported successor baseline, and that successor adds
   the response. Remove only the handoff page, retain the successor, and retarget inbound
   navigation to it; hidden earlier DOM output does not protect a prompt-only screenshot.
3. Preserve a retained entry, action/transition, and audience-facing outcome per section.
   Record baseline outcome status and candidate ids. If the source lacks an outcome, mark
   **PreExistingOutcomeGap**, leave that section unchanged, and retain it as **Review**.
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
Resolve a visually confirmed `redundantLeadInCandidate` by removing its short predecessor,
retaining the reported stronger successor, and verifying navigation reaches the successor.
The signal never authorizes removal of both pages.
Resolve every `promptHandoffCandidate` by removing only the handoff page and retaining its
reported response-producing successor. Verify the successor repeats the prompt and still
adds output after navigation repair.
In aggressive mode, an exact adjacent thumbnail match is **Remove** unless objective
final-state evidence proves a distinct visible outcome; timeline data or a claimed outcome
role alone is insufficient. Remove an in-flight page between a request and stable response
unless its thumbnail communicates a unique audience-facing fact. Remove a prompt-only
composer between a retained request and response even when its prompt text differs. Keep
iterative prompting only when the page visibly includes the prior response and leads to a
separate retained outcome; different prompt text alone is not audience value.
Unique timeline data does not protect a confirmed onboarding, valueless intermediate, or
visually redundant page when its neighbors retain the action and outcome. Freeze every
section marked **PreExistingOutcomeGap** and retain the whole section as **Review**.
Reinspect every ledger item, retain one visible page per section,
list all broken navigation, rerun and review refreshed `sequenceWindows`, identify
`aggressiveCopyPath` as the project currently open in Regale, label
the copy not presentation-ready, and never publish it.
Discard the copy only when an outcome-capable page present in the source is absent after
editing. A **PreExistingOutcomeGap** is not a refinement failure; never require refinement
to create an outcome absent from the source.

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
