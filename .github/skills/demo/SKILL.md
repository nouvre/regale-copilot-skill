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
   - Name the product and the screen state each scene needs. In the native capture path the user drives the browser, so do not ask for or invent URLs here. Scene URLs are prep hints only.
   - Present a login/prep checklist and ask the user to open each product in a browser and sign in.
   - Do not recommend a capture method yet, and do not capture yet. Wait for the user to confirm the required products are open and signed in.
4. Discover the real capture capability before recommending anything. Never choose a capture method blind.
   - Call `regale_studio_uat-list_capture_targets` and read what actually came back.
   - Confirm a project is open. `regale_studio_uat-start_capture` fails without one. If step 2 showed no open project, create or open one before capturing.
   - Only then present a capture-method recommendation, grounded in the targets that were actually returned:
     - Default to native monitor capture. The user signs in once and navigates to each scene state, so this path reaches authenticated, tenant-specific, and deep-linked screens that URL-driven capture cannot.
     - Offer HTML Capturer only for genuinely public, unauthenticated pages, and only as an explicit user choice. It runs a separate browser profile that is not signed in, and it can only reach pages addressable by URL.
     - Do not steer the user toward HTML Capturer on the grounds that native capture might fail. If native capture actually returns zero frames, which can happen in Parallels or other virtualized display environments, report it and offer HTML Capturer or manual Regale recording as recovery options at that point.
   - State plainly which path you are taking and why before running it.
5. If screen/window capture tools are available, use the native capture-target workflow:
   - Call `regale_studio_uat-list_capture_targets`. It returns exactly two kinds of target: each monitor (index, name, bounds, DPI) and the single special `Active Window` target. Per-application and per-browser-window targets do not exist. Never wait for one, and never treat their absence as a reason to abandon native capture.
   - Present the available monitors and the current `Active Window` title in plain language.
   - Prefer the monitor showing the prepared browser. Monitor capture records whatever is visible on that screen, so a single-monitor machine is fully supported as long as the user brings the browser to the front before capture starts.
   - Do not default to `Active Window` when the user is chatting with GitHub Copilot on the same desktop. Copilot will usually be the foreground window, so that target often records Copilot instead of the browser.
   - A single monitor shared with Copilot is not a blocker and is not a reason to fall back to HTML Capturer.

   Run this sequence for each scene:

   a. Call `regale_studio_uat-set_capture_target` with the chosen monitor index or name. Tell the user which target is selected.
   b. Set the capture mode with `regale_studio_uat-set_capture_mode`:
      - Use `single` for a scene made of discrete screens. Each user click captures one frame, which suits scene-based demos and keeps the user in control.
      - Use `continuous` for a flow that must be recorded over time. Pass `framesPerSecond` (1-24) and a `maxSeconds` auto-stop so recording ends on its own if the user cannot get back to chat.
   c. Tell the user which product/window to bring forward and exactly what screen state to prepare.
   d. Call `regale_studio_uat-set_studio_window` with state `minimize`. Monitor capture records the whole screen, so Regale Studio must be hidden or it will appear in the frames. Capture does not move this window for you.
   e. Wait several seconds after the user confirms, so the window switch finishes before recording starts.
   f. Call `regale_studio_uat-start_capture`.
   g. In `single` mode, tell the user to click once per screen they want captured. In `continuous` mode, tell them to drive the flow now.
   h. Call `regale_studio_uat-end_capture` when the scene is done, or let `maxSeconds` stop it.
   i. Call `regale_studio_uat-set_studio_window` with state `restore` to bring Studio back. `end_capture` does not restore it.
   j. Frames are processed asynchronously. Wait a moment, then re-query with `regale_studio_uat-get_page` or `regale_studio_uat-get_open_project` before stating what was captured.
   - If capture returns zero frames or the wrong surface, do not automatically switch to HTML Capturer. Report what was actually captured, then retry with a longer delay or a different monitor.
   - After each capture, add narration/notes and hotspots using the available Regale page/object tools.
6. Use the HTML Capturer workflow only if screen/window capture tools are unavailable or the user explicitly chooses HTML Capturer after being told it uses a separate browser profile and may require signing in again:
   - This is the only path that needs URLs. Apply the URL rules from First Response here.
   - List every scene URL verbatim and ask the user to confirm or correct each one before capturing. For scenes marked `(needs your tenant URL)`, ask for the real URL now and never substitute a placeholder.
   - If a scene needs authenticated or tenant-specific content, say so plainly: HTML Capturer is the wrong path for it because its profile is not signed in. Recommend native capture of the user's signed-in window instead.
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
