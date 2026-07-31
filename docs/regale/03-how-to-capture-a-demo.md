# How to Capture a Demo

This guide walks you through the full workflow for creating a polished interactive demo in Regale Studio, from initial capture through to final cleanup and interactivity.

Regale Studio can capture two kinds of pages, and a single demo can mix them freely:

- **Image pages** — captured by recording your screen as you click through a real application. This is the classic workflow and the subject of most of this guide (sections 1–9 below).
- **HTML pages** — captured from a live web page using the built-in HTML Capturer. The page is saved at full fidelity and stays responsive in the player. See Capturing HTML Pages just below.

## Capturing HTML Pages

**Beta.** HTML capture and HTML pages are a Beta feature in Regale Studio 5.0 — fully usable and ready for real demos, but still being refined, so some behavior may change in future releases. The HTML Capturer window is titled "Regale Html Capturer (Beta)" to reflect this. We'd love your feedback.

Instead of recording your screen, you can capture a live web page directly. The result is a real, offline copy of the page that renders at full fidelity and — unlike a screenshot — reflows to fit the player instead of breaking when the layout shifts. Use it whenever your demo walks through a real web product (a SaaS dashboard, SharePoint, Teams, an Azure blade, your own web app).

### Capturing a page

1. On the Home ribbon tab, click Html (the Capture Html group) to open the HTML Capturer — a built-in browser window.
2. Navigate to the page you want, signing in and clicking through to the exact state you want to capture (the capturer is a real browser, so cookie banners, sign-in, and in-app navigation all work).
3. Click Save Capture to add the current page to the section as a new HTML page.

The capturer pulls down everything the page needs to render offline — the HTML (with scripts and tracking pixels stripped), every linked stylesheet, font, and image (including CSS background images), stylesheets attached via adoptedStyleSheets, the contents of iframes and shadow DOM, and the current scroll position of the page and of any scrolled panels. The page that lands in your demo looks pixel-identical to the live site at the moment of capture.

### Capture profiles: sign-ins, credentials, and favorites

The capturer is a real browser, so it stays signed in between sessions — but you often build demos across several environments or personas: a Microsoft 365 admin tenant, a couple of end-user accounts, a Google Workspace, your own app's staging site. Signing in and out of each, or clearing cookies to switch, gets old fast. Capture profiles fix this: each profile is its own isolated browser identity, with its own cookies, cache, and sessions. Stay signed into all of them at once and switch between them instantly.

Every capturer starts on the built-in Default profile (which keeps the cookies you already had). The profile button on the toolbar — a person icon showing the current profile's name — lists your profiles; pick one to switch in place: the page reloads under that profile's cookies, so you land wherever that identity is signed in. Because each profile is fully isolated, switching never signs you out of the others.

Open Manage Profiles… from the profile dropdown to create, rename, and delete profiles. Each profile also keeps two things of its own:

- **Stored credentials** — a list of sign-ins for that environment (label, URL, username, password). Passwords are encrypted at rest (Windows DPAPI, tied to your Windows account) and shown masked. Click the eye to reveal one, or copy the username or password to paste into a sign-in form — the clipboard clears itself after about 30 seconds so a copied password doesn't linger. Regale doesn't type passwords into pages for you; you paste them, so you stay in control of every sign-in.
- **Favorites** — the pages you keep returning to for that persona (an admin console, a specific demo tenant). Add the current page with the star button on the toolbar (it fills gold once the page is a favorite), and jump to any saved favorite from the dropdown arrow beside it. Favorites are per-profile, so each persona gets its own shortlist; you can also edit them in the Manage Profiles window.

Deleting a profile also deletes its browsing data, so its cookies and cache are removed from disk.

**Switching starts a fresh browser session.** A profile switch reloads the current page under the new profile. Sites that keep you signed in with a normal (persistent) cookie — Microsoft, Google, most SaaS — come back already signed in. A site that stores its sign-in only for the session (a session cookie or in-page storage) will ask you to sign in again after a switch, exactly as it would in a brand-new browser window. That's the site's choice of sign-in, not a lost profile.

