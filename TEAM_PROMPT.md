# Team Working Prompt — Regale Demo Generator

Paste this whole file into Copilot or Claude as your opening message before working on this
repository, or read it yourself as an onboarding brief. It carries the context that is not
recoverable from the code alone: what the project is, what Regale Studio actually does, which
file is authoritative, and what is currently known to be wrong.

> **The source docs are in this repo.** Everything below about Regale Studio is a distillation of
> the ten help articles in [`docs/regale/`](docs/regale/README.md). When a detail matters — an
> exact permission, a flag, a role, a workflow step — read the article, don't trust the summary.
> The index in that folder tells you which one to open.

---

## Your role

You are working on `regale-copilot-skill` — a GitHub Copilot skill/agent package that lets a
**non-developer Microsoft seller** describe a product demo in plain chat and have an AI agent
build it inside **Regale Studio** by driving Regale's HTML Capturer over the real product:
navigating a live browser, clicking through the product, capturing each screen as a slide,
placing click hotspots, and attaching the talk track.

The audience is a seller, not a developer. They will never see YAML, a selector, or a tool name.
Anything that leaks implementation detail into their chat is a bug.

---

## The two-phase contract (the core invariant)

**DEFINITION mode** — runs anywhere, touches nothing.

The seller types `/demo <brief>` or selects the `Regale Demo` agent. The agent returns a compact
storyboard preview: title, audience, and numbered scenes carrying id, type, approximate duration,
inferred URL if useful, a one-line narration, and up to two beats. Then it waits.

Before the seller types exactly `confirm build`, the agent must **not**: answer the brief
directly, call any MCP tool, write a file, rename the session, start a background agent, or
build/save/publish anything.

The acceptance test that guards this: `/demo Pitch SharePoint to an executive…` must return a
storyboard, **not** a SharePoint pitch. If you change definition-mode wording, re-run that test
mentally against every runtime file.

**BUILD mode** — starts only on the exact phrase `confirm build`, and only on the same PC as
Regale Studio (MCP is loopback-only).

Inline edit commands: `edit duration scene N SECONDS`, `rename scene N "New Title"`,
`edit narration scene N: "new text"`, `add beat scene N: action [-> target]`,
`remove beat scene N: beat-number`, `reorder scene FROM TO`, `confirm build`.

Always print that command list **inside a fenced code block**. Chat renders replies as markdown,
so angle-bracket placeholders are parsed as HTML tags and silently deleted — the seller receives
`edit duration scene` with the values missing. Use `N`, `SECONDS`, `FROM`, `TO`.

---

## Repository map and the editing rule

| File | Role |
|---|---|
| `.github/skills/demo/BUILD_PIPELINE.md` | **Canonical build pipeline. The only copy.** |
| `.github/skills/demo/SKILL.md` | Copilot Agent Skill — definition mode; points at the pipeline |
| `.github/agents/regale-demo.agent.md` | Copilot app custom agent — same |
| `.github/prompts/demo.prompt.md` | VS Code `/demo` prompt file — definition mode only |
| `.github/copilot-instructions.md` | Auto-loaded repo instructions — definition mode only |
| `AGENTS.md` | Auto-loaded agent instructions — definition mode only |
| `AGENT_INSTRUCTIONS.md` | A pointer. It went stale once; it is deliberately hollow now |
| `skill.md` | Human-facing overview and the demo→Regale mapping |
| `scripts/install-*.ps1`, `install-regale-demo.cmd` | Install agent + skill into `~/.copilot`, register the MCP bridge |
| `parser.py` | Word `.docx` two-column "What to say / What to show" → demo YAML |
| `build_orchestrator.py`, `agent_controller.py`, `inchat_ui_helpers.py` | Dry-run / reference Python. Not executed by the agent |
| `QUICK_START.txt`, `WINDOWS_COPILOT_APP.md`, `SETUP.md` | Seller-facing docs |
| `docs/regale/` | Regale Studio's own help articles, verbatim. Reference material — never edit to match our assumptions |

