# Working with Shapes

Shapes are the building blocks of interactivity in a Regale Studio demo. They are how you add clickable buttons, hover tooltips, highlights, patches, labels, and animated indicators on top of your captured screens. This guide covers the full shape system: the different kinds of shapes, how to position and style them, how to wire them up to actions, and how to make them respond dynamically to variables.

For UI reference material, see the Shapes Tab, the Object Shapes pane, and the Layer Shapes pane.

## 1. Objects vs Layers

Regale Studio organizes shapes into two separate panes in the right-side panel: Objects and Layers. Every shape belongs to one or the other, and the choice determines how the shape behaves in the final demo.

### Object Shapes (Interactive)

Object shapes are interactive. They remain as live elements in the exported demo and can respond to the viewer's mouse and keyboard:

- They can have click actions and hover actions.
- They can be beacons that guide the viewer to the next step.
- They can be shown or hidden dynamically based on variables.
- They can be text inputs that accept typed input at runtime.
- They appear in the Object Shapes pane (the upper pane in the right-side panel).

Use objects whenever you need the viewer to interact with something — clickable buttons, hover tooltips, navigation targets, form fields, or anything whose appearance depends on runtime state.

### Layer Shapes (Baked into the Image)

Layer shapes are non-interactive. At export time, they are rendered (baked) into the page's image and become part of the background. Once exported, they can't be clicked, hovered, or dynamically shown — they're pixels in the picture.

- They cannot have click or hover actions.
- They are the only shapes that support the Blur effect.
- They appear in the Layer Shapes pane (the lower pane in the right-side panel).

Use layers for visual corrections and additions that are part of the static screen: patches to cover usernames or watermarks, solid-fill rectangles to hide distracting UI, cropped cutouts, blurred regions, or drawn annotations that are always visible regardless of viewer state.

**Rule of thumb:** If it needs to react, it's an Object. If it just needs to be there, it's a Layer.

**Troubleshooting — "my shape won't respond."** The most common shape mix-up is putting an interactive shape in the wrong pane. If any of these are happening, the shape is almost certainly in the Layers pane and needs to be an Object:

- A beacon or button can't be clicked in the exported demo, or does nothing when clicked.
- A shape can't be reached with the Tab key / keyboard navigation.
- A screen reader never announces the shape (its name, role, or beacon).

Layers are baked into the page image at export, so they become flat pixels — there's no element left for the mouse, the keyboard, or assistive technology to find. Fix it by dragging the shape from the Layers pane up to the Objects pane (see Adding and Reorganizing Shapes). Anything you want a viewer to click, tab to, hover, or hear announced must be an Object.

### Adding and Reorganizing Shapes

Add a new shape with the Add Object or Add Layer dropdown at the top of each pane. You can drag shapes within a pane to reorder them (which controls their z-order in the final render), and you can drag shapes between the Objects and Layers panes if you decide something should be interactive instead of baked in, or vice versa.

## 2. Shape Types

The Add Object menu offers the following shape types. Most of them are also available from the Add Layer menu, minus anything that requires interactivity.