**Automation.** Capture profiles, favorites, and credentials are also available to AI agents over the MCP server — an agent can list and switch profiles, manage favorites, and save credentials while setting up a multi-environment capture. Reading a stored password back is a separate, off-by-default permission.

### Size Mode

Each HTML page has a Size Mode that controls how it's sized during playback. Set it in the capturer when you capture, or afterward on the Page ribbon tab:

- **Fixed Size (default — 1080p)** — the page renders at its captured resolution and scales uniformly to fit, just like an image page (letterboxing on an aspect-ratio mismatch). This is the default because it captures a stable, known-good layout for every site — including apps whose JavaScript-driven layout freezes once the scripts are stripped at capture (some single-page apps, e.g. Teams, bake in pixel heights that can't reflow, so they'd otherwise show empty space below their content). You can switch any captured page to Responsive afterward.
- **Responsive** — the page fills the player and reflows like a real web page. Best for sites that lay out fluidly; switch to it after capturing if the page holds up.

When you choose Fixed Size in the capturer, a resolution picker appears with standard sizes (1080p, 1440p, 4K, a 3:2 Surface Pro, and phone presets for mobile-specific captures), plus a Custom width × height. The capturer renders the page at that resolution, fit-scaled into the window — so you can capture a clean 1080p, 4K, or phone view without resizing the window or owning that monitor (phone presets also turn on touch and the mobile layout). Recapture ("Open in Capturer") reopens the capturer in the page's captured view, so re-capturing a page starts from the same setup.

**Tip:** Some sites have to be captured at Fixed Size — their JavaScript-driven layout doesn't survive capture and only holds together at the resolution it was captured at. You can't tell in advance, so the safe order is: capture Fixed Size first, then switch the page to Responsive (on the Page tab) and check whether it still holds up. Switching that direction is just a setting toggle. Going the other way is not: if you capture Responsive and it turns out the site needed Fixed Size, the page was captured wrong and you'll have to recapture it — the switch alone won't fix it.

### Editing a captured page

Once a page is captured, select it and use the HTML tab in the right-side panel — or right-click any element in the workspace — to refine it: select and inspect elements, edit text in place, edit an element's HTML, swap an image (on one page or everywhere it's reused), animate a text field typing itself out, save or clear a scroll position, and hide or delete elements. To edit the whole document, use Edit Page HTML on the Page ribbon tab. See the HTML Tab reference for the full set of tools.

Beacons and other shapes work on HTML pages just as they do on image pages, except that on an HTML page a shape is anchored to an element rather than placed at fixed coordinates, so it stays aligned as the page reflows or scrolls.

### Saving scroll positions

A live web page remembers how far you've scrolled while you use it, but a saved snapshot has no such memory — so without help a captured page would reopen scrolled back to the top, often showing different content than what was on screen when you captured it (a chat thread jumps to its oldest messages; a long list resets to the first row).

Regale handles this for you: the capture records the scroll position of the page and of every scrolled panel (chat threads, sidebars, lists) and reapplies it on load — in the workspace, the exported demo, and the Web Player alike. Capture a page part-way down and it reopens exactly where you left it.

You can also set it yourself after capture. Right-click the page — or a specific scrollable panel — in the workspace (or use the HTML tab) and choose:

- **Save scroll position** — pin that area to wherever it's currently scrolled, so the page reopens there.
- **Clear scroll position** — let that area open at the top again.

Each is a single Ctrl+Z undo step. Scroll positions are saved per element, so you can pin a sidebar and the main page independently.

### A capture is a snapshot, not a working app

A captured HTML page is a picture of one moment — the live site's JavaScript is stripped at capture. The page keeps its exact look (HTML, CSS, images, fonts), but it does not keep its behavior: dropdowns, menus, filters, search boxes, forms, and anything else driven by the page's own scripts no longer function on their own.

