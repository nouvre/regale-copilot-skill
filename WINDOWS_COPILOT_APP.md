# Regale Demo Setup for GitHub Copilot on Windows

Use this flow for the GitHub Copilot app or Copilot CLI on the same Windows machine
where Regale Studio is running.

## One-Time Setup

1. Install and sign in to GitHub Copilot.
2. Install Regale Studio UAT.
3. Open PowerShell and paste this one line:

```powershell
irm https://raw.githubusercontent.com/nouvre/regale-copilot-skill/main/scripts/install-from-github.ps1 | iex
```

If you already have this folder on disk, double-click `install-regale-demo.cmd` instead.

The installer checks your machine first and prints a pass/fail line for each thing it
needs, so if something is missing you see all of it at once rather than discovering it
mid-build. It finds `regale-mcp-bridge.exe` itself — from a running Regale Studio, the
usual install folders, or the uninstall registry — and refuses to write a configuration
pointing at a bridge that isn't there. It then reads back what it wrote to confirm the
files landed and the config parses.

This installs:

- `Regale Demo` as a personal Copilot custom agent in `%USERPROFILE%\.copilot\agents`.
- `demo` as a personal Copilot skill in `%USERPROFILE%\.copilot\skills`, including
  `BUILD_PIPELINE.md` — the build instructions the agent reads after `confirm build`.
- The Regale Studio UAT MCP server in `%USERPROFILE%\.copilot\mcp-config.json`, registering the
  ~50 Regale tools a demo build uses rather than all ~138. The full catalogue costs about
  55,000 tokens of context on every model request, and a build makes 60–100 of those, so
  trimming it makes every step faster. If a build ever stops because a tool was not
  registered, run `install-regale-demo-all-tools.cmd` and tell us which one was missing.

Any other MCP servers already in your Copilot config are left alone.

Copilot only reads agent, skill, and MCP files at startup, so it has to be restarted. If
it is running, the installer offers to close and relaunch it for you — answer `y`.
Otherwise restart it yourself with **Exit** from the system tray; closing the window is
not enough.

Detection covers the default and common install paths. If your Regale install is
somewhere unusual, point at it directly:

```powershell
.\scripts\install-copilot-user-assets.ps1 -RegaleMcpBridgePath "C:\Path\To\regale-mcp-bridge.exe"
```

## How Capture Works

The agent builds demos through Regale's **HTML Capturer** — a real browser that Regale
controls. The agent drives it: it navigates, clicks through the product, and captures
each screen as a slide. You do not switch windows, manage focus, or click through the
app yourself.

To reach screens that are not on the landing page, the agent starts at one real URL and
then **clicks its way in**, exactly as a person would. You do not need a URL for every
screen — only the entry point.

