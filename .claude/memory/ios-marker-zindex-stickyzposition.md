---
name: ios-marker-zindex-stickyzposition
description: iOS marker z-ordering must be written via stickyZPosition — direct layer.zPosition writes are silently discarded by ZPositionableLayer
metadata:
  type: project
---

On iOS, marker annotation views use `ZPositionableLayer` (ios/AirMaps/AnnotationView.m), which **silently discards** direct writes to `self.layer.zPosition`. Setting `layer.zPosition` compiles and runs but has no visual effect — a classic "looks correct but does nothing" trap.

**Why:** MapKit resets layer zPosition internally; `stickyZPosition` (AnnotationView) is the property that survives and re-applies it. Fixed in the fork via a8a947c9 ("apply zIndex patch to iOS", July 2026) in `AIRMapMarker.m` (`getAnnotationView` custom-marker branch and `setZIndex`).

**How to apply:** Any code that orders markers on iOS must write `self.stickyZPosition = ...`, never `self.layer.zPosition = ...`. Note `setZIndex` assigns `_zIndex` (the callout-adjusted value), not the raw prop.