This is the most common point of confusion. HTML capture is not a way to clone a web app and have it keep working offline. If you capture, say, a live dashboard hoping its filters and buttons will still respond, they won't — the scripts that made them work are gone. Capture is for building a demo of a UI, not a working copy of it.

You build interactivity the Regale way instead: capture each state as its own page (the closed menu, then the open menu; the empty form, then the filled-in result) and link them with beacons and click actions. The result feels interactive to your audience even though no live code is running. Or, to show motion rather than discrete states, record a page build (next).

### Recording HTML page builds and animations

**Beta.** Build recording is part of the Beta HTML Capture feature and is still being refined.

A plain capture freezes one moment. To capture motion on an HTML page — content staggering in as a page loads, an upload progress bar filling, or an AI assistant writing a response over several seconds — record a build. A build stores the page's starting state (a baseline) plus a timeline of the timed changes that play it forward into the final captured page.

Record a build — it works just like recording your screen, but for a live web page:

1. In the HTML Capturer, navigate to the page and let it settle.
2. Click Record on the capturer toolbar (a red dot and elapsed timer appear).
3. Drive the interaction — submit a prompt, start an upload, expand a panel, or click through a multi-step flow.
4. Click Record again to stop. Every page you captured is added to your project automatically — no separate save step. (To throw a recording away instead, close the capturer without stopping.)

As you record, each click starts a new page — automatically dropping a themed interactive hotspot on the element you clicked, wired to advance to the next page — and each page you navigate to becomes a new page too, capturing its load animation as that page's build. So clicking through a wizard becomes a whole linked sequence of pages in one pass. A recording where you never click or navigate is simply a single page. Whatever animates on a page (content staggering in, a progress bar, an AI response streaming) is recorded as that page's build.

The captured pages show their final state everywhere as usual (workspace, editing, export); each build simply plays once when a viewer enters the page during playback. A click skips to the final state, and viewers who prefer reduced motion see the final state immediately.

**Editing the build timing.** When a page has a build, a build timeline bar appears above the page in the workspace — a video-editor-style strip. Transport buttons jump to the start, play/pause, and jump to the end, and a speed control speeds the whole build up or down. Drag the ruler to scrub the playhead. The track below shows each segment (a burst of activity) as a block with the idle gaps between them: click a block to select it (Ctrl/Shift for several) and set how long it plays (in seconds) — down to a brief fraction of a second — or Collapse it (drop it to a single instant right after the previous block); click a blank gap to shorten the dead air, or trim the lead-in before the build starts (handy for the "assistant thinks, then answers" pause). The end of the build is marked, and the trailing dead-air after the last block is hatched so it's clear where the animation ends. If a recording picked up scrolling you don't want in the animation, tick Strip scroll to drop all scrolling from playback (the page stays put; anything the scrolling loaded still appears), or select a block and click Remove to take a whole action out — the block stays on the track as a small dashed marker, so you can select it again and Restore it any time. Reset timing puts everything back. These edits are non-destructive: the recording itself is never altered, so you can retime freely and undo. Whether a build auto-plays on entry is a per-page setting.

**Automation.** Build recording, retiming, and playback are also available to AI agents over the MCP server, and retiming/removal (but not recording, which needs a live browser) is available headlessly in the rglx CLI.

**Current limits (Beta):** the click→page-load transition itself isn't captured (the new page starts fresh at its loaded state). An embedded frame from another site (a cross-origin iframe, e.g. an embedded app) can't be recorded from the inside — it appears in the build fully rendered at the moment it appeared live, rather than progressively.

## 1. Preparing Your Machine for Capture

A few minutes spent prepping your machine before you record will pay off in a much cleaner, more professional-looking demo.

### When Capturing the Full Desktop

- **Clean up the Windows taskbar** — Hide the date/time, network, weather, search box, and other system tray widgets. Unpin apps you don't need so the taskbar isn't a distraction in the final demo.
- **Close unnecessary apps** — Shut down anything not part of the demo, including chat clients, email, and notification sources, so they can't pop up mid-capture. Regale Studio automatically hides itself while recording, so you don't need to worry about it appearing in your captures.

