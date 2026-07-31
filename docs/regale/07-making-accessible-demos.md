# Making Accessible Demos

Accessibility is a first-class concern in Regale Studio. A well-built Regale Demo can be fully navigated by users with screen readers and other assistive technologies, but only if you configure the project, pages, and shapes with accessibility in mind. This document walks through the settings that matter most, then shows how to test your demo with Microsoft Narrator.

## 1. Project Settings

Open the Project Tab to configure project-wide accessibility settings.

### Title

The Project Title is used as the browser tab title and is the first thing a screen reader reads when a demo loads. It should reflect the actual title of the Regale Demo. Avoid common filename post-fixes like dates, version numbers, or author initials — those are useful internally but confusing when read out loud.

### Language

Set the Language to the actual language of the text in the demo. This tells the screen reader which pronunciation files to load.

For example, if you view a demo that was localized to Chinese characters but left the Language set to English, the screen reader will make sounds that do not resemble Chinese at all — it's trying to pronounce each character using English phonemes.

### Country (optional)

Some languages differ by country. Use the Country field to specify the regional variant when it matters:

- Spanish — Spain (es-es) vs. Spanish — Mexico (es-mx)
- English — United States (en-us) vs. English — United Kingdom (en-gb)

Leave this set to None if the regional variant doesn't matter.

## 2. Section Settings

Each Section has a Name, which is read by screen readers every time a new page loads from that section. The name should be meaningful — either describing the theme of the section ("Checkout Flow", "Admin Settings") or something as simple as "Section One". Avoid empty, generic, or placeholder names.

## 3. Page Settings

### Page Description

The Page Description gives concise, relevant information about the screen image so screen readers can describe it to the user. A good description:

- **Does** describe what the page shows and what has changed since the previous page
- **Does** mention any interactive elements the user is expected to act on
- **Does not** describe color or pixel placement of items (those are visual details the user can't act on)
- **Does not** repeat information contained in shapes on the page that the screen reader will already read

Use the Generate button to automatically create a description using AI, but remember to edit the result to fit these guidelines — AI-generated text can be verbose and may include unnecessary visual details.

### Special consideration for the first page

On the very first page of a Regale Demo, it is helpful to set expectations: explain that this is a simulated environment containing images of the UI, that each page has a description of what is shown, and that some elements can be interacted with. This primes the user for the rest of the experience.

For more ways to add narration to a demo, see Adding a Talk Track.

## 4. Shapes

Shape configuration is where most accessibility issues are introduced or fixed. See Working with Shapes for a full overview of the shape system, and Ribbon Shape Accessibility Tab for the exact controls.

### Name

The following shape types should have meaningful names:

- Beacons
- Any other shape with a Click or Hover action
- Panels (Stack/Dock) with a Panel Role defined (see below)
- Text Inputs

When a shape represents an element in the simulated UI, name it the same as the real element. Do not include the word "button" — the screen reader automatically announces "button" for any clickable shape, so "Save button" gets read as "Save button button".

All other shapes do not have their name written out in the exported HTML.

### Size

A beacon's clickable area should match the real UI's clickable area as closely as possible. Oversized beacons can confuse users who tab onto them far from where the visible element actually is; undersized beacons make the demo hard to use with a pointer.

### Panel Role

The Panel Role applies to Stack and Dock panels and tells screen readers how to announce the container. It is set in the Shapes Tab or the Shape Accessibility Tab.

| Role | Use when |
|---|---|
| None | You don't want the panel announced as any specific container type. |
| Region | The panel contains a region of content. This is the default for Information pop-ups and when you add an empty panel to a page. |
| Navigation | The panel contains navigation links — top nav, side nav, or a home page's links to different sections. |
| Banner | The top section of an application or web page where the title and logo are found. |
| Dialog | A modal dialog (see below — this one has special rules). |
| Group | A grouping in a list of tabs or list items. |
| Listbox | A list of interactive items. Children must be marked with Item Role = Option or List Item. Allows arrow-key / Home / End navigation between items; Space or Enter triggers the item's click action. |
| Tablist | Same as Listbox, but holds items marked with Item Role = Tab. |
| Tab Panel | The contents of the currently selected tab. |
| Alert | Showing an alert prompts the screen reader to read it immediately, interrupting whatever the user was doing. Use only for dynamic content that appears after an interaction, contains only text, and has no click actions or links. |

#### Special rules for Dialog panels

A Dialog has extra behavior and should be the only panel of its kind on the page:

- The dialog should contain a Heading shape that will be used as the dialog's accessible title.
- The dialog must contain at least one button (a clickable shape) used to navigate or otherwise close the dialog.
- The first button gets focus automatically when the page/dialog loads.
- Note: don't place a dialog on the first page of a demo if it will be embedded into another web page — focus will land on the first button in the dialog instead of the page content, which can be confusing.
- Pressing the Esc key performs the click action assigned to the first button in the dialog.

### Heading

Marking a text shape as a Heading (H1, H2, etc.) helps screen reader users understand the document layout. Users can request a list of headings to jump around the page. The Heading setting is in the Display group of the Shapes Tab.

Only set Heading on shapes that contain text. A heading should always be one of the first elements inside a shape with Panel Role = Dialog.

### Item Role

Item Role applies to any shape (not just panels) and is set in the Placement group of the Shapes Tab.

| Role | Use when |
|---|---|
| None | The item has no specific role. |
| List Item | The item is part of a list. The parent shape should be a Listbox panel, and the shape should have a click action assigned. If it represents the currently selected item, toggle Is Selected on. Use a "Set Variable" action with no variable set if you need a no-op click. |
| Option | Same as List Item — used for choices in a combo (dropdown) box. |
| Tab | Same as List Item — used inside a Tablist panel. |
| Alert | Prompts the screen reader to read the item immediately. Use only for dynamic content after an interaction, text only, no click actions. |

### Color and Contrast

For text shapes, the contrast ratio between the text color and the background color should be at least 4.5:1. Use the Contrast Ratio tool in the Home Tab Accessibility group to measure any pair of colors.

For interactive elements (buttons, links, etc.), avoid relying on color as the only distinguishing feature between the element and its background. For example, a red button on a green background with no border is a problem for users with color blindness.

The contrast ratio between a beacon and the background it sits on should be at least 3:1 across a reasonable portion of the beacon (it doesn't have to hit 3:1 over 100% of the beacon's area).

### Font Size

Demo content is scaled to fit the browser window by default, so the font size you see in Regale Studio on your monitor is not what the end user will see on theirs. A good rule of thumb for an effective 16pt display:

| Authoring monitor | Target font size |
|---|---|
| 1080p | 18 pt |
| 1440p | 28 pt |
| 4K+ | 45 pt or more |

### Screen Reader Visible

Sometimes you want a shape to be hidden from the screen reader to avoid confusion — for example, background decoration that isn't interactive and doesn't need to be read aloud. Turning Screen Reader Visible off in the Shape Accessibility Tab removes the shape from the accessibility tree.

Turning this off on a Panel shape also hides all of the panel's children from the screen reader, regardless of the children's own settings.

### Order

The order of shapes in the Object pane is important — it is the order they are rendered to the screen and the order a screen reader will walk through them. For accessibility, shapes should be ordered top-left to bottom-right, matching the visual reading order. When tabbing through clickable shapes, focus should follow a logical direction and not jump around the page.

### Text Padding

Some users adjust the text spacing values in their browser away from the default, which can cause scrollbars to appear next to text shapes. Adding a little padding to your text shapes gives the scrollbar room to sit without clipping the content.

## 5. Testing Your Demo with Microsoft Narrator

The best way to verify a demo's accessibility is to test it yourself with a screen reader. Microsoft Narrator ships with Windows and is the fastest way to get started.

### Starting Narrator

Press Ctrl + Win + Enter to toggle Narrator on and off. The first time you run it, Narrator will offer a brief tutorial — you can skip it or walk through it if you've never used a screen reader before.

Narrator uses a dedicated modifier key called the Narrator key, which defaults to Caps Lock (or Insert). All of the shortcuts below assume Caps Lock as the Narrator key.

### A suggested testing workflow

1. Preview or export the demo to HTML and open it in a browser.
2. Turn Narrator on (Ctrl + Win + Enter). Narrator should immediately read the browser tab title, which is your Project Title.
3. Move focus into the page content with Caps Lock + N (jump to the main landmark) or Caps Lock + Home (jump to the first item).
4. Start continuous reading with Caps Lock + Down Arrow. Narrator will read the Page Description first, then walk through each shape on the page in order. Stop reading at any time with Ctrl.
5. Tab through the interactive elements to hear each beacon, button, list item, etc. announced with its name and role. Verify that:
   - Every clickable shape has a meaningful name.
   - Beacons announce the same label as the real UI element they represent.
   - No shape announces "button button" (which means the word "button" was included in its name).
   - The tab order moves logically across the page rather than jumping around.
6. List the landmarks (Caps Lock + F5) to see the banner, navigation, region, dialog, etc. panels you configured. If something you expected is missing, double-check its Panel Role.
7. Trigger any interactive element with Enter (or Space on a list item). Make sure the new page's description and content read sensibly.
8. Test any Dialog panels by navigating to a page that shows one. Confirm:
   - The dialog's Heading is announced as the title.
   - Focus lands on the first button automatically.
   - Pressing Esc closes the dialog (or triggers the first button's action).

### Useful Narrator shortcuts

| Shortcut | Action |
|---|---|
| Ctrl + Win + Enter | Toggle Narrator on/off |
| Caps Lock + N | Move to the main landmark |
| Caps Lock + Home | Move to the first item on the page |
| Caps Lock + F5 | List landmarks |
| Caps Lock + F6 | List headings |
| Caps Lock + Right Arrow | Move to the next item |
| Caps Lock + Left Arrow | Move to the previous item |
| Caps Lock + Down Arrow | Start continuous reading |
| Ctrl | Stop reading |
| Tab / Shift + Tab | Move between interactive elements |
| Enter | Activate the selected link or button |
| Space | Activate a selected list item |
| Caps Lock + Spacebar | Toggle Scan Mode |

**Note:** Regale Demos do not contain traditional HTML headings for every piece of text, so Caps Lock + F6 (List headings) may return few or no results. That's expected — use Caps Lock + F5 (List landmarks) to get the structural overview instead.

### About Scan Mode

Scan Mode is an alternate Narrator mode for web pages that lack good accessibility support — it lets you read through a document with the arrow keys regardless of focus. You do not need Scan Mode for a well-built Regale Demo, because all the interactive elements are in the accessibility tree and tab-navigable natively. If you find yourself needing Scan Mode to get around a demo, that's a signal something is missing — usually a shape without a name, an incorrect Panel Role, or shapes in the wrong order.

## 6. How Real Screen Reader Users Navigate a Demo

Screen reader users don't read a page top to bottom the way sighted users visually scan it. Understanding their patterns helps you build demos that work well for them.

### First impression

When a user opens a Regale Demo, their screen reader reads the browser tab title (your Project Title) immediately, then announces the page's landmarks and begins reading the current page. This is why setting a meaningful Project Title and a clear first-page description is so important — it's the user's entire introduction to the demo.

### Building a mental model

Experienced screen reader users quickly orient themselves by asking the screen reader for structural information:

- **"What landmarks are on this page?"** (Caps Lock + F5 in Narrator) — this lists every panel with a Panel Role set, so users can jump straight to the banner, navigation, main content, or dialog. This is why setting Panel Role on top-level panels matters so much.
- **"What interactive elements are here?"** — users tab through the page to hear every clickable shape announced with its name and role. If you have twenty shapes on a page but only three are interactive, the user will get through them in three tabs.
- **"Read me everything on this page"** (Caps Lock + Down Arrow) — users start continuous reading to hear the Page Description followed by all the text and shape content in order.

### Navigating within a page

Once oriented, users typically:

1. Tab between interactive shapes to find what they want to act on.
2. Use arrow keys inside Listbox or Tablist panels to move between items (this is why Item Role matters — it enables arrow-key navigation).
3. Press Enter or Space to trigger the click action on the focused shape.
4. Listen for Alert shapes that appear dynamically, which interrupt whatever they were doing to announce new information.

### Navigating between pages

When the user activates a shape that advances the demo to a new page, the screen reader:

1. Announces the new section name (if the page is in a new section).
2. Reads the new page's description.
3. Walks through the new page's landmarks and content.

This means each page should feel self-contained from a narration standpoint. Don't rely on the user remembering context from the previous page — write descriptions that make sense on their own.

### Common frustrations to avoid

- Unnamed clickable shapes announce as "button" with no label, which is meaningless.
- Too many landmarks (every panel set to Region, for example) produces a long, noisy landmark list. Reserve roles for panels that genuinely serve that structural purpose.
- Misordered shapes force users to tab back and forth across the visible page, making it exhausting to navigate.
- Dialogs without a close button trap the user on the page.
- Alerts used for static content speak over whatever else the user was listening to and break their flow.

If you test your own demos with Narrator regularly, you'll catch most of these before they reach real users.