**The rule that matters:** to change build behaviour, edit `BUILD_PIPELINE.md` and nothing else.
The definition-mode rules are duplicated across **five** runtime files because Copilot's skill,
agent, and prompt formats each load their own — if you change those rules, change all five. The
build pipeline is deliberately never duplicated, because a duplicated copy is exactly what went
stale before.

---

## Regale Studio: what you need to know to write correct instructions

### Object model

```
Project → Sections → Pages → Images | Object Shapes | Layer Shapes
```

The demo mapping this repo uses:

| Demo definition | Regale |
|---|---|
| Scene | **Section** (drives the Table of Contents; announced by screen readers on every page load) |
| Beat | **Page** (one screen, one click) |
| Narration | **Presenter notes** |
| — | **Page description** = accessibility text, generated separately |

A scene is not one page. A three-beat scene produces roughly four pages: the opening state plus
one per click. Regale's own guidance is that more short pages beat a few long ones.

**Object vs Layer is a capability boundary, not a style choice.** Object shapes stay live in the
export and respond to mouse, keyboard, and assistive tech. Layer shapes are *baked into the page
image* at export — flat pixels, unclickable, untabbable, never announced. Anything a viewer must
click, tab to, or hear announced **must** be an Object. Conversely, masking a username or a
watermark **must** be a Layer, because an Object is drawn at runtime and the viewer could see the
real content underneath. Blur is Layer-only.

### The two capture paths

**HTML Capturer — the default and only automated path.** A real browser the agent drives, so the
whole build runs without the seller clicking anything. Never switch away from it on your own
initiative.

**Native screen capture — advanced fallback only.** Not automated: the seller drives the app by
hand while Regale records. Use it only when the surface genuinely is not a web page (Outlook,
Excel, Teams desktop), when HTML capture was attempted and actually failed, or when the seller
explicitly asked after being told it is manual. Capture targets are **only** each monitor and the
single special *Active Window* — per-application and per-browser-window targets do not exist, and
their absence is not a failure.

### Facts about HTML capture that constrain the pipeline

- **JavaScript is stripped at capture.** A captured page is a picture, not a working app.
  Dropdowns, filters, search boxes, and forms stop functioning. You build interactivity the Regale
  way: capture each state as its own page and link them with beacons.
- **On-demand content is only captured if it is already on the page.** Expand collapsed menus,
  scroll virtualized lists, and open panels *before* capturing.
- **Capture Fixed Size first (1920×1080), then optionally switch to Responsive.** That direction is
  a setting toggle. The reverse requires a full recapture, because some sites' JS-driven layout
  only holds together at the resolution it was captured at, and you cannot tell in advance.
- **Scroll positions are captured automatically** — the page and every scrolled panel — and
  reapplied on load, in the workspace, the export, and the player.
- **Shapes anchor to elements on HTML pages**, not to fixed coordinates, so they stay aligned as
  the page reflows. On image pages there is no DOM, so shapes sit at fixed coordinates.
- `query_dom` reaches into **shadow DOM**, which is what makes beacon placement reliable on
  component-framework apps like Microsoft's.
- `wait_for_capturer` reports honestly on pages that never go idle and **can name** the parts that
  animate continuously (a carousel), so they can be frozen before capture.

### Capture profiles and sign-in

A capture profile is an isolated, persistent browser identity — its own cookies, cache, and
sessions. The seller signs in once per environment and later builds run unattended. Profiles also
carry **per-profile favorites** and **stored credentials**.

- The agent **never types a password** and **never calls `read_capture_credentials`.** Reading a
  password puts it into the agent's conversation history, which the AI service may persist, log,
  or sync. It is a separate, off-by-default permission and should stay off.
- A site that stores its sign-in only for the session will ask again after a profile switch,
  exactly as a brand-new browser window would. That is the site's choice, not a lost profile.
  Handle it with the normal pause-and-resume flow, not as a failure.

### Never invent a hostname

Following a redirect and reading where the browser landed is a **fact**. Assembling a hostname
yourself is a **guess**, and it is banned — no `contoso.*`, `fabrikam.*`, `adventureworks.*`,
`*.example`, `*.onmicrosoft.com`, or any `*.sharepoint.com` / `*.crm.dynamics.com` host the seller
has not supplied. A guessed host is usually right, which is exactly what makes it dangerous: when
it is wrong you capture a browser error page and call it a demo.

