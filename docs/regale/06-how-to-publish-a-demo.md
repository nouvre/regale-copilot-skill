# How to Publish a Demo

This guide walks you through publishing your Regale Studio project to a Regale organization, making it available for viewing on the web. Publishing has been streamlined into a single dialog — you can pick a folder, find or create a demo card, find or create an asset, and kick off the upload all from the same window.

## 1. Sign In

Before you can publish, you must be signed in to your account:

1. If you are not already signed in, click Sign In in the Publish Tab.
2. Complete the authentication process.
3. Once signed in, the Publish tab controls become available and the Sign In button is replaced.

## 2. Select an Organization

1. In the Publish Tab Connect group, open the Organization dropdown.
2. Select the organization you want to publish to.

If you belong to multiple organizations, make sure you choose the correct one — every subsequent step (folders, demo cards, assets) is scoped to this organization.

## 3. Open the Publish Dialog

Click the Publish button in the Publish Tab's Publish group. The Publish dialog opens. It's a single window with three side-by-side panels:

- **Folders (Groups)** — on the left
- **Demo Cards** — in the middle
- **Assets** — on the right

You'll work left-to-right: pick a folder (or "All Folders"), search for / select or create a demo card, then select or create an asset, and finally click Publish.

## 4. Choose a Folder

The left panel shows the Folders (Groups) tree for your organization.

- Leave All Folders selected to show demo cards from every folder, or
- Select a specific folder in the tree to filter the middle panel to just that folder's demo cards.

Expand and collapse nodes in the tree to navigate the folder hierarchy.

## 5. Select or Create a Demo Card

The middle panel shows the Demo Cards available in the selected folder (or across all folders). Demo Cards are containers on the Regale portal that hold your published demos.

### Finding an Existing Demo Card

1. Use the search box at the top of the panel to search by title. Click the search button or press Enter to apply the search, and the clear button to reset it.
2. Browse the list, using the pagination controls at the bottom (First, Previous, Next, Last) if there are many cards.
3. Click a demo card to select it. The right panel updates to show the assets for that card.

### Creating a New Demo Card

If you need a new demo card, click the + Create Demo Card button at the top of the middle panel. The Create a New Demo Card dialog opens. Fill in the fields:

| Field | Description |
|---|---|
| Parent Folder (Group) | The folder where the new card will live. Defaults to the folder you had selected in the Publish dialog. |
| Title | The display name of the demo card. Required. |
| Description | A longer description shown on the Regale portal. |
| Is Published (Active) | When on, the demo card goes live immediately. Turn it off to create the card in an inactive state. If you are a Demo Group Contributor on the selected folder (rather than a full Owner), this toggle is disabled — new cards must start as drafts, and a Demo Group Owner can publish them later. |
| Viewers Restricted | When on, only users with the appropriate roles can view the demo card. |
| Also create an Asset | On by default. When checked, a matching Asset is automatically created on the new card using the card's title as the asset name. The asset starts as published; if your role only allows uploading draft files on the card, the asset is created as a Draft instead. |
| Demo Tags | Expand each tag category and check the tags that apply to this demo. Your organization may require certain tag categories. |

Click OK to create the card. The new demo card is added to the top of the list and automatically selected. Click Cancel to back out without creating anything.

**Tip:** Previously, creating a demo card meant leaving Regale Studio to open the Regale portal in a browser. That's no longer necessary — everything happens inside the Publish dialog.

## 6. Select or Create an Asset

With a demo card selected, the right panel shows its Assets — the published files attached to that card. Each asset has an ID, a Name, and an Active status.

### Selecting an Existing Asset

Click an asset in the list to select it. This is the asset your project will upload into, replacing its current contents with a new version.

### Creating a New Asset

If no asset exists yet, or you want to publish to a new one, click + Create Asset. The Create a New Asset dialog opens with these fields:

| Field | Description |
|---|---|
| Name | The asset name. Required. |
| Publish Automatically | When on (the default), the uploaded file is published immediately. Turn it off to upload as a Draft that must be approved before it goes live. If your role on the parent demo card only allows uploading draft files (for example, Demo Group Contributor), this toggle is disabled and the asset is created as a draft. |
| Make Publicly Viewable | When on, anyone with the link can view the demo without signing in. |
| Mark as Viewers Restricted | When on, viewing is restricted to users with the appropriate roles. |

Click OK to create the asset, or Cancel to back out.

**Note:** Make Publicly Viewable and Mark as Viewers Restricted are mutually exclusive — enabling one automatically disables the other.

## 7. Publish

With a demo card and asset both selected, the Publish button at the bottom of the Publish dialog becomes enabled. Click it to start the upload.

Regale Studio performs the following steps automatically:

1. Exports the project to HTML.
2. Packages the exported files into a ZIP archive.
3. Uploads the ZIP to the selected asset on the Regale portal.

A progress indicator is shown during the upload. Don't close the dialog while publishing is in progress.

## 8. Review the Result

When the upload finishes, the Upload Complete dialog appears with links to key portal pages, visibility information, and action buttons.

### Links

The dialog shows shareable links for each of the following. Click a link to open it in your browser, or use the copy button next to it to copy the URL to your clipboard.

| Link | Description |
|---|---|
| View Published Demo | The public link to the published demo. Only shown when the entire chain (folder, demo card, asset, and asset file) is published and active. |
| View Draft (review link for contributors) | A private link to preview the uploaded draft. Share this with Contributors so they can review before the demo is published. |
| View Demo Details | Opens the demo details page in the Regale portal. Only shown when the chain is fully active. |
| Edit Demo Card | Opens the demo card settings page on the Regale portal. |
| Edit Asset Entry | Opens the asset settings page on the Regale portal. |

### Visibility

Below the links, the dialog shows who can see your demo once it is published:

- **Visible to everyone in the organization** — no role restrictions are in effect.
- **Restricted** — one or more items in the hierarchy (folder, demo card, or asset) have viewer role restrictions. The dialog lists each restricted level and the roles a viewer must belong to. Restrictions are additive: a viewer must hold at least one required role at each restricted level.
- **Not yet visible in the portal** — something in the chain is not published. The dialog tells you which item needs to be activated. You can still share the draft review link with Contributors.

**Note:** Users in the Owners or Contributors groups for a demo card or folder can always view the demo in the portal, regardless of any role restrictions on the item or its ancestors. To share a draft with someone, add them as a Contributor on the Edit Demo Card page and send them the draft review link.

If the asset is marked as publicly available, role restrictions are overridden for the public /play link, meaning anyone with that URL can view the demo without signing in.

### Action Buttons

Depending on the asset's state and your permissions, some or all of these buttons are available:

| Button | Description |
|---|---|
| Publish Draft | Promotes the uploaded draft to become the active published version. Only shown if the asset is currently in draft state and you have permission to publish. Appears next to the View Published Demo link, or next to the View Draft link when the published row is hidden. |
| Download Offline Package | Downloads the published ZIP file for offline use with analytics enabled. |

Click Close to dismiss the dialog.
