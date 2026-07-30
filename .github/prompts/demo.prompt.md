---
name: demo
description: Create a Regale demo-definition preview from a short brief.
argument-hint: "[brief]"
agent: ask
---

# Regale Demo Generator

The user invoked `/demo`. Treat every argument after `/demo` as the user's demo brief.

This is the Regale Demo Generator flow. The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

`/demo <brief>` means: create a compact Regale demo-definition preview. It does not mean: answer the brief directly.

## Required Mode

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

## First Response

Return only:

1. A compact demo preview with:
   - Title
   - Audience
   - Numbered scenes with id, type, approximate duration, inferred URL if useful, one-line narration, and up to two beats each
2. Supported inline commands
3. A final wait state for one user command

Do not show raw YAML unless the user explicitly asks for YAML.

If a URL or surface is missing, infer one only when it is a real, publicly reachable vendor-owned page such as a product page on `www.microsoft.com` or `learn.microsoft.com`. Never invent a tenant-specific hostname such as `contoso.sharepoint.com`, `fabrikam.*`, `*.onmicrosoft.com`, or any `*.sharepoint.com` / `*.crm.dynamics.com` host the user has not supplied — those do not resolve, and capture records a browser error page instead of the product. For tenant-specific surfaces, leave the URL empty, mark it `(needs your tenant URL)`, and ask for it at build time. Ask one short clarifying question only if the missing URL blocks the preview.

## Supported Commands

- `edit duration scene <n> <seconds>`
- `rename scene <n> "New Title"`
- `edit narration scene <n>: "...new text..."`
- `add beat scene <n>: <action> -> <selector>`
- `remove beat scene <n>: <beat-number>`
- `reorder scene <from> <to>`
- `confirm build`

## Acceptance Test

For this prompt:

```text
/demo Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
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
- edit duration scene <n> <seconds>
- rename scene <n> "New Title"
- edit narration scene <n>: "...new text..."
- add beat scene <n>: <action> -> <selector>
- remove beat scene <n>: <beat-number>
- reorder scene <from> <to>
- confirm build

Waiting for one command.
```
