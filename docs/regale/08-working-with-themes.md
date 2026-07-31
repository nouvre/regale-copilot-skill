# Working with Themes

Themes give every demo in Regale Studio a consistent visual identity. A theme defines colors, fonts, default shape styles, and reusable Object and Layer shapes that pages can pull from. Setting up a thoughtful theme up front means new shapes match your brand automatically and any global change you need later — such as updating a brand color — can be made in one place and ripple through the entire project.

This document covers the Theme Editor dialog and the theme-related commands on the Object Shapes and Layer Shapes lists in the page view.

## 1. Opening the Theme Editor

The Theme Editor is opened from the Project Tab in the ribbon. The Theme group on that tab shows the name of the project's current theme along with an Edit Theme button — click the button to open the Theme Editor window for the active project.

Every Regale Studio project has exactly one theme. New projects start with the built-in default theme, which you can edit directly, replace by loading a saved theme file from disk, or use as a starting point for your own.

## 2. Theme Editor Dialog

The Theme Editor is organized into four tabs: Settings, Fonts, Objects, and Layers. The header and footer of the dialog contain controls that apply to the whole theme regardless of which tab you are on.

### Dialog Controls

- **Load From Disk** — Opens a file picker so you can load a previously saved theme file (.rglt) and replace the current project's theme with it. This is how you reuse a theme across projects or share a theme with another user.
- **Save To Disk** — Saves the current theme to an .rglt file on disk so it can be loaded into other projects. The file contains all of the theme's settings, fonts, colors, and shape definitions in a single portable file.
- **Accept** — Commits every change you have made in the Theme Editor and closes the dialog. This is the step that actually pushes your edits out to the project: every themed shape on every page is updated to reflect the new theme, so renaming a color, tweaking a default style, or editing a theme shape will instantly ripple through the entire project once you click Accept.
- **Cancel** — Closes the dialog without applying any of your changes. Nothing in the project is modified.

### Settings Tab

The Settings tab is where you define the theme's identity, color palette, and default appearance for the most common shape types. The left side of the tab holds the theme settings and default styles; the right side is the color list.

- **Name** — The display name of the theme. This is what shows up in the Theme group on the Project Tab and in any saved theme files.
- **Favicon** — The favicon image used by the demo. Click the picker to choose an image from the project. Note: the favicon set here only applies when you export the demo to HTML and host it yourself — demos hosted on Regale Cloud always use the favicon configured in the cloud, not the one set here.
- **Workspace Background** — The color shown behind the page in the editor workspace and as the letterbox color around the demo in the Web Player. Pick from a theme color or any custom color.
- **Default Beacon Style** — The starting appearance for new beacon shapes added to a page. The preview above the label shows what the current default looks like; click the Edit (pencil) button to open the Edit Shape dialog and adjust it.
- **Default Button Style** — The starting appearance for new button shapes. The preview shows the current default; click Edit to change it. In addition to seeding new buttons, this style also controls the appearance of the buttons in the Table of Contents and Help dialogs in the Regale Web Player, so editing it is how you brand those built-in dialogs to match the rest of your demo.
- **Default Dock/Stack Panel Style** — The starting appearance for new dock and stack panel shapes. Like the button style, this is also used for the panel chrome of the Table of Contents and Help dialogs in the Web Player. To change the font used in those dialogs, edit the default text inside the panel shape — the dialogs pick up its font settings.
- **Open Contrast Ratio Checker** — Opens an accessibility utility for checking text-against-background contrast ratios so you can verify your theme colors meet WCAG contrast requirements before publishing.

**Color list (right side of the tab)** — The theme's named color palette. Every color picker throughout Regale Studio (shape fills, borders, text colors, page backgrounds, etc.) pulls from this list, so changing a color here updates every shape in the project that references it — this is the central place to retheme a project's colors in one shot.

- Click any color box to open a color picker and change that color. The change ripples through every shape that uses it as soon as you click Accept.
- Add a new row to the list to extend the palette with additional colors.
- Use Get color from screen in the color picker to sample a color from anywhere on any monitor — handy for matching brand colors from a logo, screenshot, or web page.

### Fonts Tab

