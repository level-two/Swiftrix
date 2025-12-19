# ``SwiftrixSpriteKitRendering``

SwiftrixSpriteKitRendering is an optional SpriteKit adapter for SwiftrixCore.

It mirrors the Core scene graph into SpriteKit (`SKScene`/`SKNode`) and can drive the Core `GameLoop` using a display-linked clock. This keeps gameplay logic in `SwiftrixCore` while letting SpriteKit handle rendering and platform event delivery.

For a guide-level walkthrough, see `docs/host-integration-spritekit.md`.

## Topics

### Scene Adapter

- ``SpriteKitScene``
- ``SceneAdapterState``
- ``PerformanceBudget``

### Views and Node Binding

- ``SpriteKitRenderable``
- ``SpriteView``
- ``ContainerView``
- ``NodeBinding``
- ``NodeBindingRegistry``
- ``SpriteViewSignature``

### Host Utilities

- ``CameraController``
- ``CameraConfig``
- ``DebugOverlayConfig``
- ``DebugOverlayRenderer``
- ``HitTestBridge``
- ``HostLifecycleBridge``

### Display Link Drivers

- ``DisplayLinkDriving``
- ``CADisplayLinkDriver``
- ``ManualDisplayLinkDriver``