### When Capturing a Browser App

- If the demo doesn't require switching tabs, press F11 to put the browser into full screen mode. This hides the tabs, address bar, and bookmarks, giving you a clean capture surface with no browser chrome.
- Set the capture area to Active Application (see the next section) so only the browser content is recorded, not the desktop or taskbar behind it.

### Screen Resolution

Regale Studio captures at the monitor's native resolution. The right resolution is a trade-off between file size, playback performance, and visual sharpness:

- **1920×1080 (1080p)** — Smallest save files and HTML exports, fastest playback in the Web Player. Can look fuzzy on high-resolution displays such as 4K monitors or Microsoft Surface devices.
- **3840×2160 (4K) and above** — Crisp on high-resolution displays, but save files are much larger and animations take longer to download/buffer in the Web Player, especially on slow internet connections.
- **2560×1440 (1440p)** — A good middle-ground for most demos: sharper than 1080p without the file-size and download cost of 4K.

Pick the lowest resolution that still looks good on the displays your audience is likely to use.

## 2. Selecting a Capture Area

Before you start recording, choose what part of the screen to capture using the Area dropdown in the Home Tab Screen Capture group.

- **Specific Monitor** — Select a monitor to capture the entire screen.
- **Active Application** — Captures only the currently focused application window, ignoring everything else on screen.

## 3. Choosing a Capture Mode

Select your capture mode using the Mode dropdown in the Screen Capture group. Each mode is suited to different scenarios:

### Continuous Mode

Continuous mode captures the screen continuously at a fixed frame rate, similar to how Camtasia or other screen recording tools work. If you're used to traditional screen recorders, this will feel familiar — start recording, perform your actions naturally, and Regale Studio captures everything as it happens.

Unlike Single mode, you don't need to wait between actions. Recording starts immediately when you toggle Record on and keeps capturing frames until you stop it or switch capture modes. Each subsequent click during the recording splits the captured frames into a new page, so the natural rhythm of clicking through a UI produces a sequence of pages without any pauses.

Use Continuous mode when:

- You want a natural, Camtasia-style workflow without having to pause between steps.
- You need to capture animations, loading indicators, transitions, or motion of any kind.
- You want to record natural typing — Continuous mode captures each keystroke as it appears, producing a more realistic typing animation than Typing mode.
- You are capturing dropdowns opening, menus expanding, or tooltips appearing.

Recording stops when one of the following happens:

- You press Esc (if Stop on ESC is enabled).
- The Max Sec duration is reached (if Max Sec is enabled).
- You switch the capture mode to Single or Typing.
- You toggle the recording session off with Ctrl+Alt+S.

Configure Frames/Sec for capture frequency and Max Sec to optionally cap the recording duration. For most UI animations, 4 to 8 FPS is the ideal trade-off between smoothness and animation size. Higher frame rates produce smoother results but create larger files and can increase page load time in the Web Player. Save FPS values higher than 12 for when you need to capture very fast motion or subtle transitions.

Skip Idle Frames is especially valuable in Continuous mode. When enabled, Regale Studio watches for stretches where nothing on screen has changed and, after the configured delay, stops adding new frames until something moves again. This means you can let the recording run while you pause to think, read, or wait for an application to respond — those idle stretches won't bloat your page with redundant frames, and you won't have to manually delete them later. The delay value controls how long the screen must stay still before frames start being skipped, so you can tune it to ignore brief pauses while still trimming longer ones.

### Single Mode

Best for capturing static screens with deliberate click-by-click navigation. Each mouse click or Print Screen press captures one image. Use this when:

- You are clicking through a UI step by step.
- Each screen state is a distinct page in your demo.
- You want full control over exactly when each capture happens.

### Typing Mode

Best for capturing keyboard input where each keystroke triggers a new frame. Recording continues until you press Esc or click the mouse. Use this when:

- You want to show text being typed into a form field.
- You need one frame per keystroke for precise control.

