# Welcome to Regale Studio

Regale Studio is a Windows application for building simulated software product demos — interactive, click-through walk-throughs of real applications that look and feel like the live product, but run entirely from a set of pre-captured screens. Use it to build demos for sales calls, self-guided product tours, onboarding experiences, marketing landing pages, and anywhere else you want to show off software without the overhead (or risk) of running the real thing in front of an audience.

If you want to dive straight into building something, jump to Making Your First Demo. If you'd rather get oriented first, this page walks through what Regale Studio does, how demos are structured, and where the final output ends up.

## Installing Regale Studio

Regale Studio is a Windows desktop application. To install it:

1. Download the installer: RegaleStudioSetup.msi
2. Run the downloaded RegaleStudioSetup.msi and follow the prompts.
3. Launch Regale Studio from the Start menu.

Regale Studio checks for updates on startup, so once it's installed you'll be prompted whenever a newer version is available. The download link above always points at the latest release, so it's safe to share with teammates who need to get set up.

## What Regale Studio Is For

At its core, Regale Studio is a tool for turning a series of screens — captured from a real application, imported from a design tool, or exported from a video — into an interactive demo that a viewer can click through at their own pace.

### Building Demos from Multiple Sources

You aren't limited to any one way of getting your source material into the tool:

- **Direct screen capture** — Record the live application running on your own machine. Regale Studio watches your mouse and keyboard and captures screenshots as you click through the workflow, automatically placing click beacons where you clicked. See How to Capture a Demo for the full workflow, including continuous recording, typing capture, and machine setup tips.
- **Capturing live web pages (Beta)** — Capture a real web page with the built-in HTML Capturer. The page is saved at full fidelity as an HTML page that reflows to fit the player instead of breaking when the layout shifts. HTML capture is a Beta feature in 5.0. See Capturing HTML Pages.
- **Importing images from other sources** — Bring in screenshots, mockups from Figma or other design tools, frames extracted from a video, or any other static imagery. This is how you build demos for applications you can't easily run on your own machine, or prototype a demo before the real product exists.
- **A mix of the above** — Most real demos combine captured application screens, captured web pages, and imported images for marketing slides, branded title screens, and polished end cards.

### Who Demos Are Built For

Regale Studio demos are designed to be useful in two very different settings:

- **Guided presentations** on sales calls, QBRs, training sessions, or internal reviews. Each page can have presenter notes (a talk track only the presenter sees) so anyone can drive the demo with the same narrative. See Adding a Talk Track for the full story on presenter notes and annotations.
- **Self-guided experiences** that you share directly with prospects and customers — either via a direct link or embedded in a web page — so they can click through the product on their own time, without needing a salesperson on the call.

A single project can serve both purposes: the same demo can be walked through live with a presenter and then sent to the prospect as a follow-up.

## Projects, Pages, and the Web Player

### The Project File

Everything you build for a single demo lives in a Regale Project File (.rglx). This is a single, portable file that holds every captured image, every shape, every presenter note, theme settings, and the navigation structure of the whole demo. Opening, saving, and sharing a demo for editing is as simple as opening, saving, and sharing the .rglx.

### From Project File to Finished Demo

The .rglx is the editable source. The finished product is a Regale Demo — a set of web files (HTML, JavaScript, CSS, images, and video) that runs inside the Regale Web Player in any modern web browser. When you're ready to share a demo with the world, you have two options:

- **Publish to Regale Cloud** — The easiest path. Regale Studio uploads your project to Regale Cloud and gives you a shareable link you can send to anyone.
- **Export to a local folder** — Produces a stand-alone HTML application you can host on your own web server, embed in a marketing page, drop onto a USB stick, or check into a product's own site.

Either way, the end viewer just sees a web page — no plugins, no installs, no Regale Studio required on their end. See How to Publish a Demo for the full publishing workflow.

## How a Demo Is Structured

Regale Studio demos are organized as a simple hierarchy. Understanding this hierarchy makes everything else in the tool easier to navigate, because most of Regale Studio's UI is built around moving between these levels and editing what lives at each one.

```
Project
└── Sections
    └── Pages
        ├── Images
        ├── Object Shapes (interactive)
        └── Layer Shapes (decorative)
```

### Project

The top level. A project holds the demo's metadata, theme (colors, fonts, reusable shapes), and all of the sections below it. Most project-wide settings — branding, accessibility defaults, publish targets — are edited here. See Working with Themes for how to brand a project so everything looks consistent.

### Sections

A project is broken into one or more sections, which are used to group related pages together and drive the demo's Table of Contents. If your demo has distinct chapters — "Sign In", "Dashboard", "Create a Report", "Share with a Colleague" — each is a natural section. Viewers can jump between sections from the built-in Table of Contents in the Web Player.

Simple demos can have just one section; longer or more structured demos will have several.

### Pages

Each section is made up of one or more pages. A page is a single step in the demo: one thing the viewer sees and one action they take to move forward. On a typical page you'll have:

- A background image (or a short animation, if you captured a motion sequence) showing the state of the application.
- A click beacon — the pulsing indicator that tells the viewer where to click to advance.
- Optional presenter notes — what the presenter should say when walking through this page live.
- Optional annotations — text callouts, arrows, or highlights to draw attention to something on screen.
- Optional interactive shapes such as hover effects, scrollable regions, or hot spots that reveal additional content.

Pages are the fundamental unit of a demo. A well-paced demo usually has more short pages than a few long ones, since each click gives the viewer a beat to absorb what's changed.

### Images

Every page can have one or more images — the backdrop against which everything else sits. For most pages this is a single captured screenshot of the application; for pages that show motion (a loading spinner, a transition, a typing animation), the images form an animation sequence that plays automatically. See How to Capture a Demo for the different capture modes and how they produce single images versus animations.

Note: Having a page without images is an advanced feature that allows you to build a page completely out of shapes.

A page can also be an HTML page — a live web page captured at full fidelity that reflows to fit the player — instead of an image. HTML and image pages live side by side in the same demo and can both carry shapes, beacons, and presenter notes. See Capturing HTML Pages.

### Object Shapes and Layer Shapes

On top of each page's images, you can add two kinds of shapes:

- **Object Shapes** are interactive. Click beacons, buttons, hover effects, hot spots, tooltips, form inputs, scroll regions — anything that the viewer can interact with in the published demo is an object shape. Object shapes live above the images and respond to the viewer's mouse and keyboard.
- **Layer Shapes** are non-interactive and are "baked" into the background. They are used for things like covering up a username or other sensitive data in a captured screen, adding a decorative frame, placing a watermark, or drawing a highlight behind some content. Layer shapes appear as part of the image itself from the viewer's perspective — they don't respond to clicks.

The distinction matters because it determines what a shape can do: interactive things go in object shapes; purely visual decoration goes in layer shapes. See Working with Shapes for a full overview of both kinds and the tools Regale Studio gives you for creating and editing them.

## Where to Go Next

- **Making Your First Demo** — The simplest possible end-to-end walk-through. Start here if you want to be up and running in a few minutes.
- **How to Capture a Demo** — Machine setup, capture modes, animation cleanup, patches, hover and scroll effects, and beacon positioning.
- **Adding a Talk Track** — Presenter notes and audio narration.
- **Working with Shapes** — Everything object and layer shapes can do.
- **How to Publish a Demo** — Publishing to Regale Cloud and exporting to stand-alone HTML.
- **Making Accessible Demos** — Screen reader support, keyboard navigation, and other accessibility best practices.
- **Working with Themes** — Branding your project: colors, fonts, and reusable theme shapes.
