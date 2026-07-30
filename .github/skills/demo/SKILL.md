---
name: demo
description: Create a Regale demo-definition preview from a short user brief. Use when the user asks for /demo, wants a Regale demo, or needs a short product-demo storyboard before building in Regale Studio.
---

# Regale Demo Generator

When this skill is invoked, treat the user's text as a Regale demo brief.

The user does not need to say "Regale", "Regale skill", "demo generator", "surface", or provide a URL.

`/demo <brief>` means: create a compact Regale demo-definition preview. It does not mean: answer the brief directly.

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

Do not show raw YAML unless the user explicitly asks for YAML.

If a URL or surface is missing, infer one only when it is a real, publicly reachable page owned by the vendor, such as a product marketing or documentation page on `www.microsoft.com` or `learn.microsoft.com`.

Never invent a tenant, org, or account-specific hostname. Those do not resolve, and capture will record a browser error page instead of the product. Specifically, never use:

- Placeholder tenants such as `contoso.*`, `fabrikam.*`, `adventureworks.*`, `example.com`, or any `*.example` host.
- Any `*.sharepoint.com`, `*.crm.dynamics.com`, `*.onmicrosoft.com`, `*.service-now.com`, or similar tenant host that the user has not given you.

When a scene needs a tenant-specific surface, leave the URL empty and mark it `URL: (needs your tenant URL)`. Do not guess one. Ask for it once at build time, not during the preview.

Ask one short clarifying question only if the missing URL blocks the preview.

## Supported Commands

- `edit duration scene <n> <seconds>`
- `rename scene <n> "New Title"`
- `edit narration scene <n>: "...new text..."`
- `add beat scene <n>: <action> -> <selector>`
- `remove beat scene <n>: <beat-number>`
- `reorder scene <from> <to>`
- `confirm build`

## Build Mode

When the user types exactly `confirm build`, transition to BUILD mode.

Do not merely restate or rebuild the demo-definition in chat. BUILD mode means pushing the approved preview into Regale Studio through the `regale-studio-uat` MCP server.

First, inspect available MCP tools. If no `regale_studio_uat-*` tools are available, stop and say:

```text
I am ready to build, but I cannot see the Regale Studio MCP tools yet. Confirm Regale Studio UAT is running, the MCP bridge is configured in $HOME\.copilot\mcp-config.json, and restart GitHub Copilot.
```

If Regale tools are available, run this sequence:

1. Call `regale_studio_uat-get_agent_permissions`.
2. Call `regale_studio_uat-get_open_project`.
3. Identify the products/surfaces required by the approved scenes:
   - Use scene titles, URLs, narration, and beats to derive a short list such as SharePoint, Microsoft Teams, Microsoft 365 admin center, Dynamics 365, or Copilot.
   - Include URLs only when they are real and reachable, following the URL rules in First Response.
   - List every scene URL verbatim and ask the user to confirm or correct each one before any capture begins. For scenes marked `(needs your tenant URL)`, ask for the real URL now and do not proceed with a placeholder.
   - Present a login/prep checklist and ask the user to open each product in a browser and sign in.
   - Present a capture-method recommendation before capture begins:
     - Recommend HTML Capturer for public pages or when the user can sign in inside Regale's Capturer profile.
     - Recommend native browser/window or monitor capture for already-signed-in browser sessions, but warn that it may return zero frames in Parallels or other virtualized display environments.
     - Recommend manual Regale recording if authenticated native capture returns zero frames and the user does not want to sign in again inside HTML Capturer.
   - Do not capture yet. Wait for the user to confirm the required products are open and signed in.
4. Discover whether screen/window capture tools are available:
   - `regale_studio_uat-list_capture_targets`
   - `regale_studio_uat-set_capture_target`
   - `regale_studio_uat-start_capture`
5. If screen/window capture tools are available, use the native capture-target workflow:
   - Call `regale_studio_uat-list_capture_targets`.
   - Present the available targets in plain language, including monitor names, explicit browser/window targets if listed, and Active Window title.
   - Do not default to `Active Window` when the user is chatting with GitHub Copilot on the same Windows desktop. Copilot will usually be the active window, so that target often records Copilot instead of the browser.
   - Prefer an explicit browser window target by title when available, such as Microsoft Edge or the named Microsoft product.
   - If explicit window targets are not available, prefer the monitor that contains the prepared browser window. Ask the user to move Copilot off that monitor when possible.
   - Use `Active Window` only if the user has a reliable way to make the browser active before capture starts, such as a second monitor or a delayed switch workflow.
   - Call `regale_studio_uat-set_capture_target` with the chosen target.
   - Tell the user which target is selected.
   - For each scene, tell the user which product/window to bring forward and what screen state to prepare.
   - If the selected target is a monitor and Copilot is on that monitor, ask the user to click confirm, then immediately Alt+Tab or click into the browser. Wait several seconds before calling `regale_studio_uat-start_capture`.
   - If the selected target is an explicit browser/window target, call `regale_studio_uat-start_capture` when the user confirms the screen is ready.
   - If capture returns zero frames or the wrong surface, do not automatically switch to HTML Capturer. Re-list capture targets and ask the user to choose an explicit browser/window target or monitor target.
   - After each capture, add narration/notes and hotspots using the available Regale page/object tools.
6. Use the HTML Capturer workflow only if screen/window capture tools are unavailable or the user explicitly chooses HTML Capturer after being told it uses a separate browser profile and may require signing in again:
   - Call `regale_studio_uat-get_capturer_state`.
   - If the capturer is not open, call `regale_studio_uat-open_html_capturer`.
7. For each approved scene in HTML Capturer mode:
   - Call `regale_studio_uat-navigate_capturer` with the scene URL.
   - Call `regale_studio_uat-wait_for_capturer` with a reasonable timeout.
   - Verify the intended surface actually loaded before capturing anything. `wait_for_capturer` succeeding only means the browser finished rendering something, which includes error pages. Check the capturer's current URL, page title, and visible text using `regale_studio_uat-get_capturer_state` or the closest available tool, and treat all of the following as load failures:
     - Browser error pages, including "Hmmm… can't reach this page", "This site can't be reached", "server IP address could not be found", `ERR_NAME_NOT_RESOLVED`, `ERR_CONNECTION_REFUSED`, or any DNS/connection error text.
     - HTTP 4xx or 5xx error pages.
     - A redirect to a sign-in or consent page when the scene expected signed-in content.
   - On a load failure, do not call `regale_studio_uat-capture_html_page` for that scene. Never capture an error page as a slide. Stop, report the exact URL that failed and what the page showed, and ask the user for a working URL before continuing.
   - Call `regale_studio_uat-set_capture_size_mode` for 1920x1080.
   - Call `regale_studio_uat-pause_page_motion`.
   - Call `regale_studio_uat-capture_html_page`.
   - Add the scene narration to the captured slide/page description using the available text-setting tool.
   - Add presenter notes if the available tools support it.
   - Place click hotspots for beats when matching DOM targets can be found. If a target cannot be found, warn and continue.
   - Render or verify the page if the available tools support it.
8. Summarize the result with slide count, skipped hotspots, and any manual follow-up needed.

If a listed tool name differs in the actual MCP tool list, use the closest Regale Studio MCP tool by purpose. Never claim the demo was pushed to Regale unless at least one Regale MCP capture/build tool succeeded.

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