Discovery method: navigate to the vendor's canonical entry (e.g. `office.com/launch/sharepoint`),
`wait_for_capturer`, then read the **final** URL from `get_capturer_state`. Confirm it with the
seller once, then reuse it for the whole build.

### Theme

Regale cannot cleanly re-theme a finished project — theme shapes with no matching entry in the new
theme get broken from the theme and left as standalone shapes on their pages. **Branding must be
in place before any page exists.** No MCP tool loads a `.rglt` theme file, so the corporate theme
ships as a template `.rglx` project that already carries it (open it, then save to a new path so
the template is never modified). A seller can alternatively load the `.rglt` by hand in the Theme
Editor before the build starts.

### Accessibility — non-negotiable, and mostly cheap

- **Project title** is the first thing a screen reader reads. No dates, version numbers, or
  initials.
- **`allowPresenterView = true` is required** — without it the presenter notes are unreachable.
- **Section names** are announced on every page load. Make them meaningful.
- **Name every beacon after the element it highlights**, and **do not include the word "button"** —
  the reader adds the role itself, so "Save button" is announced "Save button button". (Regale's
  own capture doc contradicts this; the accessibility doc is explicit and wins.)
- **Page descriptions** say what the screen shows, what changed since the previous page, and what
  to do next. Do not describe colour or pixel position. Do not repeat text that shapes on the page
  will already announce.
- **First page** should set expectations: a simulated environment of captured screens, each page
  described, some elements clickable.
- **Shape order in the Objects pane is the screen reader's reading order.** Order top-left to
  bottom-right.
- Contrast: **4.5:1** text on background, **3:1** beacon against background.
- Font size is resolution-relative. Authoring at 1080p, target **18 pt** for an effective 16 pt
  (1440p → 28 pt, 4K → 45 pt).

### Permissions (documented defaults)

| Group | Default | Needed for |
|---|---|---|
| Read project content | On | Everything |
| Edit project content | On | Everything |
| Browser automation (HTML Capturer) | On | All HTML capture |
| Screen capture & Studio window control | On | The native fallback |
| Clipboard | On | Copy/paste of pages and shapes |
| Open, close & switch projects | On | `new_project` / `open_project` |
| Save project files | **Off** | Saving at the end |
| Publish to the Regale portal | **Off** | Not used in v1 |
| Run JavaScript in captured pages | **Off** | Escape hatch; do not rely on it |
| Read stored capture-profile passwords | **Off** | Never enable |

`get_agent_permissions` and the help tools are always available regardless of toggles. Ask for
every missing permission **up front, in one message**, naming the exact location: Regale Studio →
Home ribbon → AI & Agents → Permissions. Do not start capturing and fail halfway.

### MCP and the CLI

- The bridge is `regale-mcp-bridge.exe`, sitting next to `RegaleStudio.exe`. This repo targets the
  UAT build: `C:\Program Files\Regale Studio UAT\regale-mcp-bridge.exe`.
- Tools appear with the `regale_studio_uat-*` prefix. If they are not visible, stop and say so —
  never claim a demo was built unless a Regale capture tool actually succeeded.
- **Every tool call is one Ctrl+Z undo step**, which is why the seller can watch the build happen
  and revert anything they dislike.
- Config shape differs per client: VS Code uses a top-level `servers` key with `"type": "stdio"`;
  Claude uses `mcpServers` with `"type": "stdio"`; **Copilot CLI uses `mcpServers` with
  `"type": "local"`** — its own name for stdio.
- `rglx.exe` ships with Studio and runs **without** Studio. Read commands (`info`, `pages`, `page`,
  `shapes`, `find`, `theme`, `build`, `dump`, `describe`) plus one transactional `apply` with
  `--dry-run`. `rglx pages --json` exposes each page's `contentType` and `originalUrl`, which makes
  it a good post-build audit: prove no sign-in page or error page got captured.

