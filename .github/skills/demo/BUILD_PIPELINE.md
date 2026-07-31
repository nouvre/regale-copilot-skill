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

## Tool names

The names below are the expected Regale MCP tools. Discover the real list at runtime
and use the closest tool by purpose if a name differs. Never claim the demo was built
unless a Regale capture tool actually succeeded.

---

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
   | Save project files | Saving at the end | Not a blocker. Warn once now, and tell the seller to press Ctrl+S themselves at the end. |
   | Publish | Not used in v1 | Ignore. |

   Ask for any missing permission **up front**, in one message, naming the exact
   location: Regale Studio → Home ribbon → AI & Agents → Permissions. Do not start
   capturing and fail halfway.

   Never call `read_capture_credentials`. It is off by default, and it would put
   plaintext passwords into the chat transcript. The seller signs in themselves.

3. `get_open_project`.
   - A project is open → use it.
   - No project → create one from the branded template (Phase 2).

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
  reader reads this first.
- `language` — the language of the demo text.
- `allowPresenterView = true` — **required.** Without it the presenter notes this
  pipeline writes are unreachable in the player.

## Phase 3 — Capture profile and sign-in

A capture profile is an isolated, persistent browser identity. It is what lets a later
build run unattended: the seller signs in once, and the profile stays signed in.

