# Regale Studio Help Documentation

A local copy of the Regale Studio help articles this project is built against. Kept here so the
repo is self-contained: an agent can read the actual source instead of trusting a summary, and a
contributor can check a claim without leaving the codebase.

**These are Regale's docs, not ours.** Do not edit them to reflect what we wish were true. If the
product changes, replace the article. If our pipeline disagrees with an article, fix the pipeline
or record the disagreement in [`TEAM_PROMPT.md`](../../TEAM_PROMPT.md) — do not quietly edit the
doc.

Wording is reproduced as published; only structure (headings, tables, code fences) has been
normalised to markdown.

| # | Article | What it covers |
|---|---|---|
| 1 | [Welcome to Regale Studio](01-welcome-to-regale-studio.md) | What the product is, install, the `.rglx` project file, and the Project → Sections → Pages → Images/Shapes hierarchy |
| 2 | [Making Your First Demo](02-making-your-first-demo.md) | The shortest end-to-end native capture workflow and its default settings |
| 3 | [How to Capture a Demo](03-how-to-capture-a-demo.md) | **The big one.** HTML Capturer, capture profiles, size mode, scroll positions, build recording, then native capture: machine prep, areas, modes, animation cleanup, patches, hover effects, scroll effects, beacon positioning |
| 4 | [Adding a Talk Track](04-adding-a-talk-track.md) | Presenter notes, accessibility descriptions, and information annotations |
| 5 | [Working with Shapes](05-working-with-shapes.md) | Objects vs Layers, shape types, layout panels, click/hover actions, styles, beacons, placement, animation mode, variables and visibility expressions |
| 6 | [How to Publish a Demo](06-how-to-publish-a-demo.md) | Sign in → organization → folder → demo card → asset → upload, draft vs live, and visibility rules |
| 7 | [Making Accessible Demos](07-making-accessible-demos.md) | Project/section/page settings, shape names and roles, contrast and font-size targets, and testing with Narrator |
| 8 | [Working with Themes](08-working-with-themes.md) | Theme Editor, colors, fonts, reusable theme shapes, and why branding must come first |
| 9 | [RGLX Command-Line Interface](09-rglx-command-line-interface.md) | Headless inspection and transactional editing of `.rglx` files without Studio running |
| 10 | [Connecting an AI Agent (MCP)](10-connecting-an-ai-agent-mcp.md) | The bridge, per-client config, the full tool surface, the permission model, and security |

## Where to look first

| If you are… | Read |
|---|---|
| Changing what the agent does during a build | 10 (tools and permissions), then 3 (what capture can actually do) |
| Touching anything about beacons, hotspots, or shapes | 5 and 7 — the accessibility rules are binding, not advisory |
| Working on branding or project setup | 8, plus §2 of 7 for title/language |
| Writing presenter notes or page descriptions | 4 and §3 of 7 |
| Debugging why a captured page looks wrong | 3, "A capture is a snapshot, not a working app" and "Size Mode" |
| Adding verification or audit tooling | 9 |

## Known internal inconsistency

Article 3 (§9, Positioning Beacons) gives beacon name examples including the word "button" —
*"Save Button"*, *"Settings Tab"*. Article 7 (§4, Name) explicitly forbids it: the screen reader
announces the role itself, so "Save button" is read as *"Save button button"*, and the Narrator
test workflow in the same article lists that as a defect to catch.

**Article 7 wins.** This project's pipeline follows it.