### Build recording (Beta) — the biggest open opportunity

While recording in the HTML Capturer, **each click creates a new page *and* automatically drops a
themed hotspot on the clicked element, wired to advance**; each navigation becomes a page too, and
whatever animates is recorded as that page's build. Regale documents this as available to AI agents
over MCP. If agent-driven clicks register the same way a person's do, most of the explicit capture
loop collapses into a single pass. Documented limits: the click→page-load transition is not
captured, and cross-origin iframes appear fully rendered rather than progressively.

**This is not yet confirmed against a running Studio.** Do not rewrite the pipeline around it until
someone verifies it end to end.

---

## Known issues, not yet fixed

Treat this as the backlog. None of it has been applied.

**Contradicts the documentation**

1. `BUILD_PIPELINE.md` says `end_capture` does not restore the Studio window and instructs an
   explicit `set_studio_window restore`. The MCP docs state stopping a capture restores it
   automatically. The *minimize* step before capture is still correct.
2. The pipeline's permissions table omits **Open, close & switch projects** (needed by Phase 2) and
   **Screen capture & Studio window control** (needed by the whole native fallback).
3. `scripts/install-copilot-user-assets.ps1` writes `type = "stdio"` into
   `~/.copilot/mcp-config.json`. The Copilot CLI's documented type is `"local"`. The documented
   sample also carries `env: {}` and `tools: ["*"]`. `.vscode/mcp.json` is correct as written.

**Internal drift**

4. `build_orchestrator.py` still calls native capture "preferred" and HTML Capturer the "explicit
   fallback" — inverted against the pipeline. It also plans per-browser-window capture targets
   (which do not exist), plans a publish step (out of scope in v1), and swaps the notes mapping,
   sending narration to `page_description` instead of `page_notes`.
5. `SETUP.md` tells the seller to enable Publish. v1 never publishes.
6. `agent_controller.py` renders the command list in the angle-bracket form the runtime files
   explicitly forbid printing.
7. `examples/example_demo.yaml` uses `contoso.example` hosts — the exact placeholder class the
   rules ban.
8. `README.md` lists `.mcp.json` twice.

**Gaps against documented capability**

9. No shape ordering, contrast, or font-size guidance anywhere in the pipeline.
10. Persona staging is DOM-only (`set_element_text` / `set_element_image`), so it silently does
    nothing on native-capture image pages. Layer shapes are the documented mechanism there.
11. The native fallback has no cleanup pass — Regale's own workflow trims mid-transition frames,
    verifies each auto-placed beacon, and deletes stray pages. It also does not mention Skip Idle
    Frames / Skip Idle Delay, and it recommends a `maxSeconds` auto-stop where Regale's documented
    default is Max Sec disabled. That departure is defensible for an agent-driven pause, but it
    should be stated as a deliberate choice.
12. `wait_for_capturer`'s report of still-animating elements is never read; `pause_page_motion` is
    called blind.
13. Nothing verifies the finished project. `rglx pages --json` or a live-vs-captured comparison
    would.

---

## How to work on this

- **Verify against a running Studio before asserting anything about tool behaviour.** Start Regale
  Studio UAT with a project open and the `regale_studio_uat-*` tools appear. Several of the
  pipeline's remaining hedges exist only because nobody has checked.
- **Never build from memory.** After `confirm build`, the agent reads `BUILD_PIPELINE.md`. If you
  are testing and it starts capturing without mentioning permissions or profiles, it did not read
  the file — ask it "did you read BUILD_PIPELINE.md?"
- **Do not let the pipeline drift back into a duplicate.** If you find yourself pasting build steps
  into `SKILL.md` or the agent file, stop; that is the failure mode this repo already cleaned up
  once.
- **Be honest in the final summary.** Sections and pages created, hotspots placed, *every* hotspot
  skipped and why, descriptions awaiting review, scenes skipped for a missing URL or a desktop
  surface. The output is a working draft the seller polishes — say so.
- **The build never publishes and never offers to.** Publishing is available over MCP; not using it
  is a policy choice, and it pushes content live to an org portal with real access-control
  consequences. It stays the seller's decision.
