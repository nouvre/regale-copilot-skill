# RGLX Command-Line Interface

The RGLX CLI is a command-line tool for inspecting, exporting, and — as of 4.11 — editing Regale Studio project files without opening the Studio UI. It is intended for developers, power users, AI agents, and build pipelines that need to script operations against .rglx or .cts files — for example, extracting page metadata into JSON for a content dashboard, pulling the final screenshot from every page for a thumbnail gallery, or batch-applying content and style changes across a project.

The CLI ships alongside Regale Studio 4.10 and later as rglx.exe (installed under the Regale Studio install directory). All examples below use rglx as the executable name.

**Reading vs. editing.** The query commands (info, pages, page, shapes, find, images, dump, theme, variables, localizations, comments, describe) are read-only. All edits go through the single apply command, which runs every change as one all-or-nothing transaction — see Editing a project.

## Overview

- **Supported input files:** .rglx (Regale Studio projects) and .cts (legacy Click Through Studio projects).
- **Indexing:** sections and pages are 1-based. `--section 1` is the first section, `--page 1` is the first page of that section.
- **Output:** commands print human-readable text by default. Add `--json` to emit structured JSON suitable for piping into other tools.
- **Help:** run `rglx --help` to see the built-in usage summary.

## Command reference

| Command | Purpose |
|---|---|
| `rglx info <file>` | Show project title, file version, section count, total pages, and per-section page counts. |
| `rglx pages <file>` | List all pages with their descriptions. Optionally filter by section. JSON output also includes each page's contentType (Image or Html) and, for HTML pages, the originalUrl it was captured from. |
| `rglx page <file> --page N` | Dump a single page's content type, source URL (for captured HTML pages), description, presenter notes, image count, and shapes. |
| `rglx shapes <file> --page N` | List all shapes on a page (including hidden ones) with type, text, state, whether each shape lives in the page's Objects or Layers collection, and — for themed instances — the BasedOnThemeShapeId of the theme shape they derive from. Use `--only objects` or `--only layers` to filter. |
| `rglx build <file> --page N` | (Beta) Summarize a page's recorded build (page-load / interaction animation): raw and effective-after-edits durations, segments with their bounds and current retiming, event counts by type, playBuildOnEnter, and the baseline/final/timeline asset ids. Reports hasBuild: false for a page with no build. See Editing page builds. |
| `rglx find <file> <query>` | Search substring across shapes, page descriptions, and presenter notes. |
| `rglx images list <file>` | List images in the project, optionally scoped to a specific page. |
| `rglx images export <file> --page N --out DIR` | Export one or more images from a page to disk. |
| `rglx dump <file> --out DIR` | Export the entire project as a single project.json plus an optional images/ folder. |
| `rglx theme <file>` | Show the theme: name, letterbox color, default beacon/button/panel shapes, color palette, fonts, and the theme's reusable Objects/Layers shape libraries with their shapeIds and nested children. |
| `rglx variables <file>` | List project and theme variables; add `--built-ins` to include runtime variables (pg, title, …). |
| `rglx localizations <file>` | List the source language and registered translation languages with per-language field counts. |
| `rglx comments <file>` | List page comments (author, date, text), optionally scoped to a section/page. |
| `rglx describe <file> --target …` | List a target's editable properties with current values, types, and allowed values (discovery for update_properties). |
| `rglx apply <file> …` | Edit the project (4.11+) — apply one or more changes as a single transaction. See Editing a project. |

### Common flags

- `--json` — emit JSON instead of plain text (available on most commands).
- `--section N` / `--page N` — target a specific section or page (1-based).
- `--text-format text|xml|xaml|html` — how rich text (descriptions, notes, shape text) is serialized. Default is plain text.
- `--format png|webp|original` — image encoding for images export. `original` copies the stored bytes verbatim.
- `--dry-run` — available on dump; shows what would be written without touching the disk.

## Editing a project

