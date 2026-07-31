# Adding a Talk Track

A "talk track" provides context, narration, or guidance alongside your demo. Depending on your audience, you can add a talk track in three ways: Presenter Notes for live presenters, Accessibility Descriptions for screen reader users, and Information Annotations for self-guided viewers.

## 1. Presenter Notes

Presenter Notes are a script or set of talking points that a presenter reads while delivering the demo in Presenter View. They are not visible to the audience. (They are sometimes called speaker notes, and running a demo this way — notes on the presenter's screen, the demo on a second screen the audience sees — is what people mean by a two-screen, dual-monitor, or presenter-mode presentation.)

### Enabling Presenter View

Before Presenter Notes can be used during playback, Presenter View must be enabled for the project:

1. Go to the Project Tab > Player Settings group.
2. Check the Allow Presenter View checkbox.

Without this setting, the Presenter View option will not be available to users in the web player.

### Writing Presenter Notes

1. Select the page you want to add notes to in the Pages List.
2. Open the Notes tab in the right-side panel.
3. Enter your script or talking points in the Presenter Notes rich text editor. Standard text formatting is supported.

Write notes that tell the presenter what to say and do on each page. Keep them concise — the presenter needs to read them at a glance while also interacting with the demo.

### Tips

- Font sizes are automatically stripped when pasting text into Presenter Notes (ClearFontSizeOnPaste) to ensure consistent display in the web player. You do not need to manually clean up pasted text.
- Presenter Notes are also included as speaker notes when exporting the project to PowerPoint via the Export Tab.
- Each page has its own independent set of notes.

For more details, see Presenter Notes.

## 2. Accessibility Description

The Accessibility Description provides a text description of each page for users who rely on screen readers or other assistive technologies. This is essential for making your demo accessible.

### Writing an Accessibility Description

1. Select the page in the Pages List.
2. Open the Desc. tab in the right-side panel.
3. Write a clear description of what the page shows and what actions are available.

The description should convey the same information a sighted user would get from looking at the page — what is on screen, what has changed since the previous page, and what the user is expected to do next.

### Using AI to Generate Descriptions

Instead of writing each description from scratch, you can use AI to create a starting point:

1. Click the Generate button (magic wand icon) in the Desc. tab.
2. The AI will analyze the page's visual content and that of the previous page, and produce a description.
3. Review and edit the generated text as needed — AI descriptions are a starting point, not a finished product.

### Tips

- Font sizes are automatically stripped when pasting text, just like Presenter Notes.
- The description text is included in the exported HTML for screen reader accessibility.
- Each page has its own independent description.

For more details, see Page Description.

## 3. Information Annotations

Information Annotations are shapes placed directly on the demo screen that contain text guidance for the viewer. Use these when a demo will be shared directly with customers or end-users who are navigating it on their own, without a live presenter.

### Adding an Information Annotation

1. Open the project's theme (Project Tab > Theme) and look for the Information shape in the default theme. This shape includes an area for text and navigation buttons (such as Next and Back).
2. Place the Information shape on the page where guidance is needed.
3. Double-click the shape to enter text edit mode, then type your message.
4. Position and resize the shape so it does not obscure important parts of the demo.

### Marking a Shape as an Annotation

After placing the shape, you must flag it as an annotation so the player treats it correctly:

1. Select the shape and all it's children.
2. In the Shapes Tab Display group, enable the Is Annotation toggle.

When Is Annotation is enabled:

- The shape is hidden in Presenter View by default, since a live presenter does not need on-screen text guidance.
- Users viewing the demo in 1-screen mode can toggle annotations on or off using the player controls.

Note: the default Information shape in the Theme already has Is Annotation enabled.

### Keeping Annotations Visible in Presenter View

If you need an annotation to remain visible even in Presenter View (for example, a label or callout that is useful to both presenters and self-guided users):

1. Select the annotated shape.
2. In the Display group, enable Pres. Visible ("Presenter View Visible").

This forces the shape to be shown in Presenter View even though it is marked as an annotation.

### Tips

- To edit the text in a placed theme shape, double-click it to enter text edit mode. Use the Font and Paragraph controls to format the text.
- The Text Editable toggle in the Display group controls whether the shape's text can be edited outside of the Theme Shape Editor. If you want to customize the text per page, make sure this is enabled.
- You can use any shape as an annotation, not just the default Information shape — just enable the Is Annotation toggle.
- The Toggle Annotations click action (available in the Interaction group) can be assigned to a button shape to let users turn annotations on or off from within the demo itself.
