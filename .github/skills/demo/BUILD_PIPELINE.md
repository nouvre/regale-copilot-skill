# Regale Build Pipeline (canonical)

This is the single source of truth for BUILD mode. `SKILL.md` and
`.github/agents/regale-demo.agent.md` both point here. Edit this file, not a copy.

BUILD mode starts only after the user types exactly `confirm build`.

## Scope of v1

- **Web surfaces only.** Everything is captured through Regale's HTML Capturer, which
  is a real browser the agent drives. Desktop applications (Outlook, Excel, Teams
  desktop) cannot be captured this way. If a scene needs one, say so plainly and skip
  it — do not fall back to screen recording, which cannot be automated.
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
   signed-in product and not still a sign-in form.

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
- A scene marked `(needs your tenant URL)` → ask for the real URL now.

### Per scene

1. `add_section` named after the scene. Section names are announced by screen readers
   on every page load, so make them meaningful.
2. Navigate to the scene's entry URL, or continue clicking from where the previous
   scene ended if it is the same app.
3. `wait_for_capturer`, then **verify the page actually loaded** with
   `get_capturer_state`. A settled page is not a loaded page. Treat all of these as
   failures and do **not** capture:
   - Browser errors — "can't reach this page", `ERR_NAME_NOT_RESOLVED`,
     `ERR_CONNECTION_REFUSED`, any DNS or connection error text.
   - HTTP 4xx or 5xx.
   - A redirect to sign-in when signed-in content was expected. This means the
     profile's session expired — stop and ask the seller to sign in again in that
     profile. Do not capture the sign-in page as a slide.
4. `set_capture_size_mode` to fixed 1920x1080. Capture at fixed size first; a page can
   be switched to Responsive afterward, but the reverse requires a recapture.

### Per page, within a scene

1. **Reveal what the beat needs.** On-demand content is only captured if it is already
   in the page — expand collapsed menus, scroll virtualized lists, open the panel.
   Use `click_element`, `scroll_view`, `hover_element`.
2. **Stage the persona** if one was given — `set_element_text` for a display name,
   `set_element_image` for a logo or avatar. Safe cosmetic edits only. Never operate a
   destructive control (delete, send, purchase, permission change) on a live site.
3. `pause_page_motion` to freeze carousels and CSS animation.
4. `capture_html_page` → returns the new section and page.
5. **Place the click hotspot** for the beat that leads to the next page:
   - Find the target with `list_elements` or `query_dom`. Prefer describing it the way
     a screen reader would ("the Sign in button") over a brittle CSS selector.
   - `instantiate_theme_shape` with the theme's default beacon, then `anchor_shape`
     with `anchorSizing='match'` so it stays aligned as the page reflows.
   - **Name the beacon after the UI element it highlights** — "Save button", "Settings
     tab". This is required: screen readers announce the name. Do not include the word
     "button"; the reader adds it, so "Save button" is announced "Save button button".
   - Set its click action to advance to the next page.
   - Target not found → warn, skip the hotspot, keep going, and list it at the end for
     manual placement. Never abort the build over one missing element.
6. **Write the talk track:**
   - `set_text --target page_notes` ← the beat's narration. This is the seller's script.
   - `set_text --target page_description` ← an accessibility description: what the
     screen shows, what changed since the previous page, and what to do next. Do not
     describe colour or pixel positions. Flag these for seller review in the summary —
     generated descriptions are a starting point, not a finished product.
7. `render_page` to verify the page looks right.
8. **Advance the live page**: `click_element` on the same target the hotspot points at,
   wait, verify, and capture the resulting state as the next page. Repeat from step 1.

### First page of the demo

Give page 1 a description that sets expectations for screen reader users: this is a
simulated environment made of captured screens, each page is described, and some
elements can be clicked.

## Phase 5 — Finish

1. Save. If the Save permission is on, save the project. If it is off, tell the seller
   to press Ctrl+S in Regale.
2. Summarise honestly:
   - Sections and pages created.
   - Hotspots placed, and **every** hotspot skipped with the reason.
   - Accessibility descriptions written and awaiting review.
   - Any scene skipped because it needed a desktop app or a URL that was never supplied.
3. State that this is a working draft the seller should review in Regale before
   presenting.

Do not publish. Do not offer to publish.

---

## Not yet verified

Regale's HTML Capturer supports **build recording**: while recording, each click
creates a new page *and* automatically drops a themed hotspot on the clicked element,
wired to advance. If agent-driven clicks register the same way a person's do, that
collapses most of Phase 4 into a single pass.

The documentation says the input tools produce "the same kind of input a real user
produces", but this has not been tested against a running Studio. Use the explicit loop
above until someone confirms it. If it works, this pipeline gets substantially shorter.

Build recording and HTML capture are both officially **Beta** in Regale 5.0. Behaviour
may change between releases.