**Tip:** For more natural-looking typing, consider using Continuous mode instead of Typing mode. Continuous mode captures the actual screen timing of keystrokes, which looks more realistic when played back.

**Tip:** Regardless of which mode you use, you can smooth a typing animation by manually deleting frames so that letters appear in groups rather than one at a time. This gives the typing a more natural rhythm and reduces the total frame count. This is especially valuable with Typing mode, where each keystroke produces its own frame — grouping letters together avoids an unnaturally even, mechanical pace.

## 4. Capturing the Demo

### Starting a Recording Session

1. Click Record in the Quick Action Bar or press Ctrl+Alt+S to begin recording.
2. Switch to the application you are demonstrating.
3. Perform the actions you want to capture.
4. When you're done, press Ctrl+Alt+S again to stop the recording session.

**"Regale Studio disappeared!"** While a recording session is active, Regale Studio hides itself — including its taskbar button — so the app window can't end up in your captures. This is expected, and it's most surprising when you're recording on a single monitor, where the whole window seems to vanish. It isn't gone. To stop recording and bring Studio back, do either of these:

- Press Ctrl+Alt+S (the recording toggle works even while Studio is hidden), or
- Click the Regale Studio icon in the Windows system tray (the notification area at the far right of the taskbar) — clicking it stops the recording and restores the window.

### Pacing Your Clicks

How you pace clicks depends on which capture mode you are using.

In Single mode, wait for Regale Studio to finish processing each capture before performing the next click. After each click, Regale Studio captures the screen and creates a new page — you can see this happening in the Pages List. If you click again while a capture is still being processed, the new click will not create a separate page. Wait until the new page appears in Regale Studio before moving on. This also means you should wait for the application you are demonstrating to finish loading or transitioning before clicking; otherwise you may capture a page that is still rendering, resulting in incomplete or blurry screenshots. Let the UI settle, then click.

In Continuous mode, you can click at a natural pace — there is no need to wait between clicks because the screen is being captured continuously. Each click marks the boundary between pages, splitting the ongoing recording into a new page. This is the same workflow you'd use with Camtasia or any other continuous screen recorder.

**Note:** Sometimes you may want multiple clicks to land on the same page — for example, when the demo doesn't need to replicate every exact click and you'd rather combine several steps into a single page, or when you plan to use the Shape system to create menus that open on click. To do this, you can simply trim and merge the pages afterward in the Pages List.

### Using Keyboard Commands for Manual Captures

You can use Print Screen or Ctrl+Alt+C to trigger a capture without clicking. These shortcuts behave the same as a mouse click — they start a capture in whatever mode is currently selected (a single image in Single mode, a frame sequence in Continuous mode, or a typing session in Typing mode).

This is useful for:

- Breaking on non-click interactions where you still want a separate page in the final demo
- Isolating UI features that don't require a click to trigger, such as hover states, or scrollable regions, so you can later turn them into Shapes
- Capturing hover states — Press print-screen to start a new page, hover over each item, then press print-screen again to continue capturing the demo.
- Capturing scrollable regions — Same as above, but perform the scroll, then press print-screen again to continue.
- Breaking a long sequence into smaller pieces, so it is easier to edit later.

### Switching Modes During Recording

You can switch between capture modes on the fly using the Mode dropdown in the Home Tab or with keyboard shortcuts:

| Shortcut | Mode |
|---|---|
| Ctrl+Alt+1 | Single |
| Ctrl+Alt+2 | Continuous |
| Ctrl+Alt+3 | Typing |

This is useful when you need a Continuous capture for one part of the demo (e.g., a loading spinner) and single captures for the rest.

Switching out of Continuous mode will stop the current recording session.

## 5. Cleaning Up Animations

After a Continuous capture, you will typically have more frames than you need. Use the Animation Bar and Page Tab tools to tighten up your animations.

### Remove Duplicate Frames

