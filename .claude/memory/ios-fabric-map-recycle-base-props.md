---
name: ios-fabric-map-recycle-base-props
description: iOS Fabric RNMapsMapView must reset its base-view props in prepareForRecycle; prepareMapView's _props = defaultProps otherwise hides stale transform/opacity from RN's diff (rbapp "map shown sideways")
metadata:
  type: project
---

**Why `RNMapsMapView.prepareForRecycle` calls `[super updateProps:defaultProps oldProps:_props]` (Nov 2026, rbapp task 18820802).**

`prepareMapView` runs on the first `updateProps` after a recycle and sets `_props = defaultProps`, because the map-specific diffs need a default baseline for the fresh `AIRMap`. But `RCTViewComponentView.updateProps` diffs the base-view props (transform, opacity, backgroundColor, pointerEvents, shadows...) against the view's **own `_props`**, not the `oldProps` argument (the mounting layer passes `nullptr` on insert anyway). So after that reset RN compares default vs. new, and anything the previous user of the view had set that the new one leaves at default is never written back: the `UIView`/`CALayer` keeps the old value.

Seen in rbapp as maps "shown sideways": its AR mini-map set `transform: rotate(...)` on the `MapView`; the next map mounted anywhere (Replay, following flight card) reused that pooled view and came up rotated by the same angle. Measured on an iPhone 11: AR at heading 197°, then a Replay map rotated 163°; with the reset in `prepareForRecycle`, upright with the app code unchanged.

**Rules:**

- Keep the reset in `prepareForRecycle`, after `[super prepareForRecycle]` (which clears the animated-prop keys that would otherwise block the transform write) and guarded by `_view` (set only once `prepareMapView` has run, so `_props` is an `RNMapsMapViewProps`; RN asserts in Debug if a subclass reaches `updateProps` still holding plain `ViewProps`).
- Never "simplify" it into `prepareMapView`: on the very first use `_props` is still the base `ViewProps` and the assert fires.
- **Same pattern, not fixed:** `RNMapsMarkerView.prepareMarkerView` and the Google Maps views (`RNMapsGoogleMapView`, `RNMapsGooglePolygonView`) also assign `_props = defaultProps` on reuse. A base-view style on a `Marker` (opacity, transform) would leak between markers the same way. Left alone because markers recycle constantly (hot path) and no leak has been observed; apply the same reset if one shows up.
