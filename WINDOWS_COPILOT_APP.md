# Regale Demo Setup for GitHub Copilot on Windows

Use this flow for the GitHub Copilot app or Copilot CLI on the same Windows machine
where Regale Studio is running.

## One-Time Setup

1. Install and sign in to GitHub Copilot.
2. Install Regale Studio UAT.
3. Open PowerShell.
4. Run the installer:

```powershell
$u = 'https://raw.githubusercontent.com/nouvre/regale-copilot-skill/main/scripts/install-from-github.ps1'
$p = Join-Path $env:TEMP 'install-regale-demo.ps1'
Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $p
powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

If this repository is already downloaded, you can instead double-click:

```text
install-regale-demo.cmd
```

Advanced/local install:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install-copilot-user-assets.ps1
```

This installs:

- `Regale Demo` as a personal Copilot custom agent in `$HOME\.copilot\agents`.
- `demo` as a personal Copilot skill in `$HOME\.copilot\skills`, including
  `BUILD_PIPELINE.md` — the build instructions the agent reads after `confirm build`.
- The Regale Studio UAT MCP server in `$HOME\.copilot\mcp-config.json`.

If Regale Studio is installed somewhere else, pass the bridge path:

```powershell
.\scripts\install-copilot-user-assets.ps1 -RegaleMcpBridgePath "C:\Path\To\regale-mcp-bridge.exe"
```

Restart GitHub Copilot afterwards. Use **Exit** from the system tray, not just closing
the window — the agent and skill files are only read at startup.

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

## Quick Troubleshooting

- **`Regale Demo` missing under `/agent`** — restart GitHub Copilot fully (tray →
  Exit) after running the installer.
- **The agent starts building without mentioning permissions or profiles** — it did not
  read the pipeline. Ask it: *"did you read BUILD_PIPELINE.md?"* If the file is missing,
  re-run `scripts\install-copilot-user-assets.ps1`.
- **Regale tools unavailable** — confirm the config contains `regale-studio-uat`:

  ```powershell
  Get-Content "$HOME\.copilot\mcp-config.json"
  ```

- **"Studio offline" or changes don't appear** — make sure a Regale Studio window is
  actually open with a project loaded.
- **The agent only prints another preview, or says it "built demo-definition"** — it
  never reached Regale Studio. Restart Copilot and check the MCP config above.
- **It asks you to sign in again on a later build** — usually the site stores its
  sign-in per session. Sign in and continue; the agent resumes where it paused.
- **The MCP bridge cannot start** — verify the path to `regale-mcp-bridge.exe` next to
  `RegaleStudio.exe`.