| Shape | Description |
|---|---|
| Beacon | An animated click indicator (ring, circle, or rectangle) that highlights where the viewer should click next. See the Beacons section. |
| Button | A styled rectangle designed to look like a clickable button. |
| Text | A styled shape optimized for displaying text labels, titles, or paragraphs. |
| Text Input | An editable text field that accepts typed input from the viewer at runtime. Supports a "return action" that fires when the viewer presses Enter. |
| Blank Shape | An unstyled rectangle. Useful as a starting point for patches, custom-styled elements, or invisible click targets. |
| Dock Panel | A layout container that docks children to its edges. See Layout Shapes. |
| Stack Panel | A layout container that arranges children in a row or column. See Layout Shapes. |
| Canvas | A layout container that lets you position children freely using X/Y coordinates. See Layout Shapes. |
| Video | Embeds a video file you supply and plays it inline in the demo. Use it for genuine footage — a talking-head recording, or a screen capture too long or motion-rich to reproduce as a page animation. (This is unrelated to exporting a captured image animation as MP4 — that's an export setting, not a shape; see the Export tab.) Media shapes cannot have click actions of their own. |
| Sound | Plays an audio clip. Media shapes cannot have click actions of their own. |
| Folder | A grouping container in the shape tree. Does not affect layout — it just helps you organize related shapes. |

Beacons, Buttons, Text, Text Inputs, and Blank Shapes all share the same underlying styling system (fill, border, padding, opacity, images, etc.). They differ in their default appearance and in which interactive features they enable.

## 3. Layout Shapes

Layout shapes are containers that automatically arrange their children. Instead of positioning every child manually, you drop shapes into a layout container and it handles sizing and placement. This is useful for building reusable UI structures like menus, toolbars, and panels — especially ones that need to grow, scroll, or reflow.

All three layout shapes accept any other shapes as children, including other layout shapes (so you can nest them).

### Stack Panel

A Stack Panel arranges its children in a straight line, either Horizontal (side by side) or Vertical (top to bottom). Set the direction with the Orientation property in the Shapes Tab.

Stack Panels support scrolling, so you can set a fixed size on the panel and let its children overflow — viewers can scroll through them at runtime. Configure scrolling with the Horizontal Scrollbar and Vertical Scrollbar properties (Hidden, Auto, or Visible).

Use a Stack Panel when you need a row or column of items: a menu, a toolbar, a sidebar list, or a line of buttons.

### Dock Panel

A Dock Panel docks each child to one of its edges (Left, Top, Right, or Bottom). Docked children take up space along that edge, and the remaining space shrinks for the next child. You set each child's dock position on the child shape itself.

With Last Child Fill enabled (the default), the final child in the panel stretches to fill whatever space is left after the other children have been docked. This is the classic "header + sidebar + content area" layout.

Use a Dock Panel when you're building an application-style layout with headers, sidebars, and a main content area, or any situation where some shapes should cling to edges while another shape expands to fill the middle.

### Canvas

A Canvas lets you place children at absolute X/Y coordinates inside the container. Unlike Stack and Dock panels, a Canvas does no automatic arranging — you position each child yourself, just like you do directly on a page.

Canvases also support scrolling, which is useful if you want to present a large scrollable region inside a fixed-size window.

Use a Canvas when you need precise, free-form placement of children that doesn't follow a stacking or docking pattern — overlays, floating badges, callouts, or anything where the layout is intentionally irregular.

## 4. Click and Hover Actions

Object shapes can respond to two kinds of input: clicks and hovers. Both are configured in the Interaction group on the Shapes Tab.

### Click Actions

A click action runs when the viewer clicks the shape. Pick an action from the Click Action dropdown, and if the action needs additional information (e.g., a page to navigate to, a URL, or a variable to set), click Action Settings to configure it.

The available click actions are:

| Action | What It Does |
|---|---|
| None | The shape is not clickable. |
| Default | Runs the page's default action (usually "Next Page"). |
| Next Page | Advances to the next page in the demo. |
| Previous Page | Goes back to the previous page. |
| Home Page | Returns to the first page of the demo. |
| Page Link | Jumps to a specific page you choose. |
| External Link | Opens a URL in a new browser tab. |
| Toggle Shape | Shows or hides another shape by ID. Useful for popups, menus, and reveals. |
| Set Variable | Sets a variable to a value (or increments/decrements a number variable). |
| Toggle Beacons | Shows or hides all beacons in the demo. |
| Toggle Annotations | Shows or hides annotation shapes. |
| Show Help Menu | Displays the built-in help menu. |
| Show Table of Contents | Displays the table of contents. |
| Section | Navigates to a specific section. |
| Show Presenter View | Switches to presenter view. |
| Open Full Screen / Exit Full Screen | Enter or leave fullscreen mode. |
| Play/Pause Media | Controls a media shape's playback. |
| Select Image | Sets an image variable to a specific image, which is useful with shapes whose fill is bound to an image variable. |

### Hover Actions

Hover actions run when the viewer moves the mouse over a shape. The available hover action is Toggle Shape, which shows another shape while the mouse is hovering (typical use case: tooltips and hover popovers).

Two extra settings fine-tune hover behavior:

- **Hover Delay** — How long (in seconds) the viewer must hover before the action fires. A small delay prevents tooltips from flashing when the mouse just passes over.
- **Hover Persists** — When enabled, the toggled shape stays visible even after the mouse leaves. Disable this for standard tooltip behavior where the popover disappears when the mouse moves away.

### One Click, One Hover

Each shape has exactly one click action and one hover action. To build chained behaviors (e.g., clicking one thing that causes several things to change), use Set Variable to update shared state and let other shapes react to that variable via their visibility expressions, or use Toggle Shape to reveal intermediate shapes that have their own actions.

## 5. Styles

Every styleable shape shares a common set of visual properties. You edit these in the Display group of the Shapes Tab while a shape is selected.

### Style Properties

- **Fill Color** — The background of the shape, as a solid color or a gradient. You can also fill a shape with an Image or an Image Variable (see visibility expressions).
- **Border** — Color, thickness (per side), and style of the shape's outline.
- **Border Radius** — Corner rounding, per corner.
- **Padding** — Internal spacing between the shape's edge and its content.
- **Drop Shadow** — Adds a configurable drop shadow behind the shape.
- **Pointer** — Adds a speech-bubble pointer (a triangle tail) to one edge of the shape, so an annotation visibly points at the thing it describes. See Pointers below.
- **Blur** — A blur effect. Only available on Layer Shapes.
- **Opacity** — Overall transparency from 10% to 100%. Applies to the shape and all its content.
- **Font Family, Font Size, Text Color** — For shapes that contain text, set these from the Home Tab's Font group.

### Pointers (Speech-Bubble Tails)

A Pointer turns a shape into a speech bubble: a triangle tail on one edge that aims the annotation at what it's describing. The tail is drawn as part of the shape's outline, so the border runs continuously around it and the drop shadow wraps the whole bubble as one silhouette — no more stitching a separate triangle image next to a rectangle and getting two disconnected shadows.

To add one, select the shape and open the Pointer dropdown in the Display group:

- **Edge** — Click Top, Bottom, Left, or Right on the cross to pick which edge the tail protrudes from. The center × removes the pointer.
- **Position %** — Where the tail sits along the edge (50% = centered). The tail always stays clear of rounded corners.
- **Length and Width** — How far the tail sticks out and how wide its base is, in pixels.

You can also drag the pointer directly on the canvas: when a shape with a pointer is selected, a round handle appears at the tail's tip — drag it to any edge and position, even across edges. A plain drag keeps the tail's size and just repositions it; hold Shift while dragging to also stretch the tail out to the mouse, so it can reach the exact thing it points at.

Things to know:

- The tail extends outside the shape's width/height, so adding or removing a pointer never moves the shape's content.
- Pointers work on text annotations, buttons, and panels, on both image-based and HTML pages, and look the same in the editor and the published demo.
- Scrolling panels (Stack Panels and Canvases) and text input fields can't have a pointer. A scrolling panel clips its content, which is incompatible with the tail spilling outside the shape; a text input is a native field the bubble can't draw inside. Put the shape inside a Dock Panel and give the Dock Panel the pointer instead.
- The theme controls the pointer's presence, you control its aim: giving a theme shape a pointer gives one to every instance that doesn't have one yet (existing and new), but each instance keeps its own edge and position once set — a theme update never moves a pointer you've aimed, and removing the theme's pointer never removes one an instance has. The Pointer control stays enabled on themed shapes for the same reason.

### Conditional Styles

A shape can have conditional styles that override the base style under certain conditions:

- **Hover** — Applied while the mouse is over the shape. Ideal for hover highlights on buttons.
- **Focus** — Applied while the shape has keyboard focus. Important for accessible navigation.
- **Expression** — Applied when a variable expression evaluates to true. Use this to restyle shapes based on runtime state.

Conditional styles only override the properties you set on them — anything you leave alone falls through to the base style.

### Reusing Styles

To copy a look from one shape to another:

1. Right-click the source shape in the Object Shapes pane and choose Copy Style.
2. Select the target shape(s) and choose Paste Style.

Reset Styles in the context menu reverts a shape to its default style.

You can also add a shape to the Project Theme, which lets you reuse the same shape (with the same styling) across many pages.

## 6. Beacons

Beacons are the animated indicators that guide viewers through a demo by highlighting the next thing to click. A beacon is a special shape type with a built-in animation, and it is itself a click target — it combines "here's where to click" with "here's what happens when you click."

### Beacon Styles

In the Beacon group of the Shapes Tab, choose the visual style:

- **Ring** — An animated ring that expands outward. Good for general click targets.
- **Circle** — A filled circle that pulses. Good for drawing attention to a specific point.
- **Rectangle** — A solid rectangle that fades in and out. Good for buttons, menu items, and other rectangular UI.

### Beacon Properties

| Property | Description |
|---|---|
| Beacon Color | The color of the animated indicator (default: blue). |
| Max Size | For Ring and Circle, the maximum size (in pixels) the animation grows to before resetting. Ignored for Rectangle. |
| Beacon Margin | Padding between the beacon and the edge of its clickable area. Use this to shrink the visible indicator without shrinking the click zone. |
| Corners | Corner radius for Rectangle beacons only. |
| Hide Beacon | Turns off the animated indicator while keeping the click/hover area fully interactive. Use this when you need a hidden click target — for example, when a hover effect already indicates where to click. |

### Beacon Alignment

The beacon visual is positioned inside its clickable area using two alignment settings:

- **Horizontal** — Align Left, Align Horizontal Center, Align Right.
- **Vertical** — Align Top, Align Vertical Center, Align Bottom.

Use these to nudge the beacon toward a specific corner or edge of a larger click zone — for example, placing a small circle beacon in the top-right corner of a button.

**Accessibility:** Always rename beacons to describe the element they highlight (e.g., "Save Button", "Settings Menu"). Screen readers announce the beacon's name to users navigating the demo with assistive technology. See the Shape Accessibility Tab for more.

## 7. Positioning, Resizing, and Rotating

You can position, resize, and rotate shapes with the mouse, with the keyboard, or by typing exact values into the Placement group of the Shapes Tab.

### Mouse

- **Move** — Click anywhere inside the shape (away from the edges) and drag.
- **Resize** — Click near an edge or corner and drag. Edges resize one dimension; corners resize both.
- **Rotate** — Select the shape, then drag the round rotate handle floating above its top edge. The shape rotates around its center. Hold Shift to snap to 45° increments.
- **Lock Aspect Ratio** — Hold Shift while resizing to preserve the shape's aspect ratio, or toggle the Lock Aspect Ratio button in the Placement group to make it permanent.
- **Cursor feedback** — The cursor changes to indicate what will happen: a hand for move, double-headed arrows for edge resize, diagonal arrows for corner resize.

### Keyboard

Select a shape in the Main Workspace and use the arrow keys for pixel-perfect adjustments:

| Shortcut | Action |
|---|---|
| ← → ↑ ↓ | Nudge 1 pixel |
| Shift + ← → ↑ ↓ | Nudge 10 pixels |
| Ctrl + ← → ↑ ↓ | Resize 1 pixel (from the bottom-right corner) |
| Ctrl + Shift + ← → ↑ ↓ | Resize 10 pixels |
| Alt + ← → | Rotate 15° (counter-clockwise / clockwise) |
| Alt + Shift + ← → | Rotate 1° |

### Snap-to-Edge

While you're moving or resizing a shape, Regale Studio automatically snaps its edges to the edges of other shapes on the page. When an edge comes within 8 pixels of another shape's edge, it snaps into alignment and a red dashed guide line appears to show which edges are lined up.

Snapping works for:

- **Outer edges** — the moving shape's left snaps to another shape's left, or its right snaps to another shape's right, etc.
- **Inner edges** — the moving shape's right snaps to another shape's left (side-by-side alignment) and vice versa.
- **Horizontal and vertical independently** — you can snap vertically to one shape and horizontally to another at the same time.

Snap-to-edge is always on and cannot be disabled with a modifier. If you need to position a shape that would otherwise snap, move it past the snap threshold and then back.

### Placement Group

For exact values, use the Placement group in the Shapes Tab:

- **X, Y** — The top-left position of the shape on the page.
- **Width, Height** — The shape's dimensions. Minimum is 10 pixels.
- **Rotation** — The shape's rotation in degrees, clockwise around its center (0–359.99). Values outside the range wrap, so typing -45 lands as 315.
- **Width is Automatic / Height is Automatic** — When enabled, the shape auto-sizes to its content.
- **Lock Aspect Ratio** — Preserves the width-to-height ratio during resizes.
- **Horizontal Alignment / Vertical Alignment** — Left/Center/Right/Stretch and Top/Center/Bottom/Stretch. These control how the shape aligns within its parent container (page, layout panel, etc.).
- **Margin** — Spacing between the shape and neighbors inside a layout container. This is different from position: it affects layout flow, not absolute placement.
- **Animation** — On pages with multiple images, controls which frames the shape appears on. See Animation Mode on Multi-Image Pages.

## 8. Animation Mode on Multi-Image Pages

When a page has more than one image (an animation sequence), each Object shape on that page needs to know which frames it should appear on. The Animation dropdown in the Placement group of the Shapes Tab controls this.

### The Three Modes

| Mode | Behavior |
|---|---|
| Last Image (default) | The shape only appears on the last frame of the animation. Use this for callouts, beacons, and labels that should appear after the captured action has played out. |
| All Images | The shape appears on every frame. Use this for shapes that are part of the page's chrome — persistent overlays, navigation buttons, watermarks, or any shape that shouldn't blink in and out as the animation plays. |
| Custom | The shape's visibility is controlled per-frame from the Animation Bar. Use this when a shape needs to come and go partway through the animation — for example, a tooltip that appears for a few frames and then disappears. |

**Media shapes and animation mode — a common autoplay gotcha.** A Sound or Video shape only plays while it's visible. On a multi-image page, the default animation mode is Last Image — which means a sound set to autoplay won't start until the animation finishes and the last frame is reached. If you want audio to play the moment the page loads, set the media shape's animation mode to All Images so it's visible (and therefore playing) from the first frame. The same applies to Video shapes, though it's less surprising there since the video is usually the thing the page is built around. (Because media only plays while visible, you can also use a variable-driven visibility expression as a global mute switch — see Example 2: A Play Audio Toggle.)

### Setting Per-Frame Visibility (Custom Mode)

When Custom is selected, expand the Animation Bar using its expand button. The expanded view shows every shape on the page as a row, with a column per frame. Click a cell to toggle that shape's visibility on that frame; hidden cells appear faded in gray.

Switching from Custom back to Last Image or All Images discards the per-frame settings — the new mode takes over.

### Interaction with Visibility Expressions

Animation mode and visibility expressions work together. A shape must pass both checks to appear:

1. The animation mode (or per-frame setting in Custom mode) must include the current frame.
2. The visibility expression (if any) must evaluate to true for the current variable state.

This separation lets you control timing (when in the animation a shape appears) independently from runtime state (whether the viewer's choices have unlocked it).

### Single-Image Pages

On pages with only one image, the Animation mode setting has no visible effect — there's only one frame for the shape to appear on. The setting still applies, so if you later add more images to the page, the shape's existing animation mode determines how it behaves on the expanded sequence.

### Layer Shapes and Animation

Layer shapes are baked into each frame's image at export time, so they support the same Animation mode options as Object shapes. Use All Images for a layer-baked patch that should be present throughout the animation, Last Image for one that only applies to the final state, or Custom for a layer that comes and goes mid-animation.

## 9. Visibility Expressions with Variables

One of the most powerful features of the shape system is dynamic visibility: you can control whether a shape is visible based on the state of one or more variables. This is how you build demos that branch, remember choices, or reveal content conditionally.

### Variables

Variables are defined at the project level. Open the Project Tab → Variables dialog to create, edit, and delete them. Each variable has a Key (the internal identifier used in expressions) and a Name (a friendly display name), plus a default value.

Four variable types are supported:

- **Text** — String values.
- **Boolean** — True or False.
- **Number** — Decimal numbers.
- **Image** — An image reference, used to dynamically change a shape's fill image.

Regale Studio also provides built-in variables you can use in expressions without defining them yourself:

| Key | Meaning |
|---|---|
| pg | Current page number in the section |
| pgs | Number of pages in the current section |
| ppgs | Total pages in the project |
| title | Project title |
| section | Current section title |
| showBeacons | Whether beacons are currently shown |
| showAnnotations | Whether annotations are currently shown |
| isFullscreen | Whether the player is in fullscreen mode |

### Setting Variables at Runtime

Variables change value at runtime via the Set Variable click action (see Click and Hover Actions). For number variables, the action supports:

- `=100` — Set to an exact value.
- `+5` — Add to the current value.
- `-3` — Subtract from the current value.

For boolean variables:

- True or False — Set to a specific value.
- Toggle — Flip the current value.

A page can also set a variable automatically when it's shown, using the Linked Variable setting in the Page Tab.

### Visibility Expressions

With variables defined, you can make a shape visible only when certain conditions are true.

1. Select an Object shape.
2. In the Placement group of the Shapes Tab, click the Visibility (eye) button.
3. The Visibility dialog opens with a visual expression builder.

An expression is a series of comparisons combined with AND and OR. Each comparison picks a variable, a comparer, and a value. The supported comparers are:

| Comparer | For |
|---|---|
| Equals / Not Equals | Any type |
| Greater Than / Greater Or Equal / Less Than / Less Or Equal | Numbers |
| Contains / Not Contains / Starts With / Ends With | Text |
| Regex | Text (regular expression match) |

Text comparisons have an optional Ignore Case toggle.

Click Add Variable to add another line, and use the AND/OR dropdown on each subsequent line to combine it with the previous ones. Use Group Selected to nest comparisons for more complex logic.

### Expression Examples

Visibility expressions shine in a few very common demo patterns. Here are the real-world scenarios they're built for.

#### Example 1: Branching with Beacon State

One of the most powerful uses of visibility expressions is branching logic — letting the viewer's earlier clicks control what they see next. The pattern is simple: use a boolean variable for each beacon the viewer might click, set it to True from that beacon's Set Variable click action, and then use visibility expressions on later beacons to control which ones appear.

Suppose page 1 has two beacons, Beacon A (tied to variable ClickedA) and Beacon B (tied to variable ClickedB), and you want page 2 to show a third beacon Beacon C only if the viewer took the "A but not B" path:

1. Define two Boolean variables in the Project Tab: ClickedA and ClickedB, both defaulting to False.
2. On Beacon A, set the click action to Set Variable, targeting ClickedA = True. Same for Beacon B with ClickedB.
3. On page 2, open Beacon C's visibility expression and enter:

```
     ClickedA  Equals     True
AND  ClickedB  NotEquals  True
```

Beacon C will now only appear for viewers who clicked A without clicking B. You can chain this across many pages to build sophisticated branching demos without duplicating pages — every branch is a different combination of the same booleans. Regale Studio does not have a standalone NOT operator, so use NotEquals (or Equals False) to express "not clicked."

#### Example 2: A Play Audio Toggle

Audio shapes (and video shapes) don't play when they're hidden. You can use this to give viewers a global audio toggle that enables or disables all the narration in a demo.

1. Create a Boolean variable called PlayAudio, defaulting to True.
2. On every audio shape in the project, set the visibility expression to: `PlayAudio Equals True`
3. On one or more pages, add a button with the click action Set Variable, targeting PlayAudio = Toggle. This flips the value each time the viewer clicks.

Now the viewer can mute or un-mute the entire demo from any page that has the toggle button. Because audio shapes don't play while hidden, toggling PlayAudio to False stops playback immediately and prevents future audio shapes from playing when their pages load. When they toggle it back to True, audio resumes on subsequent pages.

You can pair this with a second shape that shows "Audio On" or "Audio Off" by giving each shape a complementary visibility expression (PlayAudio Equals True for one, PlayAudio Equals False for the other) so the button label always matches the current state.

#### Example 3: A Checkbox (Checked / Unchecked Swap)

To simulate an interactive checkbox in a demo, create two shapes stacked in the same spot: an "unchecked box" image and a "checked box" image. Bind their visibility to opposite states of a single Boolean variable so that exactly one is visible at any time.

1. Create a Boolean variable called AgreeToTerms, defaulting to False.
2. Add the unchecked shape and set its visibility expression to: `AgreeToTerms Equals False`
3. Add the checked shape in the same position and set its visibility expression to: `AgreeToTerms Equals True`
4. Place a beacon (or make one of the shapes itself a click target) that uses Set Variable with AgreeToTerms = Toggle.

Clicking the checkbox now swaps between the two images in place — exactly the behavior a real checkbox has. The same pattern works for toggle switches, radio buttons (use a Text variable with different values per option instead of a Boolean), and any other "pick one of several visual states" control.

**Tip:** When you have several shapes whose visibility all depends on the same variable (like the audio toggle or checkbox examples), put them in a Folder in the Object Shapes pane. That keeps them grouped in the shape tree, so it's easy to find and update them later.

### How Expressions Are Evaluated

- A shape with no visibility expression is always visible (subject to normal visibility rules like the Animation Bar's per-frame visibility).
- A shape with an empty expression (no lines) is treated as visible.
- Expressions are re-evaluated continuously. Whenever any referenced variable changes, affected shapes show or hide immediately.
- Visibility expressions are combined with per-frame visibility from the Animation Bar: a shape must pass both checks to be visible. The expression controls runtime state; per-frame visibility controls which animation frames the shape appears on.

**Tip:** If a shape isn't showing up the way you expect, check both its visibility expression and its per-frame visibility in the expanded Animation Bar. These are independent, and it's easy to hide a shape in one place while troubleshooting the other.

## What's Next?

- **Shapes Tab** — Detailed reference for every shape control in the ribbon.
- **Object Shapes and Layer Shapes** — The right-side panes where you manage shapes.
- **Shape Accessibility Tab** — Making your shapes usable with screen readers and keyboard navigation.
- **How to Capture a Demo** — Workflow guide that covers patches, hover effects, scroll effects, and beacon positioning in context.