As of 4.11 the CLI can modify projects, not just read them. All edits go through one command, `rglx apply`, which runs a transaction: it applies an ordered list of operations and saves once at the end. If any operation fails, nothing is saved — a batch either fully succeeds or leaves your file untouched.

There are two ways to supply operations:

- Inline, separated by a `+`:

```
rglx apply demo.rglx add_section --title "Intro" --as $s + add_page --section $s
```

- From a file or stdin with `--ops` — a JSON array, an `{ "ops": [ … ] }` object, or one JSON object per line (JSONL); use `-` to read stdin:

```
rglx apply demo.rglx --ops edits.json
```

**Handles.** Name the result of a create operation with `--as $name`, then reference `$name` in a later operation's `--section`, `--page`, or `--shapeId`. The CLI resolves the handle to the real object, so you can create something and edit it in the same batch.

**Safety.** Add `--dry-run` to validate every operation and report what would change without writing anything. By default the source file is updated in place; pass `--out <file>` to write a new file and leave the original untouched. Legacy .cts and older .rglx files are upgraded to the current save format when written.

### Available operations

| Group | Operations |
|---|---|
| Structure | add_section, remove_section, reorder_section, add_page, remove_page, reorder_page, combine_pages |
| Images | add_images_to_page (PNG/WebP), remove_image_from_page |
| Media | add_media (import an .mp4/.mp3 as a video/audio shape), set_media_source (repoint a media shape at a different file) |
| Text | set_text (page description/notes, project notes, or a shape via `--shapeId`) |
| Shapes | create_shape, delete_shape, duplicate_shape, move_shape, instantiate_theme_shape, set_shape_animation_visibility |
| Properties | update_properties (any editable scalar on a project, section, page, shape, or theme) |
| Variables | add_variable, update_variable, remove_variable |
| Comments | add_comment, delete_comment |
| Theme | add_theme_color, remove_theme_color, add_font, remove_font |
| Localization | add_localization, remove_localization, set_localized_text |
| Builds (Beta) | edit_build_timing (retime a page's build), set_play_build_on_enter (toggle auto-play), remove_page_build (drop a build) — see Editing page builds |

Run `rglx --help` for the current op list, and `rglx describe` (below) to discover the parameters for update_properties.

### Editing properties

To change properties on an existing object, first ask what's editable with describe, then set them with update_properties:

```
rglx describe demo.rglx --target shape --shapeId 1a2b3c... --json
rglx apply demo.rglx update_properties --target shape --shapeId 1a2b3c... \
    --width 300 --style.borderColor "#FF0078D4" --clickAction SpecificPage
```

describe reports each property's name, type, allowed values (for enums), current value, and whether it is locked by the theme. Property names are camelCase; nested ones use a dot (e.g. style.borderColor). An invalid value produces an error that lists the accepted options.

### Theme edits propagate

Editing a theme shape — its text with set_text, or its style with update_properties — updates every page instance based on that theme shape automatically, exactly like Studio's Update Theme. Properties controlled by the theme can't be set directly on an instance; edit the theme shape instead (the error message tells you which one).

To discover the shapeIds these ops target, run `rglx theme <file>` (or `--json`): it lists the theme's Objects/Layers shape trees with every shapeId and nested child. Pass a top-level object/layer id as `--themeShapeId` to instantiate_theme_shape, or any theme shapeId (including nested ones) as `--shapeId` to set_text / update_properties to edit the template and propagate the change. Going the other direction, `rglx shapes <file> --page N` reports each themed instance's BasedOnThemeShapeId, so you can find the theme shape behind an instance you can already see.

```
# Discover a theme object id, then clone it onto page 1 (validate first)
rglx theme demo.rglx --json | jq -r '.objects[0].shapeId'
rglx apply demo.rglx --dry-run \
  instantiate_theme_shape --themeShapeId <id> --section 1 --page 1
```

### A worked editing example

Create a styled button on page 1 and wire it to navigate, in a single transaction, validating first:

```
rglx apply demo.rglx --dry-run \
  create_shape --list objects --x 40 --y 40 --width 200 --height 60 --name "Next" --as $btn \
  + set_text --target shape --shapeId $btn --text "Get started" \
  + update_properties --target shape --shapeId $btn --clickAction SpecificPage
```

### Adding video or audio

add_media imports a local .mp4 (video) or .mp3 (audio) file and places it on a page as a media shape — the shape type is chosen from the file extension. The file is referenced in place and its bytes are embedded into the project when it saves, so the path must still exist at save time. Playback options (`--showControls`, `--autoPlay`, `--mute`, `--loop`) are optional.

```
rglx apply demo.rglx \
  add_media --file "C:\clips\intro.mp4" --name "Intro video" \
    --x 100 --y 80 --width 960 --height 540 --section 1 --page 1 --showControls true
```

To swap the clip behind an existing media shape, use `set_media_source --shapeId <id> --file <path>` (a video shape needs an .mp4, an audio shape an .mp3). Only .mp4 and .mp3 are supported.

Drop `--dry-run` to apply and save.

### Editing page builds

**Beta.** Page builds are part of the Beta HTML Capture feature.

An HTML page can carry a recorded build — a page-load / interaction animation made of a baseline snapshot plus a timeline of timed events. Recording a build needs a live browser, so it's done in Regale Studio's HTML Capturer (or over the MCP server), not in the CLI. What the CLI can do headlessly is inspect and retime an already-recorded build.

Inspect a build with the read command:

```
rglx build demo.rglx --page 3 --json
```

It reports hasBuild, rawDurationMs / effectiveDurationMs (before / after edits), the detected segments (each with its raw bounds and any current durationScale / gapBeforeMs / disabled), stripScroll, event counts by type, playBuildOnEnter, and the baseline/final/timeline ids. A page with no build returns hasBuild: false.

Retime a build non-destructively with edit_build_timing — the raw event timings are never changed; only an edits block is updated, and playback derives effective times from it:

```
# Play the whole build twice as fast and trim the dead air before it starts
rglx apply demo.rglx \
  edit_build_timing --page 3 --speed 2 --leadInMs 0

# Stretch segment 1 to half speed and set an 800 ms gap before it
rglx apply demo.rglx \
  edit_build_timing --page 3 --segIndex 1 --durationScale 2 --gapBeforeMs 800

# Collapse segment 2 — drop it to a single instant right after segment 1
rglx apply demo.rglx \
  edit_build_timing --page 3 --segIndex 2 --collapse true

# Strip all scrolling from playback (page won't scroll; scroll-loaded content stays)
rglx apply demo.rglx \
  edit_build_timing --page 3 --stripScroll true

# Remove segment 2 from playback entirely (reversible with --disableSegment false)
rglx apply demo.rglx \
  edit_build_timing --page 3 --segIndex 2 --disableSegment true
```

- `--speed` — global multiplier (>0; 2 = twice as fast).
- `--leadInMs` — trim/set the lead-in before the first segment (0 = start immediately).
- `--stripScroll` — true drops ALL scroll events from playback (the page won't scroll, but content that scrolling lazy-loaded still appears — the clean way to remove a captured scroll animation); false restores scrolling.
- `--segIndex N` with `--durationScale` (>0, compress <1 / stretch >1) and/or `--gapBeforeMs` (override the idle gap before segment N; 0 merges it into the previous segment — on segment 0, `--gapBeforeMs`/`--leadInMs` trims the lead-in) and/or `--collapse` (true drops segment N to a single instant right after the previous segment — zero internal duration and no gap before; false expands it back) and/or `--disableSegment` (true removes segment N from playback entirely — its events don't play and it takes no time; false restores it). Get segment indexes from `rglx build`.

Toggle whether a build auto-plays when a viewer enters the page:

```
rglx apply demo.rglx set_play_build_on_enter --page 3 --value false
```

(This is the same as `update_properties --target page --page 3 --playBuildOnEnter false`.)

Remove a build entirely — the page keeps its final static state, and the orphaned baseline/timeline assets are pruned when the project saves:

```
rglx apply demo.rglx remove_page_build --page 3
```

## Example use cases

### Export project metadata as JSON

Print a one-shot JSON summary of a project — title, save-file version, section count, and page counts per section:

```
rglx info myproject.rglx --json
```

The JSON output includes a fileVersion field (e.g. "9.1") that reports the save-file format version of the project — useful for detecting older files that predate features you rely on.

For a full structured dump of every page, shape, and presenter note (without any images), use dump with `--images none`:

```
rglx dump myproject.rglx --out ./export --images none
```

This writes ./export/project.json containing the entire project as JSON. Combine with `--text-format html` to get shape and description text as HTML fragments.

To pipe the dump directly into another tool without leaving any files on disk, omit `--out` and pass `--json`:

```
rglx dump myproject.rglx --json | jq '.sections[].title'
```

### Export the last image from each page

The last image on a page is typically the final state after any captured interactions — useful for thumbnails or change logs. The easiest way to get it from every page in one call is dump:

```
rglx dump myproject.rglx --out ./export --images last --image-format png
```

This writes ./export/project.json plus ./export/images/ containing one PNG per page. Files are named with the pattern section{SS}_page{PPP}_img{II}.png so they sort naturally.

To pull the last image from a single page instead, use images export `--last`:

```
rglx images export myproject.rglx --section 1 --page 3 --out ./out --last
```

### List pages in a specific section

Get every page in section 2 as JSON, suitable for feeding into another script:

```
rglx pages myproject.rglx --section 2 --json
```

### Search for text across a project

Find every shape, description, or presenter note that mentions "Sign in" (case-insensitive):

```
rglx find myproject.rglx "Sign in" --in shapes,notes,desc -i
```

`--in` takes a comma-separated list of shapes, desc, and/or notes. Omit it to search everywhere.

### List only the Layer shapes on a page

Every shape in a page lives in one of two collections: Objects (interactive shapes like buttons and hotspots) or Layers (non-interactive decoration). `rglx shapes` tags each row with a Location field, and you can filter to just one collection with `--only`:

```
rglx shapes myproject.rglx --section 1 --page 3 --only layers --json
```

Use `--only objects` to flip it and see only the interactive shapes. Omit `--only` to get everything, with each shape's Location still tagged as "object" or "layer" in the JSON output.

### Dump a single page with shapes and presenter notes

When you need everything about one page — content type, captured source URL, description, presenter notes, shape list, and image count — as JSON with rich text preserved as HTML:

```
rglx page myproject.rglx --section 1 --page 3 --text-format html --json
```

### Find captured HTML pages and their source URLs

HTML pages captured from a live site record the URL they came from in originalUrl. List every page, then filter to the HTML ones and pull their source URLs — for example to drive a recapture pass that refreshes a demo against its original sites:

```
rglx pages myproject.rglx --json | jq -r '.[] | select(.contentType == "Html") | "\(.section)/\(.page)\t\(.originalUrl)"'
```

Image pages and HTML pages with no recorded URL report originalUrl as null.

## Tips

- Indices are 1-based. `--section 1 --page 1` is the very first page of a project.
- Use `--dry-run` on dump to preview what files would be written before committing to a large export.
- `--text-format` original-style text: pick xml or xaml if you need to round-trip rich text back into another tool, or html for web rendering. Plain text is the default and strips formatting.
- `--format original` on images export copies the stored image bytes untouched — use this when you want the exact file Regale Studio is holding (including WebP or Rglc captures) rather than a re-encoded PNG.
- Piping JSON: commands that support `--json` write to stdout, so you can pipe them straight into jq, PowerShell's ConvertFrom-Json, or any JSON-aware tool.

## See also

- Release Notes - Version 4.10
- Connecting an AI Agent (MCP) — the same project model, driven by an AI agent against a live Studio session.