The Fonts tab is where you register custom web fonts for use throughout the project. Because the published or exported demo runs inside a web browser on your viewer's machine, you can't rely on viewers having any particular font installed — the Web Player needs to download the font itself. That is what the entries on this tab do: each one points the Web Player at a .woff or .woff2 file it can fetch and use to render text in the demo.

Out of the box, Regale Studio offers the standard web-safe fonts (Arial, Verdana, Times New Roman, Courier New, Georgia, Tahoma, Trebuchet MS, etc.) plus Segoe UI, all of which work without adding anything on this tab. Use the Fonts tab when you want to brand the demo with a font that isn't on that short list.

#### Where to find web fonts

Web fonts are widely available online. Some popular sources:

- **Google Fonts** — Free, open-source fonts. Note that Google Fonts' hosted CSS URLs are not always directly linkable from outside a web page; downloading the .woff2 files and hosting them with the project is more reliable.
- **Bunny Fonts** — A privacy-friendly drop-in mirror of Google Fonts.
- **Fontshare** — Free, professionally designed font families.
- **Font Squirrel** — Free fonts licensed for commercial use, with a built-in webfont generator.
- **Adobe Fonts** — Included with most Adobe Creative Cloud subscriptions (license terms apply for embedding).

If your company already has brand fonts, your design or marketing team can usually provide the .woff2 files directly.

#### Seeing the font inside Regale Studio

Regale Studio itself is a WPF (Windows desktop) application, and Windows can only render fonts that are installed locally in supported formats (.ttf, .otf, etc.). The .woff / .woff2 files you point the theme at are only used by the Web Player at runtime — WPF cannot read them directly.

That means: to see your custom font while editing in Regale Studio, you also need to install the corresponding .ttf or .otf file on your computer (right-click the file in Windows Explorer and choose Install). Without this step the demo will still publish correctly with the right font in the browser, but inside the editor the text will fall back to a default font, making layout work harder.

#### Controls

- **Add Font Family** — Creates a new named font family entry. Pick a name that matches the family name your text shapes will reference (for example, Inter or Roboto Mono).
- **Add Font Variant (one per family)** — Adds a new weight/style variant — regular, bold, italic, light, etc. — to the family. Each variant is a separate font file.
- **Path** — URL or relative path to the .woff or .woff2 file the Web Player should load for this variant.
- **Format** — The font file format (woff or woff2).
- **Weight** — Numeric font weight for this variant (e.g., 400 for regular, 700 for bold).
- **Style** — Font style (normal or italic).
- **Edit (pencil button)** — Opens a dialog to modify the variant's path, format, weight, and style.
- **Delete (trash button)** — Removes the variant from the family.

### Objects Tab

The Objects tab manages the library of reusable Object shapes in the theme. Object shapes are interactive shapes — buttons, beacons, panels, and the like — that respond to clicks or hovers in the published demo. Defining them in the theme lets you drop pre-styled, on-brand objects onto any page in one click, and lets you update the styling for every instance across the project from one place.

The tab is split into two panes: the list of theme object shapes on the left and a live preview of the selected shape on the right. Drag the splitter between them to resize.

- **New Object** — Adds a new, empty object shape to the theme. The new shape is added to the bottom of the list and selected so you can immediately rename it and open it in the Edit Shape dialog to design it.
- **Objects list** — Every object shape currently defined in the theme. The order shown here is the order the shapes appear in the Add Object dropdown on the page view's Object Shapes panel, so put the shapes you use most often near the top.
- **Drag to reorder** — Drag any list item up or down to change its position.
- **Edit (pencil button on each row)** — Opens the Edit Shape dialog for that shape. Double-clicking a list item does the same thing.
- **Right-click menu** — Standard clipboard operations on theme shapes:
  - **Copy / Cut / Paste** — Copy a shape within the list, or paste a shape copied from a page or another theme.
  - **Remove** — Deletes the shape from the theme. Any instance of the shape that has already been placed on a page is not deleted — it is automatically broken from the theme and becomes a standalone shape on its page.
- **Preview (right pane)** — A live, scaled preview of whichever shape is selected in the list. The preview updates as you make changes in the Edit Shape dialog so you can see exactly what the shape looks like.

