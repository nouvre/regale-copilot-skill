# Connecting an AI Agent (MCP)

Regale Studio can act as a Model Context Protocol (MCP) server, letting an AI agent — Claude, GitHub Copilot, or any other MCP-capable tool — read and edit the project you currently have open. Once connected, you can ask the agent in plain language to add pages, create and style shapes, rewrite descriptions and presenter notes, translate content, search-and-replace across the whole project, render a page to check your work, and much more. You watch the changes happen live in the editor, and every tool call is a single Ctrl+Z undo step.

The MCP server ships with Regale Studio 4.11 and later, and was significantly expanded in version 5.0 (HTML capture, in-editor HTML editing, and publishing). There is nothing extra to install — the connection runs entirely on your own PC.

**Experimental.** Connecting an AI agent is still an experimental feature. It's fully usable, but the tool set and behavior are evolving and may change in future releases. We'd love your feedback.

## How it works

Regale Studio exposes its MCP tools over a small local web server that starts with the app. AI clients don't talk to that web server directly; instead they launch a lightweight bridge program — regale-mcp-bridge.exe — that ships next to Regale Studio (normally `C:\Program Files\Regale Studio\regale-mcp-bridge.exe`). The bridge is what every client config points at.

```
AI client  ──stdio──►  regale-mcp-bridge.exe  ──HTTP (localhost)──►  Regale Studio
(Claude,                (ships with Studio)                          (the running app,
 Copilot, …)                                                          your open project)
```

This design has a few benefits worth knowing:

- **No tokens in your config.** Each time Studio launches it generates a fresh authorization token and writes it to a private discovery file under `%LOCALAPPDATA%\RegaleStudio\mcp`. The bridge reads that token at connection time, so the config you paste into your AI tool never contains a secret and keeps working across Studio restarts.
- **Connect before Studio is even running.** The bridge stays alive when Studio is closed and reconnects automatically when you open it. You can leave the connection configured in your AI tool permanently.
- **Multiple Studios at once.** The agent can launch a new Regale Studio window itself with open_studio_instance — handy when no Studio is running yet, or to open a second project to copy content into another. When more than one Studio is open, two extra tools — list_studio_instances and select_studio_instance — appear automatically so the agent can switch between them.

## The easy way: the "AI & Agents" window

The simplest way to connect is from inside Regale Studio:

1. On the Home ribbon tab, click AI & Agents.
2. On the Connect tab, choose your tool from the Your AI tool dropdown.
3. Click Apply to write the configuration for you, or Copy snippet to paste it in yourself.
4. Restart (or reload) your AI tool so it picks up the new server.

The window generates the correct snippet — including the right install path for the bridge on your machine — for each supported client, and for Claude Desktop and VS Code it can write the config file directly. If you'd rather configure things by hand, or you're using a client the dialog doesn't list, the sections below give you everything you need.

The same window's Permissions tab controls what a connected agent is allowed to do — see Permissions below.

## Generic connection settings

Every MCP client connects the same way: it runs the bridge as a stdio server with no arguments. The only differences between clients are the name of the config file and the exact JSON shape it expects.

The server entry you need, in the most common form:

```json
"regale-studio": {
  "command": "C:\\Program Files\\Regale Studio\\regale-mcp-bridge.exe",
  "args": []
}
```