1. `list_capture_profiles`.
2. A profile for this demo environment exists → `switch_capture_profile` to it.
3. It does not exist → `create_capture_profile`, switch to it, then:
   - `open_html_capturer` and `navigate_capturer` to the product's sign-in page.
   - **Stop and hand over to the seller:**

     ```text
     I've opened <product> in a new capture profile called "<name>". Sign in there once,
     including any MFA prompt, then tell me you're done. I'll reuse this profile for
     every future build, so this is a one-time step.
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

### Record the scene, then write the talk track

**Use build recording.** Do not capture pages one at a time.

While the capturer is recording, every click you make creates the next page *and* drops a
themed beacon on the element you clicked, already named after it and already wired to
advance. Regale does the beacon work — you cannot forget it, and it is far faster than
placing hotspots by hand.

This was verified against a running Studio: two agent clicks produced four pages, each
with a correctly anchored, correctly named beacon whose click action pointed at the next
page. The agent never called `instantiate_theme_shape` or `anchor_shape`.

#### Per scene

1. `add_section` named after the scene. Section names are announced by screen readers on
   every page load, so make them meaningful.
2. **`set_selection` to the section you just created.** Not optional. Captured pages land
   in whichever section is *currently selected*, and `add_section` does **not** select the
   section it creates. Skip this and you get correctly-named empty sections with every
   page piled into the wrong one. Use the section number `add_section` returned; do not
   assume it is the last section.
3. Navigate to the scene's entry URL, or carry on from where the previous scene ended if
   it is the same app.
4. `wait_for_capturer`, then **verify the page actually loaded** with
   `get_capturer_state`. A settled page is not a loaded page. Treat all of these as
   failures and do **not** record:
   - Browser errors — "can't reach this page", `ERR_NAME_NOT_RESOLVED`,
     `ERR_CONNECTION_REFUSED`, any DNS or connection error text.
   - HTTP 4xx or 5xx.
   - A redirect to sign-in when signed-in content was expected. The profile's session
     expired — pause using [Pausing and resuming](#pausing-and-resuming-without-losing-the-plan)
     and never capture the sign-in page as a slide.
5. `set_capture_size_mode` to fixed 1920x1080. Fixed first; a page can be switched to
   Responsive afterward, but the reverse needs a recapture.
6. **Stage the persona now, before recording starts** — `set_element_text` for a display
   name, `set_element_image` for a logo or avatar. Cosmetic edits only. Never operate a
   destructive control (delete, send, purchase, permission change) on a live site.
7. `pause_page_motion` to freeze carousels and CSS animation.
8. `start_build_recording`. It returns `followClicks: true` — that is the mode that chains
   pages.
9. **Walk the scene's beats, one click each:**
   - Find the target with a **narrow** `list_elements` query — pass `query` and
     `kind: 'clickable'`, and keep `maxResults` small. A broad listing returns hundreds of
     elements that stay in context and slow down every later step.
   - `click_element`, then `wait_for_capturer`.
   - Reveal anything the next beat needs — expand a menu, scroll a list. On-demand content
     is only captured if it is already on the page.
   - `get_recording_state` to confirm `pendingChainPageCount` is growing. If it is not, the
     clicks are not registering — stop and say so rather than recording nothing.
10. `stop_build_recording`. Every page in the chain is imported automatically. There is no
    separate capture step.

#### After each scene — reconcile, do not assume

`list_pages` and see what was actually produced.

**The page count will not match the storyboard.** A full page navigation starts a new page
too, not just a click, so a three-beat scene can produce five pages. This is expected. Map
the narration onto the pages that exist rather than the pages you planned, and say so in
the summary if the shape changed materially.

Then, in **one pass over the scene's pages**:

- `get_shapes` on each page. Rename any beacon that came out generically as "Hotspot" —
  give it the name of the element it sits on. Recording names most beacons from the link
  text automatically, but not all. Do not include the word "button"; the screen reader adds
  it, so "Save button" is announced "Save button button".
- `set_text --target page_notes` ← the beat's narration. This is the seller's script.
- `set_text --target page_description` ← what the screen shows, what changed since the
  previous page, and what to do next. No colour, no pixel positions, and do not repeat text
  that shapes on the page will already announce.

Write all of a scene's notes and descriptions together like this. Interleaving them into
every page doubles the number of round trips for no benefit.

Do not call `render_page` on each page. It costs a full round trip and an image every time,
and the Phase 5 self-check already verifies the result.

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
as though the page were complete.

#### Not yet proven

Recording was verified on a content site (Microsoft Learn). It has **not** been confirmed
on a heavy single-page app such as Outlook or Teams web, where a click changes the view
without a full navigation. If `pendingChainPageCount` does not rise on such a surface, use
the fallback loop for that scene and report it.

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

Do not describe the build from memory of the calls you made. Read the project back and
report what is actually there. A tool call that returned without an error is not evidence
that the thing exists.

1. `list_sections` — every section's page count.
2. `get_shapes` on every page — the beacons actually present.

Then check for each of these, and state the result plainly:

| Symptom | What it means |
|---|---|
| A section with **0 pages** | Captures went to the wrong section. Almost always a missed `set_selection` after `add_section` (Phase 4, per scene, step 2). |
| Pages piled into a section you did not name — often the default "Section One" | Same cause, seen from the other side. |
| A page with an **empty `objects` array** | No beacon. The viewer cannot advance past it. |
| Fewer pages than the approved plan had beats | The build stopped early. Say which scene it reached. |

If any of these are true, **say so in the summary as a defect, not as a completed build.**
Offer to fix it — move the misfiled pages, or place the missing beacons — rather than
reporting success and leaving the seller to discover it.

### Then

1. Save. If the Save permission is on, save the project. If it is off, tell the seller
   to press Ctrl+S in Regale.
2. Summarise honestly, from the self-check above rather than from memory:
   - Sections and pages created — the counts you just read back, and any empty section.
   - Hotspots placed, and **every** hotspot skipped with the reason.
   - Accessibility descriptions written and awaiting review.
   - Any scene skipped because it needed a desktop app or a URL that was never supplied.
3. State that this is a working draft the seller should review in Regale before
   presenting.

Do not publish. Do not offer to publish.

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
10. Frames process asynchronously. Wait, then re-query with `get_page` or
    `get_open_project` before stating what was captured.

If capture returns zero frames or the wrong surface, report what was actually captured
and retry with a longer delay or a different monitor. Do not silently switch paths.

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

Regale's HTML Capturer supports **build recording**: while recording, each click
creates a new page *and* automatically drops a themed hotspot on the clicked element,
wired to advance. If agent-driven clicks register the same way a person's do, that
collapses most of Phase 4 into a single pass.

The documentation says the input tools produce "the same kind of input a real user
produces", but this has not been tested against a running Studio. Use the explicit loop
above until someone confirms it. If it works, this pipeline gets substantially shorter.

Build recording and HTML capture are both officially **Beta** in Regale 5.0. Behaviour
may change between releases.
