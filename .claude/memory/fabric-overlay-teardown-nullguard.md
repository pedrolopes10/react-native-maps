---
name: fabric-overlay-teardown-nullguard
description: Fabric surface teardown can destroy overlay views never attached to a map — every overlay's destroy path must use the SoftReference + null-guard pattern or it NPEs
metadata:
  type: project
---

During Fabric surface teardown (`stopSurface`), an overlay view (circle, marker, polygon, polyline) can be dropped via `onDropViewInstance` when it was never attached to a map, or after the map already released its manager collections. Calling `collection.remove(...)` then throws an NPE (real-world crash: `MapCircle.removeFromMap` at MapCircle.java:126, fixed in c7ce034e, July 2026 — MapCircle was the one overlay missed when the others were hardened in 529a21b3).

**Why:** The collection field is only assigned in `addToMap`, and destroy can also run twice (`MapView.removeFeatureAt` + `onDropViewInstance`), so destroy must be null-safe and idempotent.

**How to apply:** Any new overlay type (or edits to destroy paths) must follow the existing pattern in `MapMarker`/`MapPolygon`/`MapPolyline`/`MapCircle` (android/src/main/java/com/rnmaps/maps/): hold the manager collection in a `SoftReference` set in `addToMap`; in `doDestroy()` dereference, only call `removeFromMap` if present, then clear the reference; in `removeFromMap` return early if the native object is null and null it after removal.