Click Remove Duplicates in the Page Tab's Images group. When two side-by-side images are exactly the same, this removes one of them and continues checking against the next image. This is a good first pass to drop unnecessary frames from Continuous captures where nothing changed on screen, but isn't needed if you were using Skip Idle Frames during recording, since that setting automatically prevents redundant frames from being captured in the first place.

### Manually Remove Frames

Select unwanted frames in the Animation Bar and press Delete (or right-click and choose Remove). Use this to:

- Remove frames where the screen was mid-transition or partially rendered.
- Trim the beginning and end of a Continuous capture.
- Remove frames that add no visual value to the animation.

**Tip**

You can select a frame and hold shift while using the left/right arrow keys to select multiple frames at once, then delete them all together.

The main workspace will automatically update to show the last selected frame, so you can see what the animation looks like as you select.

### Use Loop Mode for Small Repeating Animations

For small, repeating animations like progress indicators, blinking cursors, or pulsing elements, set the animation type to Loop in the Page Tab's Animation group.

With Loop mode, you only need a few frames — the animation plays forward repeatedly, creating a continuous effect with minimal images that plays until the demoer advances the demo.

### Split Animations Across Pages

When using only Images for animations, you can split a long animation across multiple pages to improve performance - this isn't needed when using Auto or Video mode in the export settings.

1. Select the images you want to split into a new page in the Animation Bar.
2. Right-click and choose Convert To Page to move the selected frames onto a new page (inserted right after the current page), or Split Page (shortcut /) to move the selected frame and every frame after it onto a new page while earlier frames stay put.

## 6. Making Patches

Patches are Layer Shapes placed over parts of an image to cover, replace, or modify specific areas. Use patches to hide unwanted UI elements, correct visual artifacts, or create dynamic content.

**Warning:** Don't place patches in the Objects group, these are interactive shapes drawn at runtime and do not modify the underlying image and might allow the user to see the unwanted content underneath.

### Covering Areas with Layer Shapes

To cover an unwanted area of an image or animation (such as a username, date, or watermark):

1. In the Layer Shapes pane, click Add Layer and choose Blank Shape.
2. Position and resize the shape over the area you want to cover using the Shapes Tab Placement controls.
3. Set the shape's fill color to match the surrounding area.

### Matching Colors with the Eyedropper

To get an exact color match for a solid-color patch:

1. Select the shape and open a color picker (e.g., the fill color in the Display group).
2. Click the eyedropper button ("Get color from screen").
3. Move your mouse anywhere on the screen and click to pick up the exact color from the underlying image.

This ensures your patch blends seamlessly with the background.

### Creating Image Cutouts

To create a "cutout" — a cropped portion of the background image that can be repositioned or animated:

1. In the Main Workspace, drag a selection rectangle over the area you want to copy.
2. Tip after drawing a selection, you can resize and move it using the mouse to get a precise crop.
3. Press Ctrl+C or right-click the selection and select Copy to copy the selected region.
4. Press Ctrl+V or right-click the workspace and select Paste to paste it as a new image element.

Cutouts are useful for creating patches that include complex textures or gradients that a solid color shape cannot replicate.

### Controlling Shape Visibility Per Frame

To make a shape visible only on specific animation frames:

1. Select the shape(s) you want to control visibility for.
2. Open the Shape Tab and in the Animation dropdown in the Placement group, select Custom.
3. Expand the Animation Bar by clicking the expand button.
4. In the expanded view, each image column shows all custom animation shapes on the page.
5. Click a shape in a specific frame column to toggle its visibility for that frame.
6. Shapes hidden on a frame appear faded (reduced opacity) and highlighted in gray.

This allows you to show a patch on some frames but not others — useful when different frames need different corrections.

### Blending with Transparency

To blend a cutout or patch during a fade-in or window transition, you have two options:

- **Shape Opacity** — Select the shape and adjust the Opacity slider in the Shapes Tab's Display group (range: 10% to 100%). This controls the transparency of the entire shape, including its content and border. Use this when you want the whole patch to fade uniformly.
- **Fill Color Transparency** — Open the shape's fill color picker and adjust the alpha channel. This makes only the background fill semi-transparent while keeping borders and other style elements opaque.

