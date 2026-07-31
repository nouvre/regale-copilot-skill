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

After `confirm build`, transition to BUILD mode: read `.github/skills/demo/BUILD_PIPELINE.md` and follow it. That file is the single source of truth for the build; do not build from memory. Do not merely restate or rebuild the definition in chat. If no `regale_studio_uat-*` MCP tools are visible, stop and tell the user the Regale MCP tools are unavailable.

## First Response Shape

The first response to `/demo` must contain only:

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
- edit duration scene N SECONDS
- rename scene N "New Title"
- edit narration scene N: "new text"
- add beat scene N: action
- remove beat scene N: beat-number
- reorder scene FROM TO
- confirm build

Waiting for one command.
```