### Layers Tab

The Layers tab manages the library of reusable Layer shapes in the theme. Layer shapes are non-interactive decoration — backgrounds, dividers, watermarks, headers, footers, and patches — that sit behind or alongside the interactive content of a page. Like theme objects, theme layers can be dropped onto any page from a single dropdown to keep the look of the demo consistent.

The Layers tab works exactly like the Objects tab — a list of shapes on the left, a live preview on the right, and the same set of controls.

- **New Layer** — Adds a new, empty layer shape to the theme and selects it so you can rename it and open the Edit Shape dialog.
- **Layers list** — Every layer shape defined in the theme. The order here drives the order in the Add Layer dropdown on the page view's Layer Shapes panel.
- **Drag to reorder** — Drag any list item up or down to change its position.
- **Edit (pencil button)** — Opens the Edit Shape dialog for that layer. Double-clicking a list item does the same.
- **Right-click menu** — Copy, Cut, Paste, and Remove, with the same behavior as on the Objects tab. Removing a theme layer breaks any placed instances from the theme rather than deleting them from their pages.
- **Preview (right pane)** — Live preview of the currently selected layer shape.

## 3. Using Theme Shapes on a Page

The Object Shapes and Layer Shapes panels in the page view are tightly integrated with the theme. You can add shapes from the theme directly, promote a one-off shape into the theme, or sever a shape's connection to the theme so it can be customized without affecting other pages. The same set of commands is available on both panels.

### Adding a Theme Shape

The Add button at the top of the Object Shapes and Layer Shapes panels is a split button. Click the main part to add a basic, unthemed shape; click the dropdown arrow to pick from any of the object or layer shapes defined in the theme. Picking a theme shape drops a new instance of that shape onto the current page, already styled to match the theme.

- **Add Object (split button on the Object Shapes panel)** — The dropdown lists every object shape defined in the theme. Selecting one drops a new themed instance onto the current page.
- **Add Layer (split button on the Layer Shapes panel)** — The dropdown lists every layer shape defined in the theme. Selecting one drops a new themed instance onto the current page.

### Telling Which Shapes Are Themed

In the Object Shapes and Layer Shapes lists, each shape has an icon next to its name that indicates whether it is linked to the theme:

- **Blue icon** — The shape is a themed shape — it is linked to a shape in the theme. Editing the underlying theme shape (or accepting changes in the Theme Editor) will update this shape automatically.
- **Black icon** — The shape is a standalone shape — it is not linked to the theme. Theme changes will not affect it.

This makes it easy to scan a page and see at a glance which shapes will follow the theme and which won't.

### Editing a Theme Shape

To edit a themed shape, right-click it in the Object Shapes or Layer Shapes list and choose Edit Theme Shape. This opens the Edit Shape dialog on the underlying theme shape — not just the placed instance. Any changes you save will ripple through every instance of that theme shape across the entire project, on every page, the next time the theme is applied.

If you only want to change the appearance of one shape on one page, don't use Edit Theme Shape — use Break from Theme first so your edits stay local.

### Breaking from Theme

Right-click a themed shape and choose Break from Theme to disconnect it from the theme. The shape stays on the page exactly as it looks now, but its icon turns black and it becomes a standalone shape that can be restyled on its own. Future changes to the theme shape it used to be linked to will no longer affect it.

This is the right command when you want a one-off variation of a theme shape on a single page without affecting any other pages.

### Adding to Theme

Right-click a standalone shape and choose Add to Theme to promote it into the theme as a new reusable shape. The shape on the page becomes an instance of the new theme entry (its icon turns blue), and the same shape can then be dropped onto other pages from the Add Object or Add Layer dropdown.

**Tip:** This works with beacon shapes too. The theme ships with one default beacon style, but you can take any beacon you've customized — changing its color, size, animation, ring style, and so on — and add it to the theme to give yourself a library of additional beacon styles to choose from across the project.

## 4. Edit Shape Dialog

The Edit Shape dialog (titled Theme Shape Editor) is the full shape designer used to author the visual definition of a theme shape. It is a modal window with its own ribbon, shape tree, and live preview, and can be opened in two ways:

- From inside the Theme Editor by clicking the Edit (pencil) button on a shape in the Objects or Layers list, or by double-clicking the shape.
- From the page view by right-clicking a themed shape in the Object Shapes or Layer Shapes list and choosing Edit Theme Shape.

In both cases you are editing the theme entry itself, not a single instance — but when those edits are pushed out to the rest of the project depends on which entry point you used. See Accepting and Cancelling below for the details.

### Layout

The dialog has four regions:

- **Ribbon (top)** — Two tabs (Home and Shapes) with all the commands for editing the shape.
- **Shape Tree (left pane)** — A hierarchical view of the shape you're editing. Unlike the Object/Layer Shapes lists on a page, the tree can only have one root item — a theme entry is a single shape, not a collection. If that root is a panel shape (Dock Panel or Stack Panel), it can contain child shapes nested underneath; if it's any other shape type, the tree is just one item.
- **Preview (right pane)** — A live, scaled rendering of the current shape against a neutral background. You can click and edit text directly in the preview, and the rendering updates as you change properties in the ribbon.
- **Accept / Cancel (bottom)** — The buttons that commit or discard your edits. Behavior differs by entry point (see below).

A splitter between the shape tree and the preview lets you resize the two panes.

### Home Ribbon Tab

The Home tab holds general-purpose editing commands that aren't specific to any shape type:

- **Undo / Redo** — Split buttons with a dropdown of the undo and redo history. The dialog has its own undo stack that is independent of the main project's undo history.
- **Add Shape** — A dropdown that adds a new shape under the currently selected panel in the shape tree. Options include Dock Panel, Stack Panel, Shape (basic styled shape), Button, Text, Text Input, and a list of the existing basic theme shapes you can drop in as children. Only panel shapes accept children, so this button is most useful when the root shape (or a descendant) is a Dock Panel or Stack Panel.
- **Font** — The standard font ribbon for editing text runs inside the shape (family, size, weight, style, color, etc.).
- **Paragraph** — Paragraph-level text formatting (alignment, list style, indentation).

### Shapes Ribbon Tab

The Shapes tab exposes most of the same controls as the Shapes Tab in the main Regale Studio ribbon, but tuned for editing a template rather than a concrete shape on a page. The groups and the important differences are:

- **Placement** — The same placement ribbon used on the main Shapes tab, but the Position (X/Y) inputs are disabled in the dialog. Theme shapes are templates — they don't live at fixed coordinates on a page — so only the Alignment, Docking, and Visibility controls apply here. Width and Height are still editable.
- **Click Action** (visible only when the selected shape supports click actions) — The same click-zone ribbon, with two differences:
  - The Hover action combo and the Hover Settings button are hidden. Hover actions don't make sense on a theme template; the shape-specific hover configuration happens on the placed instance.
  - The Variable combo only lists theme-level variables. Project-level variables are filtered out, because a theme needs to be portable across projects.
