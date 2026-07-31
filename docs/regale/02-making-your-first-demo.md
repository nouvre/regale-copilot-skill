# Making Your First Demo

This guide walks you through the simplest possible workflow for creating a demo in Regale Studio. If you've never made a demo before, start here — you'll be up and running in just a few minutes. Once you're comfortable with the basics, see How to Capture a Demo for more advanced capture techniques and cleanup tools.

**Before you begin:** This guide assumes Regale Studio is already installed and open. If you haven't installed it yet, see Installing Regale Studio.

## 1. Select a Monitor

In the Home Tab Screen Capture group, open the Area dropdown and choose the monitor you want to capture. Pick the monitor where the application you're demonstrating will be visible.

**Tip:** If you only have one monitor, just select it from the list. If you have multiple monitors, choose the one your demo application will run on.

## 2. Check Your Capture Settings

In the same Screen Capture group, verify that the following defaults are set in the Capture Continuous group. These settings give you a smooth, natural recording experience right out of the box:

- **Mode: Continuous** — Continuous mode captures the screen continuously, just like a video screen recorder. You click through your application at a natural pace and each click automatically splits the recording into a new page.
- **Frames/Sec: 8** — 8 FPS is a good balance between smooth animations and manageable file size.
- **Max Sec: Disabled (unchecked)** — With Max Sec disabled, recording won't cut off unexpectedly. You control when to stop.
- **Skip Idle Frames: Enabled** — When nothing is changing on screen, Regale Studio stops capturing redundant frames automatically, keeping your pages lean.
- **Skip Idle Delay: 0.25 seconds** — The screen must be still for half a second before idle skipping kicks in. This preserves brief UI transitions while trimming longer pauses.

## 3. Click Record

Click the Record button in the Quick Action Bar, or press Ctrl+Alt+S, to start a recording session. Regale Studio is now watching for your clicks.

## 4. Capture the Demo

Switch to the application you want to demonstrate and start clicking through it at a natural pace. There's no need to wait between clicks — Continuous mode records the screen continuously, and each click automatically splits the recording into a new page. This is the same workflow you'd use with any video screen recorder: just perform your actions normally and Regale Studio captures everything as it happens.

**Tip:** If you need to pause to think or wait for a page to load, that's fine — Skip Idle Frames will automatically trim the dead air so it won't bloat your pages with redundant frames.

When you've finished walking through your demo, press Ctrl+Alt+S again (or click Record in the Quick Action Bar) to stop the recording session. You should now see one page in the Pages List for each click you made.

## 5. Clean Up the Captured Pages

Before adding presenter notes, take a quick pass through your captured pages to tidy things up:

1. Step through each page in the Pages List, one by one, using the arrow keys or by clicking each page.
2. **Trim extra frames.** Step through each page's frames in the Animation Bar. Select and delete any frames that are mid-transition, partially rendered, or otherwise unnecessary, such as a hover style shown on a button before the click happened.
3. **Check the beacon placement.** Regale Studio automatically places a beacon where you clicked on each page. Verify that each beacon is positioned over the UI element you intended to click (button, link, menu item, etc.). If a beacon is off-target, drag it in the Main Workspace to the correct spot, or fine-tune its position using the Placement controls in the Shapes Tab.
4. **Remove any pages you don't want.** If you accidentally captured extra pages — for example, a stray click, a page where the screen wasn't ready yet, or a step you don't actually need in the final demo — select the page in the Pages List and press Delete (or right-click and choose Remove).

This quick cleanup pass ensures your demo tells a clean, focused story before you start writing presenter notes.

## 6. Add Presenter Notes to Each Page

Now that you have your pages captured, add presenter notes so you (or anyone else presenting the demo) knows what to say at each step:

1. Click the first page in the Pages List to select it.
2. Open the Notes tab in the right-side panel to access the Presenter Notes editor.
3. Type the talking points or script for that page.
4. Move on to the next page and repeat.

## What's Next?

Congratulations — you've made your first demo! From here, you can explore more advanced features:

- **How to Capture a Demo** — Learn about Single mode, Typing mode, hover effects, scroll effects, and beacon positioning.
- **Capturing HTML Pages (Beta)** — Capture a live web page at full fidelity instead of recording your screen.
- **Adding a Talk Track** — Add information annotations and presenter notes to your demo.
- **Working with Shapes** — Build interactive elements, hover effects, beacons, and visibility-driven branching.
- **How to Publish a Demo** — Share your finished demo with others.
