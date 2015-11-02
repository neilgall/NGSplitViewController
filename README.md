# NGSplitViewController
A UISplitViewController replacement with a simpler, saner API and no magic.

# Overview

This view controller along with its master and detail view controllers can be created in Interface Builder
but the relationships must be configured in code. This is as simple as setting the `masterViewController` and
`detailViewController` properties, and assigning a delegate.

By default, `NGSplitViewController` shows the master and detail view controllers side-by-side when in a
regular horizontal size class. The split ratio can be changed by adjusting the `splitRatio` property.
In a compact horizontal size class, the master view controller disappears leaving the detail to fill the
view of the `NGSplitViewController`. The application should arrange for some means to present the master
view controller, and call `overlayMasterViewController()` to do so. On narrow (<=320 points overall) views
the master view controller replaces the full view of the detail using a cross-fade. On wider views, the
master view controller slides in from the left. The application should present some means to return to
the detail view using `dismissOverlaidMasterViewController()`, although on wider screens any touch in the
right margin outside the overlay will also dismiss the overlay.

The precise behaviour of when the master view controller is shown and hidden can be overridden by the
delegate.


# Adding to your project

For now just add `NGSplitViewController.swift` directly to your project. The rest of the project here is simply a testbed and demonstration.