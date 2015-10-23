# NGSplitViewController
A UISplitViewController replacement with a sane API

Sane in this case means there is no magic. Create an `NGSplitViewController` and assign its `masterViewController` and `detailViewController` properties. Optionally adjust the `splitRatio` and `animateOverlayDuration`. Assign a delegate.

In a regular horizontal size class the master and detail view controllers will appear side by side. In a compact horizontal size class only the detail will show. In this state the master can be made to appear as an overlay which slides in from the left.

In your delegate, add and remove some UI to control showing the overlay in response to `willHideMasterViewController` and `willShowMasterViewController`. Unlike `UISplitViewController` this UI is entirely up to your app. When you want the master view controller to appear overlaid, call `overlayMasterViewController()` and `dismissOverlaidMasterViewController()` as appropriate. The overlay will also be automatically dismissed if the user taps outside its bounds.

That's it for now.