Native screen recording still exists, but only as a manual fallback for surfaces that
are not web pages (Outlook, Excel, Teams desktop). See
[When native capture is used](#when-native-capture-is-used).

## Signing In: the Managed Profile

The Capturer keeps its own browser identities, called **capture profiles**. A profile is
isolated — its own cookies, cache, and sessions — and it persists, so signing in is
designed to be a one-time step per environment.

What that means in practice:

1. On the first build against a product, the agent creates a profile, opens the
   product, and **pauses** so you can sign in — including any MFA prompt.
2. You sign in inside the Capturer window and tell the agent you're done.
3. The agent resumes at the exact scene it paused on. Nothing already built is lost.
4. On later builds it reuses that profile and should not stop again.

Two things worth knowing:

- **The agent never types your password.** It will not read stored passwords either;
  that is a separate Regale permission which is off by default and should stay off,
  because it would put your password into the chat transcript.
- **Some sites sign you out anyway.** A site that only stores its sign-in for the
  session, rather than in a persistent cookie, will ask again — the same as it would in
  a new browser window. The agent pauses and asks you to sign in; that is expected, not
  a broken profile.

You can manage profiles yourself in the Capturer toolbar (the person icon) — create,
rename, switch, and store per-profile favourites.

## Daily Use

1. Start Regale Studio UAT.
2. Open or create a Regale project.
3. Open the GitHub Copilot app.
4. Type `/agent` and select `Regale Demo`.
5. Enter a plain brief:

```text
Pitch SharePoint to an executive. Keep it short and lead with business value, arguing how a single governed intranet cuts scattered files and drives faster decisions across the org.
```

The agent returns a compact preview and waits for edits.

When ready, type:

```text
confirm build
```

Only then does the agent call Regale MCP tools.

## What to Expect After `confirm build`

### How long, and why it looks stuck

A build is roughly **20 Regale calls per scene**, and each one is a separate round trip to
the model. A three-scene demo is 60–100 calls: usually **10–15 minutes**, sometimes three
times that when the model service is busy. Thirty to sixty seconds of silence between steps
is normal, and it is not a sign anything is wrong.

Note that this has nothing to do with the length of the finished demo. An 85-second video
is not an 85-second build.

The agent tells you its estimate before it starts and reports at each scene boundary
("scene 2 of 4 recorded, 5 pages"), so you can tell progress from a hang.

### Turn on "allow all tools" first

Copilot asks permission the first time it uses each new tool. A build reaches for about
twenty different Regale tools, spread across the whole run — so if you leave approvals on,
prompts arrive at unpredictable moments over fifteen minutes, and **the build stops dead at
each one** until you come back to the window.

Turn on allow-all for the session before you type `confirm build`. The agent will remind
you. Two caveats:

- It is **per session**. If you resume a chat later to finish a build, turn it on again.
- Some enterprise-managed GitHub accounts block it. If the toggle is unavailable, keep the
  Copilot window in view during the build and answer prompts as they come.

### The rest

- It reads `BUILD_PIPELINE.md` and says so.
- It checks Regale permissions and asks you **up front**, in one message, to enable
  anything missing. It should not fail halfway through for a permission.
- It confirms a project is open and sets the project title, language, and Presenter
  View.
- It checks capture profiles and, if a sign-in is needed, pauses (see above).
- It asks for the entry URL when a scene needs a tenant-specific surface. It will not
  invent one — placeholder hostnames do not resolve and would capture an error page.
- Per scene: it navigates, verifies the right page actually loaded, captures it, places
  a named click hotspot, writes your narration into presenter notes, and moves on by
  clicking through to the next state.
- It finishes at a **saved project**. It does not publish. Review the demo in Regale and
  publish it yourself.

The result is a working draft. Expect to trim slides, nudge a hotspot, and tighten
narration before presenting.

**Page descriptions are not written by default.** These are the screen reader texts, and
they cost an extra round trip per page — a fifth of the build — on pages you are about to
trim. The agent offers the pass at the end; say "write descriptions" once the draft is the
shape you want. Page 1 is described during the build regardless. Ask for descriptions up
front if you need a fully accessible deliverable and can accept the extra time.

### Permissions

Read, Edit, and Browser automation are on by default and are all the build needs.

**Save project files is off by default.** Turn it on if you want the agent to save the
file for you: Regale Studio → Home ribbon → **AI & Agents** → **Permissions**. If you
leave it off, the build still works — press Ctrl+S in Regale at the end.

Publish is off and stays off; publishing is your call, not the agent's.

## When Native Capture Is Used

Only when you ask for it, or when the surface genuinely is not a web page — a desktop
application, or anything without a URL.

It is **not automated**. You drive the app yourself while Regale records the screen, and
Regale Studio is minimised during recording so it does not appear in the frames. The
agent will tell you which window to bring forward and when to click.

If a demo mixes web and desktop surfaces, the web scenes still build automatically; only
the desktop ones need you.

## Refining an Existing Draft

Use focused audits when you want to inspect one class of problem without changing the
open project:

```text
audit duplicates
audit screenshot order
audit setup and errors
audit demo flow
show refinement plan
```

These commands are read-only. `refine the open draft` runs all audits and then asks for
conservative or aggressive execution. `apply refinement plan` also reruns the audits
against the current saved file before making changes, so an older plan cannot be applied
to a changed project.

## Quick Troubleshooting

- **`Regale Demo` missing under `/agent`** — restart GitHub Copilot fully (tray →
  Exit) after running the installer.
- **The agent starts building without mentioning permissions or profiles** — it did not
  read the pipeline. Ask it: *"did you read BUILD_PIPELINE.md?"* If the file is missing,
  re-run the installer.
- **Regale tools unavailable** — re-run the installer. Its verify step reports whether the
  config is valid and whether the bridge it names actually exists, which is the usual
  cause. To look yourself:

  ```powershell
  Get-Content "$env:USERPROFILE\.copilot\mcp-config.json"
  ```

- **"Studio offline" or changes don't appear** — make sure a Regale Studio window is
  actually open with a project loaded.
- **The agent only prints another preview, or says it "built demo-definition"** — it
  never reached Regale Studio. Restart Copilot and check the MCP config above.
- **It asks you to sign in again on a later build** — usually the site stores its
  sign-in per session. Sign in and continue; the agent resumes where it paused.
- **The build seems to have stopped** — check for an unanswered tool-approval prompt
  first; that is the usual cause, and it waits indefinitely. Otherwise, long gaps are
  expected (see [How long](#how-long-and-why-it-looks-stuck)). Turn on allow-all to avoid
  it entirely.
- **"That tool isn't available"** mid-build — the tool is outside the installed subset.
  Run `install-regale-demo-all-tools.cmd`, restart Copilot, and report which tool it was
  so it can be added to the default list.
- **The MCP bridge cannot start** — re-run the installer; it re-detects the bridge and
  fails loudly if it cannot find one. If Regale Studio is running when you install,
  detection uses that install's folder.
