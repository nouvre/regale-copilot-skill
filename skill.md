# Regale Demo Generator Skill

> **This is an overview, not instructions.** The files agents actually load are listed
> under [Where the real instructions live](#where-the-real-instructions-live). Do not
> copy behaviour rules into this file — that is what caused the drift this repo already
> had to clean up once.

## Purpose

Enable non-developer Microsoft sellers to generate interactive product demos in Regale
Studio through conversational chat. A seller describes the demo in plain language; the
agent turns it into a reviewable storyboard, then drives Regale Studio's HTML Capturer
to build it — navigating a real browser, clicking through the product, capturing each
screen as a slide, and wiring up hotspots and the talk track.

## Two phases

**Definition** — anywhere. The seller gives a brief (or uploads a Word `.docx` with a
two-column "What to say / What to show" table). The agent produces a compact preview in
chat, supports short inline edits, and waits. Nothing touches Regale until the seller
types exactly `confirm build`.

**Build** — on the same PC as Regale Studio. The agent captures each screen through the
HTML Capturer and assembles the project live in the editor, where the seller can watch
it happen and Ctrl+Z anything they dislike.

## Scope of v1

| | |
|---|---|
| Surfaces | Web only. Desktop apps (Outlook, Excel, Teams desktop) are out of scope. |
| Capture | HTML Capturer, agent-driven. Screen recording is not used — it cannot be automated. |
| Auth | A named capture profile per environment. The seller signs in once; later builds are unattended. |
| Demo style | Seller-led. Narration becomes presenter notes. |
| Output | A saved project. Publishing is the seller's job. |
| Quality bar | A working draft the seller polishes — not a finished demo. |

## How the demo maps into Regale

| Demo definition | Regale |
|---|---|
| Scene | Section (drives the Table of Contents) |
| Beat | Page (one screen, one click) |
| Narration | Presenter notes |
| — | Page description = accessibility text, generated separately |

## Where the real instructions live

| File | Role |
|---|---|
| [`.github/skills/demo/BUILD_PIPELINE.md`](.github/skills/demo/BUILD_PIPELINE.md) | **Canonical build pipeline.** The only place it is written down. |
| [`.github/skills/demo/SKILL.md`](.github/skills/demo/SKILL.md) | Copilot Agent Skill — definition mode, points at the pipeline |
| [`.github/agents/regale-demo.agent.md`](.github/agents/regale-demo.agent.md) | Copilot app custom agent — same |
| [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | Auto-loaded repo instructions — definition mode only |
| [`AGENTS.md`](AGENTS.md) | Auto-loaded agent instructions — definition mode only |

## Constraints worth remembering

- Regale MCP is local-only (127.0.0.1). The build must run on the same PC as Studio.
- Read, Edit, and Browser automation permissions are on by default. **Save and Publish
  are off** — the seller enables Save once if they want the agent to save the file.
- Regale cannot cleanly re-theme a finished project, so branding is applied at project
  creation, from a template `.rglx`.
- HTML capture and build recording are officially **Beta** in Regale 5.0.