Combine either approach with per-frame visibility to fade a patch in or out across animation frames.

## 7. Making Hover Effects

Hover effects allow shapes to appear or change when the user moves their mouse over a specific area in the exported simulation. These are commonly used to show tooltips, dropdown menus, button highlights, and other interactive states.

### Continuous Capture Workflow

The preferred method when capturing a whole demo at once, including the hover states. This allows you to capture the hover states in context, ensuring they are perfectly aligned and visually consistent with the rest of the demo.

1. **While recording** — hover over each UI element you want to create a hover effect for, they will be captured in the animation as separate frames.
2. **Clean up the animation frames** — After recording, go through the animation frames and make sure you have a clear "base" frame (no hover) and one image for each hover state. Delete any frames that are mid-transition or partially rendered.
3. **Select the area** — In the Main Workspace, drag a selection rectangle around the area where the hover effects appear. This defines the region that will be used for comparison.
4. **Select the animation frames** — In the Animation Bar, select the frames that contain the hover states you want to extract. The first selected frame is treated as the base (no hover state), and all subsequent selected frames contain the hover states.
5. **Create the hovers** — Right-click on the selected frames and choose Create Hover Effects > From Selection. (Use From Full Page if you want to compare the entire page rather than a specific selection.) The tool will:
   - Compare each subsequent frame to the base frame.
   - Detect the visual differences.
   - Create beacon shapes (click/hover zones) and image shapes (hover visuals) for each difference.
   - Group each pair into a "Hover Effect" canvas.
   - Remove the animation frames from the animation.

Note: the newly created hover shapes will only be visible on the last frame of the animation.

### Single Image Workflow

Use this method when you have already captured your demo and want to add hover effects afterward.

1. **Capture the hover states** — While recording in Single capture mode, use Print Screen or Ctrl+Alt+C to capture each hover state as a separate screenshot. You should have one "base" screenshot (no hover) and one or more screenshots showing the hover states.
2. **Select the area** — In the Main Workspace, drag a selection rectangle around the area where the hover effects appear. This defines the region that will be used for comparison.
3. **Select the pages** — In the Pages List, select all the pages involved:
   - The first selected page is treated as the base (no hover state).
   - All subsequent selected pages contain the hover states to be extracted.
4. **Create the hovers** — Right-click on the selected pages and choose Create Hover Effects > From Selection. (Use From Full Page if you want to compare the entire page rather than a specific selection.) The tool will:
   - Compare each subsequent page to the base page.
   - Detect the visual differences.
   - Create beacon shapes (click/hover zones) and image shapes (hover visuals) for each difference.
   - Group each pair into a "Hover Effect" canvas.
   - Remove the extra pages, keeping only the base page with the new hover shapes.
5. **Rename and describe shapes** — After creation, rename each hover shape to describe the UI element it represents (e.g., "Settings Menu Hover", "Submit Button Highlight"). This is important for accessibility — screen readers will announce the shape name to users navigating the simulation with assistive technology.

### Tips

- Make sure the selection area is precise — it should cover only the region where hover states differ.
- For animations with hover states, capture the hover states as separate pages (single screenshots), not as additional animation frames.

## 8. Making Scroll Effects

Scroll effects simulate scrollable content regions in the exported simulation. The workflow is similar to creating hover effects.

### Creating a Scroll

1. **Capture the scroll states** — Record the content at different scroll positions. Each scroll position should be a separate screenshot or animation frame.
2. **Make a precise selection** — In the Main Workspace, drag a selection rectangle around the scrollable content area. Be precise — the selection must not include non-scrolling elements (like a fixed header or navigation bar) or the original scrollbar. Only select the content that actually scrolls.
3. **Select the source material** — Select the pages (in the Pages List) or images (in the Animation Bar) that contain the different scroll positions.
4. **Create the scroll** — Right-click on the selected pages or images and choose Create Scroll Shape, then select either:
   - **Vertical Scroll** — Combines the selected area across the selected pages/images into a single vertically scrollable image.
   - **Horizontal Scroll** — Combines the selected area into a single horizontally scrollable image.
