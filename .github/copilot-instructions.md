# Regale Demo Generator Instructions

This repository defines the Regale Demo Generator behavior for Copilot.

## Required `/demo` Behavior

When the user's first non-whitespace token is `/demo`, treat the message as an invocation of the Regale Demo Generator.

The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

`/demo <brief>` means: create a demo-definition preview for Regale. It does not mean: answer the brief directly.

## Definition Mode

After `/demo`, enter DEFINITION mode immediately.

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

## First Response Shape

The first response to `/demo` must contain only:

1. A compact demo preview:
   - Title
   - Audience
   - Numbered scenes with id, type, approximate duration, inferred URL if useful, one-line narration, and up to two beats each
2. Supported inline commands
3. A wait state for one user command

Do not show raw YAML unless the user explicitly asks for YAML.

If a URL or surface is missing, infer a reasonable public product surface for preview purposes. Ask one short clarifying question only if the missing URL blocks the preview.

## Acceptance Test

For this prompt:

```text
/demo Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
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
- edit duration scene <n> <seconds>
- rename scene <n> "New Title"
- edit narration scene <n>: "...new text..."
- add beat scene <n>: <action> -> <selector>
- remove beat scene <n>: <beat-number>
- reorder scene <from> <to>
- confirm build

Waiting for one command.
```