- **Display** (styled shapes only) — The full Shape Styled ribbon: fill, border, shadow, padding, corner radius, opacity, image, and so on. Exactly the same controls as on the main Shapes tab.
- **Beacon** (beacon shapes only) — The full Beacon ribbon for configuring beacon style, ring, pulse, color, and animation.
- **Dock Panel** (dock panels only) — Last Item Fills Panel toggle and an accessibility Role combo for setting the panel's ARIA role. (The Role combo is specific to the Edit Shape dialog — the main Shapes tab's Dock Panel group doesn't expose it.)
- **Stack Panel** (stack panels only) — Orientation, accessibility Role, and Vertical Scrollbar / Horizontal Scrollbar mode combos. (Like Dock Panel, the Role combo only appears here. Unlike the main Shapes tab, there are no "Set Ver./Hor. Pos." buttons, since a runtime scroll position doesn't apply to a template.)
- **Text Input** (text input shapes only) — The standard Text Input ribbon.
- **Video** (video shapes only) — The standard Video ribbon.
- **Sound** (sound shapes only) — The standard Sound ribbon.

**Note:** The Shape Accessibility tab from the main ribbon is not available in the Edit Shape dialog. Accessibility properties (label, role, description, tab order, etc.) are set on the placed instance of a shape, not on the theme template.

### Shape Tree Context Menu

Right-clicking in the shape tree provides the standard edit commands:

- **Copy / Cut / Paste** — Clipboard operations on shapes.
- **Paste Style** — Apply the style from a copied shape to the selected shape without replacing the shape itself.
- **Reset Styles** — Clear all style overrides on the selected shape.
- **Pick Image...** — Set a background image on a styled shape.
- **Check Contrast** — Run the contrast checker against the selected text shape.
- **Rename (F2)** — Rename the selected shape.
- **Remove** — Delete the selected shape from the tree. (You cannot delete the single root shape.)

### Accepting and Cancelling

The Accept and Cancel buttons at the bottom-right of the dialog behave differently depending on where the dialog was opened from:

- **Opened from the page view** (right-click a themed shape → Edit Theme Shape) — Clicking Accept immediately walks every page in the project, finds every shape linked to the theme shape you just edited, and updates it in place. Your changes ripple through the entire project as soon as the dialog closes.
- **Opened from the Theme Editor** (Edit button or double-click in the Objects/Layers list) — Clicking Accept saves your changes into the theme, but the project is not updated yet. The placed instances on pages still show the old style until you click Accept on the Theme Editor window itself, which is the step that walks the project and pushes every pending theme change out to the linked shapes (see section 2, Dialog Controls for more on the Theme Editor's Accept behavior).

In both cases, Cancel discards everything you did in the dialog and leaves the theme unchanged.

This distinction matters when you're making a lot of theme edits in one sitting: editing inside the Theme Editor lets you batch multiple shape changes together and apply them in a single, atomic operation when you finally accept the Theme Editor, while editing from the page view is a quick one-shot update for a single shape.

## 5. Tips and Best Practices

### Set Up Branding at the Start of a Project

Configure your theme — colors, fonts, default shape styles, and any reusable theme shapes — before you start building out pages. This is also when to load an existing theme file from disk if you have one: pick Load From Disk on the Theme Editor right after creating the project.

Swapping themes on a finished project is not a clean operation. The color palette and default styles will update, but any custom theme shapes that existed in the old theme won't have matching entries in the new theme, so placed instances of them will be broken from the theme and left as standalone shapes on their pages. That's rarely what you want, and fixing it by hand is tedious. Do the branding work up front and you'll avoid the problem entirely.

### Use Theme Shapes for Consistency Across Pages

Any visual element that shows up on more than a handful of pages — headers, footers, navigation bars, call-to-action buttons, branded panels, standardized callouts — is a great candidate for a theme shape. Define it once in the theme, drop it onto each page from the Add Object or Add Layer dropdown, and every instance will stay in sync. When you need to tweak the design later, one edit in the Theme Editor updates every page in the project at once.

This is also how you keep demos looking consistent as they grow. Pages built over weeks or months will drift visually if every author styles their shapes by hand; theme shapes make that impossible.

### Build New Shapes on a Page First, Then Promote Them

When you want to add a brand-new shape to the theme (rather than tweaking one that's already there), it is usually easier to build it on a page first and then add it to the theme:

1. Drop a basic shape on a page and style it using the normal ribbon controls. You get the full workspace, real background images to size against, and all the usual shape tools.
2. When it looks right, right-click it in the Object Shapes or Layer Shapes list and choose Add to Theme.

Authoring inside the Theme Editor's Edit Shape dialog works too, but it's more abstract — you're styling against a blank preview instead of a real page, and a few ribbon controls (notably Position, as covered in section 4) are disabled. Start on a page and promote when you're happy.

### Promoting Shapes Preserves Page-Level Properties

When you use Add to Theme on a shape from a page, the properties that the Edit Shape dialog doesn't let you edit — most notably the shape's position on the page — are carried along with the shape into the theme. The theme shape remembers those values, and every time you drop a new instance of that shape onto another page it lands with the same position, size, and alignment.

This is a surprisingly powerful shortcut. For example: build a footer bar at the bottom of one page exactly where you want it, then Add to Theme. From that point on, adding the footer to any page drops it at the same spot, ready to go. The same trick works for fixed headers, side panels, watermarks, and any other element that should appear in a consistent location across pages.
