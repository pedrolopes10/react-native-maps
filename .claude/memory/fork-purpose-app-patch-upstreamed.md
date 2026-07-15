---
name: fork-purpose-app-patch-upstreamed
description: This fork carries AirNav Radar (rbapp) customizations directly; the app's react-native-maps+1.27.2.patch was fully upstreamed into the fork and deleted (July 2026)
metadata:
  type: project
---

This repo is AirNav Systems' fork of react-native-maps, consumed by the AirNav Radar app (rbapp). It exists to carry app-specific customizations that upstream doesn't have: the `imageScale` marker prop (54408536), `setZIndex` on Android MarkerManager (a03433ef) and iOS via [[ios-marker-zindex-stickyzposition]] (a8a947c9), `pointerEvents="none"` forwarding to detached annotation views (RNMapsMarkerView.mm), and the Android UrlTile urlTemplate-update fix (f6350710).

**Why:** These changes previously lived in the app as a patch-package patch (`react-native-maps+1.27.2.patch`). On 2026-07-15 the last of it was applied to the fork's sources and the patch file was deleted — the fork's source tree is now the single source of truth; the app-side patch is obsolete and should not be resurrected.

**How to apply:** When syncing with upstream react-native-maps, preserve these fork-specific features (rebase/merge conflicts around them are expected). New app-driven map tweaks go directly into the fork, not into a patch-package patch in rbapp.
