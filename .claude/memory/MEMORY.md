# Memory Index

- [Fork purpose & upstreamed app patch](fork-purpose-app-patch-upstreamed.md) — AirNav fork of react-native-maps; rbapp's 1.27.2 patch fully upstreamed and deleted (2026-07); fork sources are the single source of truth
- [Fabric overlay teardown null-guard](fabric-overlay-teardown-nullguard.md) — stopSurface can destroy overlays never attached to a map; all overlay destroy paths need the SoftReference + null-guard idempotent pattern
- [iOS marker zIndex via stickyZPosition](ios-marker-zindex-stickyzposition.md) — layer.zPosition writes are silently discarded by ZPositionableLayer; always use stickyZPosition
- [iOS Fabric map recycle: base props](ios-fabric-map-recycle-base-props.md) — RNMapsMapView.prepareForRecycle must reset base-view props; prepareMapView resets \_props so stale transform/opacity survived reuse (rbapp map shown sideways); marker and Google views share the pattern, unfixed