5. **Adjust the scroll** — The Scrollable Creation Review Dialog will open, allowing you to fine-tune the alignment of the captured images and adjust the scroll behavior.
6. **Position the scrollbar** — Adjust the width of the scroll container to move the scrollbar to the correct position, aligning it with where the original scrollbar was in the captured screenshots.
7. **Cover the old scrollbar** — Add a Layer Shape over the original scrollbar in the background image to hide it, since the simulation will render its own scrollbar.

### Fixing a "ghost image" flash on page transitions

A scroll shape is an Object, so it's drawn on top of the page's background image — and the background image behind it still shows the content in its original position (scrollbar at the top). If the scroll shape is scrolled part-way down, the two disagree: the object shows the scrolled view, the background underneath shows the top.

You won't notice this while the page sits still, but during a page transition the objects are briefly hidden while the images cross-fade — so for a split second the un-scrolled background shows through, and it reads as the content jumping back to the top and then snapping down again ("ghosting").

The fix is to make the background image match the scrolled state, so there's nothing different to flash:

1. Scroll the scroll shape to the position you want the page to open at.
2. Right-click the workspace and choose Copy Image with all Shapes — this flattens the current view (background plus the scrolled shape) into a single image on the clipboard.
3. Paste it back onto the page (Ctrl+V) so the flattened, already-scrolled image becomes the page's background.

Now the background already shows the scrolled position, so when the objects hide during a transition there's no mismatch to flash. (If you later need to re-edit the scroll, delete the flattened image and repeat once you're done.)

### Tips

- The more scroll positions you capture, the smoother the scroll effect will be.
- Ensure all captures are at the same zoom level and window size for consistent alignment.

## 9. Positioning Beacons

Beacons are the animated indicators (circles, rings, or rectangles) that guide the user through the demo by highlighting where to click. After capturing and cleaning up your demo, go through each page and position the beacons correctly.

### Automatic Beacon Sizing

During capture, Regale Studio automatically detects the UI control you clicked and sizes the beacon to match it. By default, the beacon is expanded by 5 pixels on each side so it is slightly larger than the control — this makes the beacon easier to spot during the demo. You can adjust this value using the Beacon Pad setting in the Home Tab Screen Capture group (range: 0 to 50 pixels). Setting it to 0 will size the beacon to exactly match the detected control. The beacon is always clamped to the page boundaries, so padding near the edge of the screen will not push the beacon off-screen.

### Workflow

1. Navigate through the demo page by page using the Pages List.
2. Select each beacon in the Object Shapes pane or by clicking it in the workspace.
3. Position the beacon so it is centered over the UI element that was clicked during recording. Use the Placement controls in the Shapes Tab to set precise coordinates, or drag the beacon directly in the workspace.
4. Resize the beacon to appropriately cover the target element — large enough to be noticeable, small enough to clearly indicate the intended click target.
5. Rename each beacon to match the UI element it highlights (e.g., "Save Button", "Settings Tab", "Search Field"). This is required for accessibility — screen readers announce the beacon name to users, so it must accurately describe the element. Without a descriptive name, screen reader users will not know what they are expected to interact with.

### Beacon Styles

Choose the beacon style that best fits the context (see Shapes Tab - Beacon Group):

- **Rectangle** — Highlights a rectangular region. Good for buttons, text fields, and menu items.
- **Circle** — A filled circle that pulses. Good for drawing attention to a specific point.
- **Ring** — An animated ring that expands outward. Good for general click targets.

### Tips

- Use the Hide Beacon option if you need the click/hover action but don't want a visible indicator on a particular shape.
- Adjust the Maximum Size to control how large the beacon animation grows within its clickable area.
- Use the beacon alignment buttons to position the beacon relative to its clickable area (left/center/right, top/center/bottom).
