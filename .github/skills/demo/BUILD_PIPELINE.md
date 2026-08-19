# Regale Build Pipeline (canonical)

This is the single source of truth for BUILD mode. `SKILL.md` and
`.github/agents/regale-demo.agent.md` both point here. Edit this file, not a copy.

BUILD mode starts only after the user types exactly `confirm build`.

## Scope of v1

- **HTML Capturer is the default and only automated path.** It is a real browser the
  agent drives, so the whole build runs without the seller clicking through the
  product. Never switch away from it on your own initiative.
- **Native screen capture exists only as an advanced fallback** the seller explicitly
  chooses — for desktop applications (Outlook, Excel, Teams desktop) and anything not
  addressable by URL. It cannot be automated: the seller drives the browser or app by
  hand while the agent records. See [Advanced fallback](#advanced-fallback--native-screen-capture).
  Do not offer it because HTML capture *might* fail, only when it actually has or when
  the surface is genuinely not web-based.
- **Seller-led demos.** Narration becomes presenter notes. On-screen annotations for
  self-guided viewing are not in scope.
- **No publishing.** The build ends at a saved project. The seller reviews and
  publishes from Regale themselves.
- **Output is a working draft**, not a finished demo. Say so in the final summary.
- **Capture, do not provision the product being demonstrated.** This pipeline may stage
  cosmetic text and images, navigate, and click through an existing environment. It must
  not create or repair Dataverse tables, Power Apps, Power Automate flows, Power BI
  reports, connectors, tenant configuration, or other product resources. If a planned
  state is missing or invalid, skip that beat or scene, record the blocker, and continue.
  Product setup is a separate task that needs its own explicit request and time budget.

## Tool names

The names below are the expected Regale MCP tools. Discover the real list at runtime
and use the closest tool by purpose if a name differs. Never claim the demo was built
unless a Regale capture tool actually succeeded.

---

## Operational limits — binding on every phase

These limits are circuit breakers, not estimates. They override instructions elsewhere
to repair, retry, wait, or finish a scene.

### Build timebox

- Start an **active-build clock** with the first Regale tool call. The default timebox is
  **30 minutes of tool work**. Time visibly spent waiting for the seller to approve a
  tool or complete sign-in does not count.
- Check elapsed active-build time before every Regale tool call and again when it returns.
  Do not rely only on scene-boundary checks; a repair sequence can otherwise overrun the
  limit by itself.
- At 25 minutes, do not start another scene or optional pass. Finish reconciling the
  current scene, save a checkpoint, and report what remains.
- At 30 minutes, make no more capture, audit, or repair calls. Save immediately if the
  permission is available, then return a partial-build summary with the exact resume
  point. If Save is unavailable, stop and tell the seller to press Ctrl+S.
- Continuing past the timebox requires a **new explicit user message**. Silence is not
  permission to continue. Never extend the timebox because the project is nearly done.

### Bounded recovery

For one failed operation, the entire recovery budget is:

1. The original operation.
2. One diagnostic read that can change the next action.
3. One repair attempt.
4. One verification read.

If the repair or verification fails, stop working that defect. Record the page, scene,
operation, and error; save the partial draft; then continue with an independent scene if
the timebox permits. **Never try selector variants, repeat the same rejected anchor, or
enter a diagnose-repair-verify loop.** A cross-scene beacon that rejects its anchor or
action once gets at most the single repair attempt above, then becomes a handoff item.

### Waiting and lack of progress

- Never issue a wait longer than 60 seconds. After one wait, read state once. If the
  state has not advanced, apply bounded recovery or pause; do not stack more waits.
- Two consecutive tool calls with no observable project or capturer-state progress are
  a stall. Save and report the partial draft instead of making a third speculative call.
- Tool success is not progress unless a readback shows a changed URL, page count, shape,
  property, or saved state.

### Durable checkpoints

Save after project creation and after every reconciled scene, not only in Phase 5. A
checkpoint happens before announcing scene progress. If Save permission is off, an
unattended build is unsafe: stop in Phase 1 and ask the seller either to enable **Save
project files** or explicitly choose manual checkpoint mode, in which the build pauses
after every scene for the seller to press Ctrl+S.

---

## Phase 0 — Say what this costs, before you start

A build with visual refinement is roughly **30 tool calls per scene**, so a three-scene demo is 90–140 calls,
each one a separate model round trip. Do not convert that count into a confident runtime:
call latency varies too much, and field builds have taken hours. State the 30-minute
timebox and that the result may be a saved partial draft instead.

Sellers read silence as a hang and walk away from the window. Your **first message after
`confirm build`**, before any tool call, has to prevent that.

### The estimate is the first thing you write

Open with it. Not a heading, not a preamble — the estimate itself, as the opening
sentence:

> scene count · rough call count · 30-minute stop · saved partial-draft behavior

This is the half that is easy to lose, because the setup asks below feel more actionable
and they arrive in a tidy numbered list. They are not more important. A seller who
approves two toggles and then watches nothing happen for eleven minutes is exactly the
problem this phase exists to solve.

**A first message that opens "Two setup steps..." has failed this phase.** So has any
message where a reader cannot answer "how long will this take?" without asking.

### Then the setup asks

Copilot prompts on first use of each new tool name, and this build reaches for about
twenty across four phases. Left alone, approval prompts arrive at random points over
fifteen minutes, and each one silently parks the build until the seller happens to look.
So ask once, up front, folded together with the Phase 1 permission check.

### One message, in this order

```text
Building 3 scenes is roughly 105 Regale calls. I'm timeboxing this build to 30 minutes of
tool work: at that point I will save and report the exact partial result rather than keep
retrying. I will post progress and a saved checkpoint after every scene.

Before I start, two toggles so it doesn't stop halfway:

1. Turn on "allow all tools" for this session in Copilot. Otherwise I'll ask you to
   approve each new Regale tool as I first reach for it, and I stop dead until you
   answer. If you'd rather approve them one by one, that's fine - I've front-loaded
   most of them, so expect a cluster of prompts early and a few more during the build.
2. In Regale Studio -> Home ribbon -> AI & Agents -> Permissions, confirm Read project
   content, Edit project content, Browser automation, and Save project files are on.
   Without Save, I must pause after every scene for you to press Ctrl+S.

Tell me when both are done and I'll start.
```

The opening paragraph is **not optional garnish** — it is the phase. The numbered list is
the cheap part. Scale the call count to the actual plan at roughly thirty calls per scene,
but do not promise a completion time. The operational promise is the stop time.

Two caveats worth knowing, though you do not need to recite them:

- Allow-all is **per session**. Resuming a chat later resets it, so a build picked up
  after a pause needs it turned on again.
- Some enterprise-managed GitHub accounts block allow-all entirely. If the seller says
  the toggle is unavailable, do not fight it — warn them that approvals will arrive
  throughout and to keep the window in view.

Report progress at each scene boundary — "scene 2 of 4 recorded, 5 pages, beacons on all
5" — so the silence between them is legible. Report the beacons from the audit, not from
the fact that recording was supposed to place them.

If the canary check in Phase 4 finds recording is not placing beacons on this surface, the
build switches to placing them by hand only while the original timebox remains. Say that
the saved draft may contain fewer scenes; never extend the deadline silently.

## Phase 1 — Preconditions

1. Confirm `regale_studio_uat-*` tools are visible. If not, stop:

   ```text
   I can't see the Regale Studio MCP tools. Confirm Regale Studio is running, the MCP
   bridge is configured, and restart GitHub Copilot.
   ```

2. `get_agent_permissions`. Required groups and what to do if they are off:

   | Group | Needed for | If off |
   |---|---|---|
   | Read project content | Everything | Stop. Ask the user to enable it. |
   | Edit project content | Everything | Stop. Ask the user to enable it. |
   | Browser automation | All capture | Stop. Ask the user to enable it. |
   | Save project files | Checkpoints and cancellation recovery | Stop unless the seller explicitly chooses manual checkpoint mode. |
   | Publish | Not used in v1 | Ignore. |

   Phase 0 already asked for these. This step verifies rather than re-asks. If something
   is still off, say which one and where — Regale Studio → Home ribbon → AI & Agents →
   Permissions — in **one** message. Do not start capturing and fail halfway, and do not
   drip permission requests out one at a time.

   Never call `read_capture_credentials`. It is off by default, and it would put
   plaintext passwords into the chat transcript. The seller signs in themselves.

3. `get_open_project`.
   - A project is open → use it.
   - No project → create one from the branded template (Phase 2).

### The opening sweep — cluster the approvals

Copilot asks permission the **first** time it sees each tool name, so the timing of those
prompts is decided by the order you first reach for things. Left to fall out naturally,
the first use of `list_capture_profiles` lands in Phase 3 and `get_shapes` in Phase 4 —
which is how a seller ends up approving a tool eleven minutes in, having long since
switched windows.

You cannot reduce the number of approvals. You can decide **when** they arrive. So do all
the read-only orientation now, in one burst, while the seller is still watching:

| Call | What it tells you |
|---|---|
| `get_agent_permissions` | above |
| `get_open_project` | above |
| `list_sections` | whether the project already has structure you must not clobber |
| `list_pages` | the same, at page level; also the baseline count Phase 4 reconciles against |
| `get_theme` | the theme's default beacon shape, which the fallback loop needs |
| `list_capture_profiles` | whether a profile for this environment already exists (Phase 3) |
| `get_capturer_state` | whether the capturer is already open and where it is pointed |

That is about seven prompts in the first thirty seconds, then a long quiet stretch instead
of the reverse.

**Every call here has to earn its place.** Do not call a tool purely to get it approved —
you are ordering real work, not manufacturing it. Each row above returns something the
build genuinely uses, and if a project is not open yet, skip the project-shaped calls
rather than firing them at nothing.

Tell the seller what is about to happen, so the burst reads as progress:

```text
Checking the project and capture setup - about seven approval prompts in the next few
moments. I'm getting them out of the way now so the build itself runs quietly.
```

Phase 3 brings a second, smaller cluster when the capturer opens
(`open_html_capturer`, `navigate_capturer`, `wait_for_capturer`). Say the same thing
again, briefly. Phase 4's writes — `add_section`, `set_selection`, `set_text`,
`click_element`, the recording tools — cannot be front-loaded, because inventing writes
to pre-approve them would put junk in the seller's project. Those few will still arrive
mid-build, and Phase 0 has already warned that some will.

## Phase 2 — Project and theme

Regale cannot cleanly re-theme a finished project, so branding must be in place
*before* any page exists.

There is no MCP tool that loads a `.rglt` theme file. The corporate theme therefore
ships as a **template `.rglx` project** that already carries it.

- Template available → `open_project` on the template, then save to a new path so the
  template itself is never modified.
- No template → `new_project` and continue with the default theme. Tell the seller the
  demo is unbranded and that re-theming later is not clean, so branding should be
  sorted before the next build.

Then set project properties with `update_properties --target project`:

- `title` — the real demo title. No dates, version numbers, or initials; a screen
  reader reads this first. **Leaving it as `New Project` is an export warning the seller
  hits later**, so this is not cosmetic — set it before you capture anything and confirm
  the write with the `get_open_project` you make in Phase 5.
- `language` — the language of the demo text.
- `allowPresenterView = true` — **required.** Without it the presenter notes this
  pipeline writes are unreachable in the player.

### The default section is a trap

`new_project` creates a project that already has one empty section, usually **"Section
One"**. Phase 4 then calls `add_section` per scene and captures into those, and the default
is left behind with zero pages.

Regale's Export Validation treats an empty section as an **Error**, not a warning:
*"This Section has no visible Pages. Please add a Page or unselect this Section."* So a
build that looks finished stops the seller at the export dialog with a defect they did not
cause and cannot interpret.

**Reuse it for scene 1.** Do not add a section for scene 1 and leave the default sitting
next to it:

1. `update_properties --target section 1` to set `Title` to scene 1's name.
2. `set_selection` to section 1.
3. Capture scene 1 into it. Scene 2 onward proceed normally with `add_section`.

Only reuse a section that is **empty and default-named**. The opening sweep's
`list_sections` already tells you both — a section with pages is the seller's or the
template's, and repurposing it renames their work. If the project came from a branded
template that ships real sections, leave every one of them alone and add your own.

**Removal is the fallback, not the default.** `remove_section` is destructive, and the
index it takes has *moved*: every `add_section` renumbers the sections after it. An agent
that removes "section 1" from a stale mental map deletes a scene it already captured. So
reach for it only when reuse was not possible — a stray empty section found at Phase 5 —
and re-read `list_sections` immediately before, so the number you pass came from the
current state rather than from memory.

Never remove the default *before* the real sections exist. It is the only section in the
project at that point, and a project needs one.

## Phase 3 — Capture profile and sign-in

A capture profile is an isolated, persistent browser identity. Its cookies persist across
builds, so a seller who signed in last week may still be signed in — but may not. A
session can expire, MFA can reset, or the seller can be on a different machine.

**Always ask. Never skip sign-in confirmation because a profile already exists.** The cost
of asking is one extra message. The cost of silently capturing a sign-in page as a slide
is a broken demo the seller discovers during a customer meeting.

Once signed in, the profile's session covers every Microsoft 365 product — SharePoint,
Outlook, Teams, Defender, Purview — for the life of that session. One prompt at the start
is enough; do not ask again per scene.

1. You already called `list_capture_profiles` in the opening sweep — use that result
   rather than calling it again.
2. A profile for this demo environment exists → `switch_capture_profile` to it.
   It does not exist → `create_capture_profile`, then `switch_capture_profile` to it.
3. **Always — whether the profile is new or existing:**
   - `open_html_capturer`.
   - `navigate_capturer` to the product's sign-in or canonical entry page. For Microsoft
     365 products use `https://www.office.com` so the profile's full session is exercised
     before any capture. For other vendors, use their canonical sign-in page.
   - **Stop and hand over to the seller:**

     ```text
     I've opened the HTML Capturer and navigated to <product>. Please sign in if you
     see a login screen — including any MFA step. If you're already signed in you'll land
     straight on the product. Either way, tell me when you're ready and I'll start the
     build. I'll use this session for every scene, so this is a one-time step per build.
     ```

   - Wait. Do not attempt to type credentials or read stored passwords.
4. After the seller confirms, verify with `get_capturer_state` that the page is the
   signed-in product and not still a sign-in form. If it is still a sign-in form, say
   so and wait again rather than capturing it.

### Detecting that a sign-in is needed

Check for all of these, at Phase 3 and again before every capture:

- The current URL is an identity provider — `login.microsoftonline.com`,
  `accounts.google.com`, `login.live.com`, or any host that is not the product.
- The page shows a sign-in, consent, MFA, or "pick an account" prompt.
- Content that should be personalised is missing or shows a signed-out state.

Any of these on a scene that expected signed-in content means the profile has no
session, or its session expired. Do not capture. Pause.

### Pausing and resuming without losing the plan

A pause must not cost the seller their work. When you pause for sign-in:

1. **Keep the approved scene plan in full.** Do not re-derive it, re-ask for the brief,
   or re-print the whole preview.
2. **Say exactly where you stopped** — which scene, which page within it, what is
   already built, and what remains. For example:

   ```text
   Paused at scene 2 of 4 ("Search the intranet"), page 3.

   Built so far: section 1 complete (4 pages), section 2 pages 1-2.
   Waiting on: sign-in to <product> in capture profile "<name>".

   Sign in in the Capturer window, including any MFA prompt, then tell me you're done
   and I'll pick up at scene 2 page 3. Nothing already built is lost.
   ```

3. **Wait.** Do not type credentials, do not call `read_capture_credentials`, and do
   not skip ahead to a scene that does not need auth.
4. **On resume**, verify the session with `get_capturer_state`, then continue at the
   exact scene and page you named. Never rebuild a section that already exists, and
   never start the project over.

If the seller cannot sign in, offer to skip the affected scenes and build the rest,
listing what was skipped in the final summary. Do not abandon the whole build.

## Phase 3.5 — Discover the tenant entry URL

Run this **only after the profile is signed in**, and only when a scene needs a
tenant-specific surface the seller has not given you a URL for. It replaces asking.

The method is to navigate to the vendor's canonical entry point and read where the
browser actually ends up. The tenant's own routing does the work.

1. `navigate_capturer` to the canonical entry for the surface.
2. `wait_for_capturer`.
3. `get_capturer_state` and read the **final** URL — after all redirects.
4. If it is still an identity provider or an error page, do not retry blindly. Pause
   for sign-in using the flow above.

For Microsoft 365:

| Surface | Navigate to | Lands on |
|---|---|---|
| SharePoint | `https://www.office.com/launch/sharepoint` | `https://TENANT.sharepoint.com/...` |
| OneDrive | `https://www.office.com/launch/onedrive` | `https://TENANT-my.sharepoint.com/...` |
| Outlook web | `https://outlook.office.com/mail/` | the signed-in mailbox |
| Teams web | `https://teams.microsoft.com` | not tenant-hosted; the URL is the same for everyone |
| Admin centre | `https://admin.microsoft.com` | shows the org name and default domain |

For anything else, use the vendor's canonical sign-in or app entry and read the landing
URL the same way. If the product has no such entry, ask the seller.

### Discovery is not guessing

Following a redirect and reading the result is a **fact** — the browser went there.
Assembling a hostname yourself is a **guess**, and the ban on it is unchanged:

- Allowed: navigate to `https://www.office.com/launch/sharepoint`, land on
  `https://acme.sharepoint.com/sites/intranet`, use that.
- Not allowed: see the signed-in user is `someone@acme.onmicrosoft.com` and type
  `https://acme.sharepoint.com` directly. It is usually right, which is exactly what
  makes it dangerous — when it is wrong you capture an error page.

If redirect discovery does not produce a working URL, ask the seller. Never fall back
to assembling one.

### Confirm once, then reuse

State what you found and let the seller correct it before any capture:

```text
Signed in as <account>. Discovered your SharePoint at:
  https://acme.sharepoint.com

I'll use that as the entry point for scenes 2 and 3. Say "no" if that's the wrong site
and give me the right one.
```

One confirmation covers the whole build. Reuse the discovered host for every scene on
that surface rather than re-discovering per scene, and record it so a resume after a
sign-in pause does not repeat the question.

## Phase 4 — Capture loop

### Mapping

| Demo definition | Regale |
|---|---|
| Scene | **Section** (drives the Table of Contents) |
| Beat | **Page** (one screen, one click) |
| Narration | **Presenter notes** on the section's pages |
| — | **Page description** = accessibility text, generated separately |

A scene is not one page. Each beat is a state the viewer clicks through, so a
three-beat scene produces roughly four pages: the opening state plus one per click.
Regale's own guidance is that more short pages beat a few long ones.

Treat that as an estimate, not a contract. Build recording also creates a page on every
full navigation, so the real count is usually higher. Read the pages back and work with
what exists.

### Navigation

Navigate to **one real entry URL** per scene, then reach every later state by clicking
inside the live app — exactly as a person would. Do not deep-link to each screen and
never invent a hostname.

Rules carried over and still binding:

- Infer a URL only when it is a real, publicly reachable vendor-owned page (for
  example on `www.microsoft.com` or `learn.microsoft.com`).
- Never invent a tenant hostname: no `contoso.*`, `fabrikam.*`, `adventureworks.*`,
  `*.example`, `*.onmicrosoft.com`, or any `*.sharepoint.com` / `*.crm.dynamics.com`
  host the seller has not supplied.
- A scene marked `(needs your tenant URL)` → try [Phase 3.5](#phase-35--discover-the-tenant-entry-url)
  first. Only ask the seller if redirect discovery fails.
- The destination state must already exist and work. A broken flow, unresolved connector,
  missing table, empty report, or invalid app is an environment blocker, not an invitation
  to build or debug that resource. Name the blocked beat and move to the next independent
  scene. Do not spend Regale build time repairing the product being captured.

### Record the scene, then write the talk track

**Use build recording.** Do not capture pages one at a time.

While the capturer is recording, every click you make creates the next page *and* drops a
themed beacon on the element you clicked, already named after it and already wired to
advance. When it works it is far faster than placing hotspots by hand.

This was verified against a running Studio on a content site: two agent clicks produced four
pages, each with a correctly anchored, correctly named beacon whose click action pointed at
the next page. The agent never called `instantiate_theme_shape` or `anchor_shape`.

**It does not always work, and it fails silently.** On a single-page app the clicks can
register as neither pages nor beacons while every tool call still returns success — see
[Where recording is known to fail](#where-recording-is-known-to-fail). So recording is a
shortcut, not a guarantee: it does not remove the obligation to check that the beacons
exist, which is why [the audit](#beacon-audit-and-repair--every-scene-before-you-move-on)
is not optional.

#### Per scene

1. Get a section for the scene. Section names are announced by screen readers on every page
   load, so make them meaningful either way.
   - **Scene 1, on a project with one empty default section** — rename that one instead of
     adding to it, per [The default section is a trap](#the-default-section-is-a-trap).
   - **Every other scene** — `add_section` named after the scene.
2. **`set_selection` to that section.** Not optional. Captured pages land in whichever
   section is *currently selected*, and `add_section` does **not** select the section it
   creates — nor does renaming one. Skip this and you get correctly-named empty sections
   with every page piled into the wrong one. Use the section number `add_section` returned;
   do not assume it is the last section.
3. Navigate to the scene's entry URL, or carry on from where the previous scene ended if
   it is the same app.
4. `wait_for_capturer` once for at most 60 seconds, then **verify the page actually loaded** with
   `get_capturer_state`. A settled page is not a loaded page. Treat all of these as
   failures and do **not** record:
   - Browser errors — "can't reach this page", `ERR_NAME_NOT_RESOLVED`,
     `ERR_CONNECTION_REFUSED`, any DNS or connection error text.
   - HTTP 4xx or 5xx.
   - A redirect to sign-in when signed-in content was expected. The profile's session
     expired — pause using [Pausing and resuming](#pausing-and-resuming-without-losing-the-plan)
     and never capture the sign-in page as a slide.
   - No observable change after the wait. Do one diagnostic state read, then pause or
     skip the scene; never respond with another multi-minute wait.
5. Capture size — **usually nothing to do.** The capturer already defaults to fixed
   1920x1080, and the emulation is live and persists across navigations, so calling
   `set_capture_size_mode` every scene sets it to what it already was. Call it only to
   choose a *different* resolution, or to switch a scene to Responsive — and then once,
   not per scene. Keep Fixed unless you have a reason: a fixed page can be upgraded to
   Responsive afterward, but the reverse needs a recapture.
6. **Clear non-story UI before recording.** Query visible `[role='dialog']`,
   `[aria-modal='true']`, onboarding tours, coach marks, consent banners, and first-run
   notices. If the approved beat does not explicitly demonstrate that UI, dismiss it once
   with its normal **Got it**, **Skip**, **Not now**, or **Close** control and verify it is
   gone. "Welcome to the new Calendar" is setup friction, not selling content. If it
   cannot be dismissed within bounded recovery, do not record through it: skip the scene
   and report the blocker. Never capture a dialog merely because it appeared.
7. **Stage the persona now, before recording starts** — `set_element_text` for a display
   name, `set_element_image` for a logo or avatar. Cosmetic edits only. Never operate a
   destructive control (delete, send, purchase, permission change) on a live site.
8. `pause_page_motion` to freeze carousels and CSS animation. This one **is** per
   navigation — a page load resets its own animations — but skip it when the scene
   carries on from where the previous scene ended without a full navigation, and skip it
   on surfaces with nothing moving.
9. `start_build_recording`. It returns `followClicks: true` — that is the mode that chains
   pages.
10. **Walk the scene's beats, one click each:**
   - Find the target with a **narrow** `list_elements` query — pass `query` and
     `kind: 'clickable'`, and keep `maxResults` small. A broad listing returns hundreds of
     elements that stay in context and slow down every later step.
   - `click_element`, then `wait_for_capturer` once for at most 60 seconds.
   - Reveal anything the next beat needs — expand a menu, scroll a list. On-demand content
     is only captured if it is already on the page.
   - Do **not** call `get_recording_state` between every click. It is a health check, not a
     step, and at two calls per beat it is one of the largest avoidable costs in the build.
11. `get_recording_state` **once**, after the last beat and before stopping. Confirm
    `pendingChainPageCount` has grown by roughly one per click. If it is zero or barely
    moved, the clicks did not register — stop and say so rather than recording nothing.
    Check it earlier only if you have specific reason to suspect a surface, in which case
    check after the *first* click and then leave it alone.
12. `stop_build_recording`. Every page in the chain is imported automatically. There is no
    separate capture step.

#### After each scene — reconcile, do not assume

`list_pages` and see what was actually produced.

**The page count will not match the storyboard.** A full page navigation starts a new page
too, not just a click, so a three-beat scene can produce five pages. This is expected. Map
the narration onto the pages that exist rather than the pages you planned, and say so in
the summary if the shape changed materially.

#### Visual refinement — every scene, before notes and beacons

Captured pages are raw material, not the final sequence. A successful capture can still
contain a modal, a blank transition, or two pages showing the same useful state. Do not
hand that sequence to the seller as "done" and make them discover the cleanup themselves.

Save the project, then run this skill's read-only
`scripts\inspect-rglx.ps1 -ProjectPath "PATH"` against the saved `.rglx` path returned by
`get_open_project`. Read its `report.json` and inspect the extracted thumbnails in order
with Copilot's local image viewer. Treat the thumbnail as the page's starting frame, not
the whole page: also inspect `hasBuildTimeline`, HTML/baseline fingerprints, narration,
and navigation edges. Do not use `capture_view` or `render_page` for this bulk pass:
image-returning Regale MCP calls can stall the client. For each page, write an internal
verdict:

- **Keep** — it shows a distinct, stable state required by an approved beat, or it is the
  necessary before/after state for a click.
- **Remove** — it is clearly one of the artifacts below.
- **Review** — its value is ambiguous. Keep it and name it in the final summary; do not
  guess on a destructive edit.

A page earns **Remove** when the extracted-thumbnail evidence shows any of these:

- A first-run, onboarding, product-tour, consent, or "what's new" dialog that is not an
  approved beat.
- A blank, loading, skeleton, partially rendered, or post-submit/pre-result state. For a
  prompt workflow, keep the ready prompt and the completed response; remove the empty or
  waiting page between them.
- A package-equivalent adjacent duplicate with no distinct HTML end state, build timeline,
  interaction, navigation role, or narration. Matching thumbnails alone are not duplicate
  evidence because two pages can start alike and play different builds.
- A sign-in page, browser error, accidental navigation, or content unrelated to the
  scene's narration and beats.
- A page for which you cannot state a one-line audience-facing purpose tied to the
  approved scene.

Do **not** remove a page merely because it looks similar if it carries the only control
needed for the next click, shows a meaningful before/after change, or has unique approved
narration. When uncertain, use **Review**.

The inspector's `thumbnailMatchesPrevious` flag is only a comparison lead. Even
`packageEquivalentToPrevious` still requires a flow-role check before removal. Preserve
section entry and outcome pages, build-timeline pages, navigation sources and targets, and
unique narration unless the page is a confirmed artifact and its flow role is repaired.
Text signals only identify pages to review; confirm setup, error, or blocked states in the
thumbnail before removing them.

Before deleting, identify the scene's retained entry, action/transition, and outcome. Call
`get_shapes` on each candidate, its predecessor and successor, and any page targeting it.
If the retained path is not clear, keep the candidate as **Review**. During automatic
cleanup, remove at most `max(1, floor(original pages * 0.25))` pages, never two consecutive
pages, and never collapse a multi-page scene below two pages.

If an inbound shape has `LockActions: true` or is theme-controlled, do not delete first.
Set `LockActions` to false on that shape instance, re-read it, retarget it to the retained
successor by page id, and re-read it again. Only delete after every inbound target is
verified. One failed unlock or retarget changes the candidate to **Review**; continue the
audit without retrying or rolling back unrelated work.

Collect all clear removals first. Re-read `list_pages` once so every target comes from the
current structure, then call `remove_page` from the highest page number to the lowest so
renumbering cannot change a later target. Re-read `list_pages` once after the batch and
verify the kept sequence is contiguous. Do not repeatedly render or reconsider a removed
page. Record a short removal log, for example:

```text
Scene 2 refinement: removed page 3 (empty state between submitted prompt and completed
response) and page 6 (exact duplicate of page 5). Kept page 8 for review (minor state
change; purpose unclear).
```

This visual pass is required work on the current scene and takes priority over starting
another scene. It remains subject to the 30-minute build timebox. If the timebox prevents
the pass, save and say plainly that the last scene is captured but **not refined**.

Then, in **one pass over the scene's pages**:

- `get_shapes` on each page. Rename any beacon that came out generically as "Hotspot" —
  give it the name of the element it sits on. Recording names most beacons from the link
  text automatically, but not all. Do not include the word "button"; the screen reader adds
  it, so "Save button" is announced "Save button button".
- `set_text --target page_notes` ← the beat's narration. This is the seller's script.

**Keep a running tally as you go**, from what these calls actually returned — not from
what you intended:

```text
Section 2 "Search the intranet": 5 pages; beacons present on 1,2,3,5; page 4 none.
```

Phase 5 reports from this tally, so it does not have to read every page a second time.
Record it as you read, and record the truth: a page with an empty `objects` array goes in
as "none", not as an assumption that recording handled it.

**A tally entry you did not read is a fabrication.** Recording is *supposed* to place a
beacon on every click, and that expectation is strong enough to write itself into the
tally as though it were an observation. It has already happened in the field: a build
reported "2 pages, with a beacon on page 1" to a seller whose page 1 had no shapes on it
at all. Every number in that line comes from a `get_shapes` result in this session or it
does not go in the line.

Write all of a scene's notes together like this. Interleaving them into every page doubles
the number of round trips for no benefit.

Do not visually capture a kept page again during the beacon audit. The refinement
screenshot already established its visual state; `get_shapes` supplies the object evidence.

#### Beacon audit and repair — every scene, before you move on

The `get_shapes` pass above is also the audit. Do not schedule a second sweep; decide the
verdict as each result comes back.

**A page passes only if its `objects` array contains a shape that advances the viewer** — a
beacon or button with a click action pointing at the next page. Anything less is a fail:

| What came back | Verdict |
|---|---|
| Empty `objects` array | **Fail.** No beacon. |
| Only layer shapes | **Fail.** Layers are baked into the exported image — unclickable, untabbable, never announced. |
| An object with no click action, or one that does not advance | **Fail.** A dead beacon looks right in the editor and traps the viewer at runtime. |
| An advancing object | Pass. Rename it if it came out as "Hotspot". |

Exactly one page in the whole project is exempt: the **final page of the final scene**,
which has nowhere to advance to. A scene's own last page is *not* exempt — it advances into
the next scene's first page, and a viewer stranded at the end of section 1 has the same
broken demo as one stranded on page 2. Since you audit per scene, treat every page as
needing a beacon and revisit only the true last page once the build is complete.

**Attempt one repair for each failing page now**, in the same pass, while you still know
what the scene was clicking:

1. Find the element the beat clicked. `query_dom` and `list_elements` both work against the
   captured page in the editor, not just the live capturer — so a page captured minutes ago
   is still queryable. Use the beat's target as the query.
2. `instantiate_theme_shape` with the theme's default beacon — you read the theme in the
   opening sweep, so use that shape id rather than calling `get_theme` again.
3. `anchor_shape` with `anchorSizing='match'` so it tracks the element rather than sitting
   at fixed coordinates.
4. Name it after the element it sits on. **Not** the word "button" — the screen reader adds
   the role, so "Save button" is announced "Save button button".
5. Set its click action to the next page.
6. `get_shapes` on that page again and confirm the object is there. This is the one re-read
   worth its round trip: a repair you did not verify is the same claim that caused the
   repair.

Then update the tally from the re-read, and count the repair in the totals so the summary
distinguishes beacons recording placed from beacons you had to add.

This six-step sequence is **one repair attempt**, not a recipe to restart when any step
fails. If the element cannot be found, the selector is rejected, the anchor is rejected,
the action cannot be set, or verification still fails, stop repairing that page. Leave it,
name it in the final summary as needing a hotspot placed by hand, and keep going. Do not
try a broader selector, alternate anchor, fixed coordinates, shape replacement, or a
second verification. Never abort the build over one element and never let one element
consume the build.

#### Scene checkpoint — before moving on

After reconciliation and the bounded repair pass, save the project before reporting the
scene complete. If Save permission is unavailable and the seller chose manual checkpoint
mode, pause here for Ctrl+S and wait for confirmation. The progress line must say
`checkpoint saved` (or `waiting for Ctrl+S`); a page count alone is not a checkpoint.

Before starting the next scene, check the active-build clock. At 25 minutes, go to Phase 5
with the saved scenes that exist. Do not start another scene merely because its first URL
is already open.

#### The first scene is a canary — check it before building the rest

Run the audit on scene 1 and read the result **before starting scene 2**.

If scene 1 produced **no beacons at all**, recording is not placing them on this surface.
That is a property of the surface, not of that one scene, so building three more scenes the
same way produces three more scenes to repair. Stop and say so:

```text
Scene 1 recorded 4 pages but Regale placed no beacons on any of them - I've read the
shapes back and they're empty. Recording isn't dropping hotspots on this surface, so I'm
switching to placing them myself while the original 30-minute timebox remains. I may save
fewer scenes as a result rather than run past the limit.
```

Then use the [fallback loop](#fallback--the-explicit-capture-loop) for the remaining
scenes, and repair scene 1's pages before moving on, subject to the same bounded-recovery
rule and the original 30-minute timebox.

The same reasoning applies to pages: if `list_sections` shows sections with 0 or 1 pages
where the plan had several beats, the clicks are not chaining either. Do not keep going and
discover it at the end — that is the failure this canary exists to catch.

#### Page descriptions — offer them, don't assume them

`set_text --target page_description` is the accessibility text: what the screen shows, what
changed since the previous page, what to do next. No colour, no pixel positions, and do not
repeat text that shapes on the page will already announce.

It is also **one extra round trip per page** — on a 20-page draft, a fifth of the whole
build. And the output of this pipeline is a draft the seller is about to trim, so some of
those pages will not survive to be presented.

So do not write them inline during the capture loop. Instead, at the end of Phase 5, offer:

```text
I haven't written the page descriptions yet — that's the screen reader text, one pass over
all 18 pages, a few more minutes. Worth doing once you've trimmed the draft, so we're not
describing pages you're about to delete. Say "write descriptions" whenever you're ready.
```

Two exceptions that get written inline, because they are not disposable:

- **Page 1 of the demo**, per [First page of the demo](#first-page-of-the-demo).
- Any page the seller has already said is going in the final cut.

If the seller asks for a fully accessible deliverable up front, write descriptions inline
and tell them it roughly doubles the per-page cost.

#### Fallback — the explicit capture loop

If recording is unusable for a scene — it produced no pages, or the surface fights it —
fall back to capturing pages individually: `capture_html_page`, then `list_elements` /
`query_dom` to find the target, `instantiate_theme_shape` with the theme's default beacon,
`anchor_shape` with `anchorSizing='match'`, name it, set its click action to the next page,
and `get_shapes` to confirm it exists. Then `click_element` to advance and repeat.

This is slower and the beacon step is easy to drop, which is exactly why it is the
fallback. **A page with no beacon is an unfinished page** — the viewer cannot advance, and
what you have built is a screenshot with notes attached. If a target genuinely cannot be
found, warn, keep going, and list that page in the final summary as needing a hotspot
placed by hand. Never abort the whole build over one element, and never continue silently
as though the page were complete. The fallback does not reset the clock or recovery
budget. One failed anchor ends work on that page.

#### Where recording is known to fail

Recording was verified on a content site (Microsoft Learn): two agent clicks produced four
pages, each with a correctly anchored and correctly named beacon.

**It has been seen to fail on Microsoft 365 Copilot chat.** A four-scene build there
finished with 4 sections, 2 pages, and no beacons on either — the clicks neither chained
pages nor dropped hotspots. This is the heavy single-page app case: a click changes the
view without a full navigation, and recording appears to have nothing to hook. Assume the
same of Outlook web, Teams web, and anything else that renders a whole app in one document.

On those surfaces, expect to place beacons yourself. The canary check above is what keeps
that from costing a whole build, and `pendingChainPageCount` staying flat after the first
click is the earliest signal of it.

Also note: beacons created by recording are theme-based with `LockActions: true`, so their
click actions are owned by the theme and the edit tools will refuse changes to them on the
instance. The auto-wired navigation is already correct, so leave it alone unless you have a
specific reason, in which case set `LockActions` to false on that instance first.

### First page of the demo

Give page 1 a description that sets expectations for screen reader users: this is a
simulated environment made of captured screens, each page is described, and some
elements can be clicked.

## Phase 5 — Finish

### Self-check first — before you claim anything

Do not describe the build from memory of the calls you made. Report what tool results
actually showed. A tool call that returned without an error is not evidence that the thing
exists.

1. `list_sections` — every section's page count. One call. This is the authoritative
   check, and it is the one that catches the `set_selection` failure below.
2. **Beacons: report the Phase 4 audit**, not a fresh sweep. Every page was read with
   `get_shapes` during the reconcile pass, every failing page was repaired and re-read
   there, and nothing since has touched shapes — `set_text` writes notes, not objects. A
   second full pass over a 20-page draft is 20 round trips to learn what you already hold.

   The saving depends on the audit having actually run. Re-read now where it did not:
   pages you renamed a beacon on and did not read back, pages the fallback loop built, any
   page whose `list_sections` count disagrees with what you recorded, and **any scene whose
   audit you cannot point to a `get_shapes` result for**. Uncertainty about whether you
   read a page is itself the answer — read it.

If Phase 4's reconcile pass was skipped or interrupted for a scene, there is no audit for
it — read that scene's pages now. Do not report on a scene you never read.

**Do not state a beacon count you cannot trace to a tool result.** "With a beacon on page
1" is a claim about the project, and the seller checks it by opening the Shapes tab. If
the audit says a page has none and could not be repaired, the summary says that page has
none.

Then check for each of these, and state the result plainly:

| Symptom | What it means |
|---|---|
| A section with **0 pages** | Captures went to the wrong section. Almost always a missed `set_selection` after `add_section` (Phase 4, per scene, step 2). |
| Pages piled into a section you did not name — often the default "Section One" | Same cause, seen from the other side. |
| A page with an **empty `objects` array** | No beacon. The viewer cannot advance past it. Phase 4 should already have repaired this — if one reaches here, repair it now. |
| Beacons on no page in the project | Recording placed none and the canary check did not fire. Every page needs one placed by hand; say so before the seller finds out. |
| Fewer pages than the approved plan had beats | The build stopped early. Say which scene it reached. |

If any of these are true, **say so in the summary as a defect, not as a completed build.**
Fix only what fits within the remaining timebox and bounded-recovery budget. Otherwise
save and report the defect rather than leaving the seller to discover it. Phase 5 never
extends the clock and never restarts a repair that already failed in Phase 4.

### Export readiness — clear Regale's own validator before you hand over

Regale runs an Export Validation pass when the seller clicks Export, and it blocks on
things this pipeline is supposed to have prevented. The seller meets them minutes after
you said the build was finished, in a dialog that does not explain which of them matter.

You already hold everything needed to pre-empt it. No extra calls:

| Regale reports | Read it from | Fix before handing over |
|---|---|---|
| Error — *"This Section has no visible Pages"* | `list_sections`, any section with `pageCount` 0 | `remove_section`, or move pages into it if captures went astray. Usually the leftover default section — see [The default section is a trap](#the-default-section-is-a-trap). |
| The same Error on a section that *has* pages | Sections and pages both carry `IsHidden`. "Visible" means not hidden, so a section whose every page is hidden reads as empty to the validator while `list_sections` still reports a page count. | Unhide the pages, or hide the whole section — Regale's own suggested fix, *"unselect this Section"*, is `IsHidden = true` on the section. Nothing in this pipeline sets `IsHidden`, so if you meet this, someone hid them by hand: ask before changing it. |
| Warning — *"The Project Title is still the default value: 'New Project'"* | `get_open_project`, `title` | `update_properties --target project`. Phase 2 should have set it; if it is still the default, the write never landed. |

Fix both silently — they are your defects, not the seller's decisions, and neither needs
asking. Then say the project is export-clean, so the seller knows the dialog should come up
empty:

```text
Checked it against Regale's export validation - no errors or warnings, so Export won't
stop you.
```

If something genuinely cannot be fixed, name it and say what the seller will see in the
dialog, rather than letting them discover it after the build.

If the seller says a beacon you reported is not there, do not re-argue from the tally. One
`render_page` on that page with the objects overlay settles it in a single call, and a
disagreement about whether the demo works is worth that round trip.

### Then

1. Save the final checkpoint. If manual checkpoint mode is active, tell the seller to
   press Ctrl+S in Regale and do not call the build durable until they confirm.
2. Summarise honestly, from the self-check above rather than from memory:
   - Sections and pages created — the counts you just read back, and any empty section.
   - Refinement — pages removed with reasons, every page retained for review, and any
     scene that was captured but not visually refined before the timebox.
   - Hotspots: how many recording placed, how many you had to add in the repair pass, and
     **every** page still without one, named, with the reason.
   - Any scene skipped because it needed a desktop app or a URL that was never supplied.
3. State that this is a working draft the seller should review in Regale before
   presenting.
4. Offer the page-description pass, per
   [Page descriptions](#page-descriptions--offer-them-dont-assume-them). Say plainly that
   it has not been done yet — do not let it read as finished accessibility work.

Do not publish. Do not offer to publish.

### Refining an already-built draft

If the user asks to refine a project that is already open, do not recapture it and do not
make them rebuild from the original brief. Treat this as a fresh, 30-minute refinement
task:

#### Choose the refinement mode

For a bare `refine the open draft`, ask once before tools:

- **Conservative cleanup (Recommended)** — remove only when the retained flow can be
  verified. Keep uncertain or structurally protected pages as **Review**.
- **Aggressive cleanup in a copy** — remove visually confirmed setup, error, blocked, and
  redundant pages after one navigation-repair attempt, even if repair fails. Never modify
  the source project; the resulting copy may be broken and is not presentation-ready.

Accept `refine the open draft conservatively` and `refine the open draft aggressively` as
direct selections. The immediate replies `conservative` and `aggressive` also select the
mode. Do not ask another prioritization question after the choice.

**Refinement has a narrow write surface.** Allowed writes are `remove_page`, a property or
shape write strictly needed to repair navigation on a retained page, and `save_project`.
Never call `set_text`, capture/recording tools, or product-interaction tools. Missing page
descriptions and presenter notes are not refinement defects. Never hide a page by setting
`IsHidden`; give it a rendered **Remove** verdict and delete it, or retain it as **Review**
when the evidence is ambiguous.
Do not count, mention, or remediate description/note completeness in refinement progress
or its final summary.

#### Mandatory conservative gates

These are completion criteria, not suggestions:

If the user selected aggressive mode, skip these gates and the conservative execution
list below; continue at **Aggressive cleanup in a copy**.

1. Confirm `remove_page`, `get_shapes`, and `save_project` are visible. Read the saved
   `.rglx` path from `get_open_project`, save once, then run
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH" -CreateBackup`. The inspector is the only
   shell command allowed in refinement mode. Do not remove anything unless `backupPath`
   exists in `report.json`; include that path in the final summary.
2. Read its `report.json`. For every visible page in section/page order, inspect the
   extracted thumbnail as its **starting frame**, then read its build-timeline flag,
   baseline/current HTML fingerprints, narration, incoming targets, and outgoing actions.
   Assign **Keep**, **Remove**, or **Review**. Review every consecutive
   predecessor/current/successor trio and create a defect ledger before any write. The
   ledger must include every onboarding or first-run dialog, setup/sign-in screen,
   request-to-result intermediate state with no audience-facing value, blocked/error
   state, and adjacent frame with no meaningful visible progression. Record its exact
   section/page ids, evidence, and intended retained predecessor/successor. A matching
   thumbnail is never sufficient removal evidence, but an exact match plus the absence of
   a distinct visible story role is strong duplicate evidence. Do not call `capture_view`
   or `render_page`.
3. Before writes, state an internal flow contract for every section: its entry state, at
   least one retained action/transition, and its audience-facing outcome. If those three
   roles cannot be identified, make no deletions in that section and mark it **Review**.
   Preserve pages carrying `build-timeline`, `inbound-navigation-target`,
   `outbound-navigation`, `section-entry`, `section-outcome`, or unique narration unless
   a confirmed artifact can be removed while another retained page fulfills that role.
   Before approving a candidate, call `get_shapes` on it, its predecessor and successor,
   and every page targeting it.
4. Enforce the automatic-removal budget per section: at most
   `max(1, floor(original pages * 0.25))` pages; never remove two consecutive pages; and
   never reduce a multi-page section below two pages. Present any larger removal plan to
   the user and wait for explicit approval instead of applying it.
5. Process approved **Remove** candidates highest page number first. For every inbound
   shape, retarget it to the retained successor **before** deletion. When `LockActions` is
   true or `isThemeControlled` is true, first set `LockActions` false on that shape
   instance and verify the unlock; then set and verify the new page-id target. One failed
   unlock or retarget changes the candidate to **Review** with no deletion or retry. After
   verified retargeting, remove the candidate, re-list the section, and inspect shapes on
   all retained pages. Never call `update_properties` on a project, section, or page;
   shape navigation writes are the only exception.
6. Save, rerun the inspector without `-CreateBackup`, and compare the result with the
   original report. A section passes only if its page-count floor, entry/action/outcome
   contract, build-timeline pages, and navigation targets remain intact. Otherwise stop,
   identify the backup, and do not call refinement complete.

The agent may say refinement is complete only when the verdict count equals the original
visible-page count and the post-edit flow check passes. Its final summary must state that
count, every removal and reason, every **Review** page, each section's retained
entry/action/outcome flow, navigation verified, and the backup path.

**Review is not a blocked state.** If all pages were inspected, the project remains valid,
and unsafe candidates were retained, finish as `complete with review items`. Use `blocked`
only when backup, inspection, restoration, or project-wide flow verification cannot
complete.

`thumbnailMatchesPrevious` is never removal evidence. `packageEquivalentToPrevious` is
only a candidate and still requires the flow contract and removal budget. Inspector text
signals are review leads, not automatic removal decisions. If the inspector or local
image viewer is unavailable, stop and report that exact precondition. Do not fall back to
Regale image calls, metadata-only editing, page hiding, or text polishing.

Forbidden tools/actions in this mode: `get_page` as a visual substitute, `set_text`,
`capture_view`, `render_page`, capture or recording creation, product interaction,
page/section/project property edits, page hiding, accessibility work, presenter-note work,
and title/section polishing. The package inspector is the only allowed shell command.

1. Check Read, Edit, and Save permissions, then read `list_sections` and `list_pages`.
2. Run the package inspector with `-CreateBackup`. For each section, apply the
   [visual refinement](#visual-refinement--every-scene-before-notes-and-beacons)
   classification to its extracted thumbnails, then remove only **Remove** verdicts from
   highest page number to lowest.
3. Re-read that section once, audit advancing shapes on the pages immediately before each
   removal and on the retained sequence, and use the same bounded-recovery rule for any
   broken navigation. Do not rewrite notes or descriptions; report a now-inaccurate note
   as a follow-up item instead of expanding refinement scope.
4. Save and re-inspect after each refined section. At the timebox, save and report the
   exact next section.
5. Finish with the removal log, retained **Review** pages, per-section flow contracts,
   navigation defects, backup path, and sections not yet processed. Do not call an
   unprocessed or flow-invalid section refined.

The user can ask in plain language, for example `refine the open draft`. This is a
post-build task, not a definition-mode command, and it does not require `confirm build`
again when the current conversation already built or opened the project.

#### Aggressive cleanup in a copy

This mode requires the user's explicit `aggressive` selection. Never infer it from
frustration, urgency, or a request to remove one page.

1. Save the source, then run
   `scripts\inspect-rglx.ps1 -ProjectPath "PATH" -CreateBackup -CreateAggressiveCopy`.
2. Verify `backupPath` and `aggressiveCopyPath` exist. Record `projectPath` as immutable,
   open `aggressiveCopyPath` with Regale, and confirm that exact copy is active before any
   write. Abort if the active path is still the source.
3. Perform the same full visual and package inspection. Aggressive does not permit removal
   based only on matching thumbnails or vague suspicion. Build the defect ledger before
   edits and resolve those candidates before considering unrelated cleanup. A distinct
   timeline, click, or narration is not audience value by itself: it does not protect a
   confirmed onboarding page, a request-to-result intermediate state that communicates
   nothing, or a visually redundant adjacent frame when the retained neighbors still
   provide the action and outcome.
4. Attempt unlock/retarget once for each confirmed removal. If repair fails, the explicit
   selection permits deletion **only in the aggressive copy**. The 25-percent budget,
   consecutive-removal restriction, and two-page floor are waived, but retain at least one
   visible page in every section. If a section has no audience-facing outcome, retain that
   section as **Review** rather than deleting arbitrary pages and leaving a false story.
5. Save and re-inspect the copy. Recheck every original defect-ledger entry and report it
   as removed or retained with a concrete reason. Do not roll back to or overwrite the
   source. Finish with
   `aggressive copy created - repair required`, the source path, copy path, backup path,
   removals, retained Review pages, and every broken/dangling navigation edge. State that
   the exact copy path is the project currently open in Regale and that the copy is not
   presentation-ready. Do not publish it.

---

## Advanced fallback — native screen capture

**This path is not automated.** The seller drives the application by hand while Regale
records the screen. Use it only when one of these is true:

- The surface is not a web page — a desktop application, or anything with no URL.
- HTML capture was attempted for the scene and actually failed.
- The seller explicitly asked for it after being told it is manual.

Never choose it pre-emptively because HTML capture *might* not work, and never drift
into it because a selector was hard to find. Say plainly what it costs before starting:
the seller has to bring the app forward, perform each step themselves, and Regale
Studio has to be hidden while it records.

### What the targets actually are

`list_capture_targets` returns exactly two kinds of target: each **monitor** (index,
name, bounds, DPI) and the single special **Active Window**. Per-application and
per-browser-window targets do not exist. Their absence is not a failure — do not wait
for one.

- Prefer the monitor showing the prepared application. Monitor capture records whatever
  is on that screen, so a single-monitor machine is fully supported.
- Do not default to `Active Window` while the seller is chatting with Copilot on the
  same desktop — Copilot is usually the foreground window, so it records Copilot.

### Sequence, per scene

1. `set_capture_target` with the chosen monitor. Say which one is selected.
2. `set_capture_mode`:
   - `single` — one frame per click. Best for discrete screens; keeps the seller in
     control.
   - `continuous` — records over time. Pass `framesPerSecond` (4–8 suits most UI) and a
     `maxSeconds` auto-stop so recording ends by itself if the seller cannot get back
     to chat.
3. Tell the seller which window to bring forward and exactly what state to prepare.
4. `set_studio_window` with state `minimize`. Monitor capture records the whole screen,
   so Studio will appear in the frames otherwise. Capture does not move it for you.
5. Wait several seconds after the seller confirms, so the window switch completes.
6. `start_capture`.
7. In `single` mode, tell them to click once per screen they want. In `continuous`,
   tell them to drive the flow now.
8. `end_capture`, or let `maxSeconds` stop it.
9. `set_studio_window` with state `restore`. `end_capture` does not restore it.
10. Frames process asynchronously. Wait once for at most 60 seconds, then re-query with `get_page` or
    `get_open_project` before stating what was captured.

If capture returns zero frames or the wrong surface, report what was actually captured
and wait for a new explicit user message before retrying with a different monitor. Do not
silently switch paths, extend the wait, or count the retry against the current build.

### What differs afterwards

Captured screens are **image pages**, not HTML, so:

- Beacons are placed automatically where the seller clicked and sized to the control
  they hit. There is no DOM, so `query_dom`, `anchor_shape`, and CSS selectors do not
  apply — shapes sit at fixed coordinates.
- Still rename every beacon after the element it highlights. The accessibility rule is
  unchanged.
- Presenter notes and page descriptions are written exactly as in Phase 4.

---

## Not yet verified

### Profile persistence across Studio restarts

Regale documents capture profiles as persistent, isolated browser identities that keep
their own cookies and sessions, so a profile signed in once should still be signed in
on a later build. This pipeline depends on that, but it has not been confirmed
end to end on this machine.

One documented caveat already applies: a site that stores its sign-in only for the
session — a session cookie or in-page storage rather than a persistent cookie — will
ask for sign-in again after a profile switch, exactly as a brand-new browser window
would. That is the site's choice, not a lost profile. Handle it with the normal pause
and resume flow rather than reporting it as a failure.

Until this is confirmed, do not promise the seller that they will never sign in again.
Say the profile is designed to persist and that you will pause if it has not.

### Agent-driven build recording

Agent-driven clicks do register: on a content site, recording chained the pages and placed
the beacons exactly as a person's clicks would, which is why Phase 4 is built on it.

What is **not** established is where that stops holding. It has failed outright on
Microsoft 365 Copilot chat — no chained pages, no beacons, no error — and nobody has yet
mapped which surfaces work. The audit and canary in Phase 4 exist because that boundary is
unknown, not because recording is expected to fail.

Worth establishing: whether `pendingChainPageCount` is a reliable early signal on every
surface that fails, or only some. If it is reliable, the canary can move earlier, to after
the first click of scene 1, and cost one call instead of a scene.

Build recording and HTML capture are both officially **Beta** in Regale 5.0. Behaviour
may change between releases.
