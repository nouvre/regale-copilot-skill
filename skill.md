# Regale Demo Generator Skill

## Purpose
Enable non-developer Microsoft sellers to generate interactive product demos in Regale Studio through conversational chat. Users define demos either by:
- Providing plain-language goals (product, audience, target URL)
- Uploading a Word .docx with a two-column "What to say / What to show" table

The skill produces a YAML demo-definition for review/editing, then drives Regale Studio's local MCP server to build it automatically.

## Two Phases

### Phase 1: Definition (anywhere)
- Accept plain-language goals or parse a .docx file (two-column table only).
- Generate a YAML demo-definition conforming to the schema (title, audience, scenes with narration, beats, surface URLs, persona info).
- Present the definition in chat for user review and inline editing.
- Save the YAML to the chat workspace for build and future reuse.

### Phase 2: Build (VS Code + Regale Studio, same PC)
- Check connectivity: Regale Studio open, project loaded, Capturer ready.
- Discover available Regale MCP tools dynamically (do NOT hardcode tool names).
- Check permission groups: alert user if SaveProject or Publish are disabled (user can enable in Regale → AI & Agents → Permissions).
- For each scene: navigate Capturer to surface URL, stage persona, capture page, place interactive Objects (beacons) per beat, write narration, render for verification.
- Publish to Regale portal only if Publish permission is enabled.
- Report progress live; stop and instruct user on any blockers (missing permissions, project not open, etc).

## Interaction Flow

### Define
User: "I need a 5-minute demo of Microsoft Copilot for sales teams. [optional context paste or .docx upload]"

Agent:
1. If .docx: parse two-column table → YAML. If plain-language: extract goals → generate scaffold YAML.
2. Present YAML in chat (syntax-highlighted, editable).
3. Invite user to refine (edit scene narration, add/remove beats, adjust durations, etc).
4. Save final YAML to workspace.

### Build
User: "Build this demo. [Have you opened Regale Studio? Is Capturer open?]"

Agent:
1. Check preconditions (Regale Studio open, project exists, Capturer open; stop and instruct user if not).
2. List available Regale MCP tools and permission groups.
3. Alert: "SaveProject and Publish are disabled. Enable them in Regale → AI & Agents → Permissions to auto-save and publish."
4. For each scene:
   - Open Capturer, navigate to surface_url, wait for page settle.
   - Stage persona (swap name/avatar/logo if provided, hide overlays, freeze animations).
   - Set viewport size (1920x1080 desktop, or user-specified).
   - Capture page into Regale project (baseline + build timeline).
   - Query page elements; for each beat, place an interactive beacon/panel on the target_selector.
   - Write narration → page description; presenter_notes → page notes.
   - Render page to verify appearance.
   - Report scene completion.
5. Final summary: link to Regale project (or publish link if enabled).

## Error Handling
- Missing tool/permission: stop and explain exact step in Regale UI to enable.
- Page not found / selector not on page: warn and skip beat; allow user to manually place beacon in Regale later.
- Capturer timeout: allow retry or manual navigation.
- Never destructively modify live pages without explicit user confirmation (e.g., cookie banner removal OK; data deletion not OK).

## Tool Constraints
- Regale MCP is local-only (127.0.0.1, no cross-network access).
- Regale Studio must be running and a project must be open.
- HTML Capturer must be available for page staging and capture.
- SaveProject and Publish permissions are OFF by default.

## Implementation Notes
- Do NOT hardcode Regale tool names or argument schemas. On connection, call a tool-listing endpoint (or equivalent) and dynamically dispatch based on the returned tool list.
- Respond conversationally; keep the user informed of progress.
- For non-developers, avoid jargon (prefer "slide" over "page", "click hotspot" over "beacon", etc). Rephrase as needed.