**Path note.** If Regale Studio is installed somewhere other than `C:\Program Files\Regale Studio\`, point command at the regale-mcp-bridge.exe that sits next to RegaleStudio.exe. The path may contain spaces — keep it as a single JSON string; no extra quoting is needed. In JSON, remember to escape each backslash as `\\`.

Some clients require a transport type on the entry (`"type": "stdio"` or `"local"`) and some wrap servers under a different top-level key. The client-specific sections below show the exact form for each.

You can name the server anything you like, but regale-studio is the name Regale Studio's own dialog uses, and the rest of this guide assumes it.

## Claude

### Claude Desktop (also hosts Claude Cowork and Claude Code)

Claude Desktop reads claude_desktop_config.json and uses the mcpServers key. You can open this file from Claude Desktop via Settings → Developer → Edit Config, or edit it directly:

- Standard installer: `%APPDATA%\Claude\claude_desktop_config.json`
- Microsoft Store install: `%LOCALAPPDATA%\Packages\Claude_*\LocalCache\Roaming\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "regale-studio": {
      "command": "C:\\Program Files\\Regale Studio\\regale-mcp-bridge.exe",
      "args": []
    }
  }
}
```

If you already have other servers under mcpServers, add just the regale-studio entry alongside them. Restart Claude Desktop after saving. (Using AI & Agents → Connect → Apply to Claude Desktop in Regale Studio does this edit for you, finding the right config path automatically.)

### Claude Code (CLI / terminal)

Claude Code stores MCP servers per project in a .mcp.json file, or for all your projects in ~/.claude.json. Both use the mcpServers key.

The quickest way is the claude mcp add command — run it from your project folder:

```
claude mcp add --transport stdio regale-studio -- "C:\Program Files\Regale Studio\regale-mcp-bridge.exe"
```

Add `--scope project` to write a shareable .mcp.json at the project root, or `--scope user` to make it available in every project. Everything before the `--` configures Claude Code; everything after is the command it runs.

Or edit .mcp.json directly:

```json
{
  "mcpServers": {
    "regale-studio": {
      "type": "stdio",
      "command": "C:\\Program Files\\Regale Studio\\regale-mcp-bridge.exe",
      "args": []
    }
  }
}
```

Reload Claude Code (or start a new session) to pick up the change. Run /mcp inside Claude Code to confirm regale-studio is connected.

## GitHub Copilot

### Copilot in VS Code

VS Code's built-in MCP support (used by Copilot Chat in agent mode) uses a top-level servers key and requires an explicit `"type": "stdio"` on each entry.

The easiest path is AI & Agents → Connect → Apply to VS Code (user) in Regale Studio, which writes the user-scope config so it works in every workspace. To do it by hand, open the Command Palette (F1) → MCP: Open User Configuration and add:

```json
{
  "servers": {
    "regale-studio": {
      "type": "stdio",
      "command": "C:\\Program Files\\Regale Studio\\regale-mcp-bridge.exe",
      "args": []
    }
  }
}
```

This user-scope file lives at `%APPDATA%\Code\User\mcp.json`. To scope the server to a single workspace instead, put the same JSON in a .vscode/mcp.json file at the root of that workspace.

After saving, open the Command Palette → MCP: Open User Configuration and click Start on the regale-studio server (or use MCP: List Servers). In a Copilot Chat panel, switch to Agent mode to use the tools.

### Copilot CLI

The GitHub Copilot CLI reads MCP servers from ~/.copilot/mcp-config.json, using the mcpServers key with a type of "local" (its name for stdio).

You can add it interactively — run /mcp add inside the CLI and fill in the form (choose the STDIO/local type, and enter the bridge path as the command) — or edit the config file directly:

```json
{
  "mcpServers": {
    "regale-studio": {
      "type": "local",
      "command": "C:\\Program Files\\Regale Studio\\regale-mcp-bridge.exe",
      "args": [],
      "env": {},
      "tools": ["*"]
    }
  }
}
```

Run /mcp show inside the CLI to confirm the server is connected.

## What the agent can do

Once connected, the agent works against the project you have open in Regale Studio. It understands Regale's data model — a Project contains ordered Sections, which contain ordered Pages, which hold animation images and Shapes — and the split between Layers (baked into the exported page image, for covering/redacting/annotating) and Objects (interactive elements at runtime, such as buttons, beacons, and panels). It also understands the shared Theme that drives default beacon/button/panel styling, the color palette, and custom fonts.

The available tools cover:

| Area | What the agent can do |
|---|---|
| Read & inspect | Get the open project and your current selection, list sections/pages, read a page's shapes, descriptions, and presenter notes, and inspect the theme. |
| Publish | Browse the portal folders and demo cards you can publish to, check a project for publish-blocking issues, and publish the open project to the Regale portal — either to a new demo card or as a new version of an existing one. Publishing is explicit about whether to go live or upload a draft, and won't activate a live version unless you have permission. A publish runs in the background; the agent reports progress and gives you the demo links when it's done. The agent can also attach supporting files (a prep-guide PDF, a deck, a data file) to a card as downloadable assets. |
| Project files | Create a new project, open a recent or named project file, save (or Save As to a new path), launch a new Regale Studio window — optionally opening another project in it — so two projects can be worked on side by side, and gracefully close a window (saving by default). Before replacing a project with unsaved changes, the agent is told to save first — nothing is discarded without your go-ahead. |
| Copy & paste | Copy and paste whole pages, shapes, or page images — the same Windows-clipboard copy/paste you use in the editor. Because it's the system clipboard, the agent can copy from one open project and paste into another to move content between demos. |
| Render | Composite any page to a PNG to verify visual changes (optionally overlaying interactive Objects). |
| Screen capture | List the monitors / active-window capture targets, pick one, set the mode (continuous or single image), and start/stop recording — the same screen capture you drive from the ribbon. The agent can also read Studio's window position, take a screenshot of the live screen — or of a specific Studio window (the editor, the HTML Capturer, or the source editor, brought to the front first) — to check its own work, and minimize / restore / maximize / focus / resize the Studio window — handy on a single monitor so Studio isn't recorded (it leaves the taskbar while minimized; stopping a capture restores it automatically). |
| HTML capture | Drive the HTML Capturer window: open it, navigate it to a web page, wait for the page to finish loading (with an honest report on pages that never go idle — the agent can name the parts of a page that animate continuously, like a carousel, and freeze them before capturing), size the browser viewport for consistent captures, and save the page into the project as a new HTML page — the same pipeline as the capturer's Save button, one undo step. The agent can also read the page's buttons, links, and form fields the way a screen reader would ("the Sign in button"), interact with the live page — click, hover, fill forms, press keys, and scroll, with the same kind of input a real user produces — stage the page before capturing (swap a logo, avatar, name, or chart image, edit text, hide an element — handy for industry-specific demo variants), and compare the live original against the captured page side by side to verify the capture. Editing isn't limited to before capture — it can also edit a page you've already captured, in the workspace editor: change text, swap an image, tweak styles (e.g. recolor an app's chrome across pages), or hide an element, each as one undo step. It can query the page by CSS selector to find and inspect elements — on the live capturer and on the captured page in the editor alike — reaching into the shadow DOM that component frameworks (like Microsoft's) use, which makes placing beacons and anchors on the right element reliable. (On-demand content — lazily-loaded lists, collapsed menus, virtualized scroll regions — is only captured if it's on the page already, so the agent expands or scrolls to reveal it first.) Because these are real actions on a real website, the agent is instructed to act conservatively and never operate destructive controls without your explicit say-so. Running arbitrary JavaScript in the capturer is a separate, off-by-default capability you can enable on the AI & Agents window's Permissions tab ("Allow AI agents to run JavaScript in captured pages") for power-user cases the built-in tools don't cover. The agent can also manage capture profiles — the isolated browser identities used for multi-environment captures: list, create, rename, delete, and switch profiles, manage each profile's favorites, and add or update an environment's stored sign-in credentials. Reading a stored password back in plaintext is a separate, off-by-default permission (see below). |
| Structure | Add, remove, reorder, combine, and split sections and pages; add or remove page images. |
| Shapes | Create, duplicate, move, and delete shapes; instantiate theme shapes; show/hide shapes per animation step. |
| Editing | Set scalar properties, rich text (plain / HTML / XAML), and click actions; import a local video or audio file (.mp4 / .mp3) onto a page or the theme as a media shape; describe what's editable on any target. |
| Theme | Read and edit the theme, colors, and fonts; theme edits propagate to every bound instance automatically. |
| Variables | List, add, update, and remove the key/value variables shapes use at runtime. |
| Localization | Manage translation languages and per-section/page/shape translated text. |
| Search & replace | Substring or regex search-and-replace across titles, descriptions, notes, shape names, shape text, and theme shapes. |
| Comments | List, add, and delete review comments. |
| Help | Search and read these help articles to answer product questions. |

Because the agent edits the live project, you see every change as it happens, and each tool call is one Ctrl+Z undo step — so anything you don't like is easy to revert.

## Permissions

You decide what a connected agent is allowed to do. On the Home ribbon tab, click AI & Agents and open the Permissions tab. Changes apply immediately — connected agents are notified live, with no reconnect needed — and they apply to every agent that connects to this PC, whichever AI tool it comes from.

At the top is the master switch, Allow AI agents to connect to Regale Studio. Turn it off and no agent can connect at all: the connection stops being advertised on your PC, already-connected agents are cut off, and nothing is exposed until you turn it back on.

Below it, each permission group controls a set of tools. Tools in a disabled group are completely hidden from the agent; if an agent tries to use one anyway (for example, from a stale tool list), it gets a clear message telling it the capability is disabled and which toggle controls it.

| Permission | What it allows | Default |
|---|---|---|
| Read project content | See pages, shapes, project files, images, and rendered pages in the open project. | On |
| Edit project content | Change the open project in memory. Edits are undoable; nothing touches disk. | On |
| Save project files | Write the project file to disk (save_project, and the save step inside close/publish). | Off |
| Screen capture & Studio window control | Record the screen, take screenshots, move/resize the Studio window. | On |
| Browser automation (HTML Capturer) | Drive the HTML Capturer's live browser — navigate, click, type, stage pages, and manage capture profiles and favorites. | On |
| ↳ Run JavaScript in captured pages | The arbitrary-script escape hatch (execute_capturer_js). | Off |
| ↳ Read stored capture-profile passwords | Return a capture profile's saved passwords in plaintext (read_capture_credentials). Creating/updating credentials doesn't need this — only reading them back does. | Off |
| Clipboard (copy & paste) | Copy/paste pages, shapes, and images via the Windows clipboard. | On |
| Publish to the Regale portal | Upload and publish demos with your signed-in account. | Off |
| Open, close & switch projects | Create/open projects, launch new Studio windows (including the bridge's open_studio_instance), close this one. | On |

A few notes:

- Saving and publishing start off because they push content beyond the live, undoable editing session — to your disk and to the portal. Enable them when you want an agent to handle the full workflow end to end. While saving is disabled, an agent asking to close_studio_instance or publish_project with their default save-first behavior gets a clear refusal and can retry with save:false.
- Reading stored capture-profile passwords starts off because it returns secrets in plaintext to the agent (and thus to its AI service). A password an agent reads with read_capture_credentials becomes part of that agent's conversation history — which its AI service or client may persist, log, or sync — so enabling this toggle means consenting to your saved passwords leaving your PC that way. An agent can still create and update a profile's credentials with the browser-automation permission — only reading a saved password back requires this separate toggle. Leave it off unless you specifically want an agent to retrieve passwords.
- Help and reference tools are always available to a connected agent — they only read documentation. An agent can also read which permission groups are currently on (without being able to change them), so it can ask you to enable a group up front rather than failing partway through a task.
- Permissions are per-Windows-user on this PC, not per project. If you run more than one Studio at once, each window applies the settings it loaded at startup, so restart other windows after changing permissions (the master switch and open_studio_instance take effect everywhere immediately via the bridge).

## Security & privacy

- **Local only.** The MCP server listens on 127.0.0.1 (loopback) — it is never reachable from another machine on your network.
- **Per-launch authorization.** A fresh 256-bit token is generated each time Studio starts and discarded when it closes. The token lives in a discovery file under `%LOCALAPPDATA%\RegaleStudio`, which only your Windows user account can read, so other processes on the PC can't reach the MCP surface without it.
- **The agent can modify your project.** A connected agent can read and change the open project just as you can. Connect tools you trust, review changes as they appear, and use Ctrl+Z if needed. Your project content is sent to whichever AI service your client uses (e.g. Anthropic for Claude, GitHub for Copilot) — the same as any other prompt you send that tool.
- **You control the capabilities.** The Permissions tab of the AI & Agents window lets you turn off whole capability groups — saving, publishing, browser automation, the clipboard, screen capture — or disable agent connections entirely. Saving to disk and publishing to the portal are off until you enable them.

## Troubleshooting

- **"Bridge not found" in the dialog, or the agent can't connect.** Confirm regale-mcp-bridge.exe exists next to RegaleStudio.exe and that the command path in your config matches. Reinstall Regale Studio if the bridge is missing.
- **Agent connects but lists no tools.** That's expected when Regale Studio isn't running — the bridge stays connected and the tools appear once you open Studio. Most clients refresh automatically; if yours doesn't, reload it.
- **The connection dropped and won't come back / the bridge was unloaded.** If the bridge process gets shut down or unloaded (for example after a crash, an update, or the AI tool closing it), the fix is almost always to restart the AI host application so it relaunches the bridge — reloading a chat or starting a new session inside the same app usually isn't enough. For Claude Desktop, "restart" means a full Exit, not just closing the window — closing the window only hides Claude to the system tray, leaving the old process (and its stale bridge) running. Exit it completely first: right-click the Claude icon in the system tray and choose Exit, or use the hamburger menu → File → Exit inside Claude, then reopen it.
- **Changes don't apply / "Studio offline" errors.** Make sure a Regale Studio window is actually open. If you have several open, ask the agent to use list_studio_instances / select_studio_instance to target the right one.
- **Claude Desktop didn't pick up the change.** Fully quit and reopen Claude Desktop — it only reads claude_desktop_config.json at startup. Closing the window isn't enough; use Exit (system-tray icon → Exit, or hamburger menu → File → Exit) so the process actually stops, then reopen it.
- **VS Code server is "stopped."** Open the Command Palette → MCP: List Servers, select regale-studio, and click Start, then use Copilot Chat in Agent mode.

## See also

- RGLX Command-Line Interface — script operations against .rglx files without opening Studio.
- Release Notes - Version 5.0
