# Research Summary — Swiftrix SpriteKit Rendering Adapter

## Decision 1: Testing Harness Uses Headless SKView + Fakes

- **Decision**: Author adapter unit tests with XCTest by instantiating `SKView`/`SKScene` offscreen (no window) and injecting a lightweight `SpriteKitTestHarness` that exposes node graphs without requiring a live display link. Property sync logic is validated via deterministic clock ticks, while lifecycle edge cases use test doubles for `CADisplayLink`.
- **Rationale**: SpriteKit scenes can run without being presented, which lets us assert node creation/removal, transforms, and hierarchy changes entirely inside XCTest. Injecting a fake clock avoids flakiness from real frame timing.
- **Alternatives considered**: (a) Full UI tests that render to a simulator window (too slow, brittle); (b) fully mocking SpriteKit nodes (loses confidence that we mirror actual APIs and retains risk of drift).

## Decision 2: Display Link Scheduling Happens on Main Run Loop Only

- **Decision**: The adapter owns a single `CADisplayLink` registered on the main run loop in `.common` modes. SpriteKitSceneAdapter steps Core updates within the display link callback, then runs the sync routine before SpriteKit draws.
- **Rationale**: Apple documents SpriteKit as main-thread only; tying Core updates to the same run loop guarantees deterministic order (Core update, then SpriteKit render) and prevents race conditions with view lifecycle events.
- **Alternatives considered**: (a) Using `SKScene.update(_:)` (would mix SpriteKit timing into Core and break determinism); (b) background queues + manual dispatch (SpriteKit APIs are not thread-safe and would deadlock).

## Decision 3: Performance Budget = 60 FPS with 500 Nodes & 6 Levels Deep

- **Decision**: Commit to sustaining 60 FPS while synchronizing up to 500 visible nodes with a maximum hierarchy depth of 6 levels. Beyond that, the adapter batches sync work over multiple frames using configurable node budgets.
- **Rationale**: Pacman demo currently <100 nodes, but future demos (tile maps, bullet hell) need headroom. 500 nodes aligns with Apple guidance for SpriteKit on modern devices without custom Metal shaders.
- **Alternatives considered**: (a) Unlimited node support (unbounded; would require complex spatial partitioning we do not own yet); (b) keep budget at 200 nodes (insufficient for moderate scenes).

## Decision 4: Scale Expectation = 1,000 Core GameObjects per Scene (with Views optional)

- **Decision**: Document an upper bound of ~1,000 concurrent `GameObject`s, assuming half carry visual `View` components. Non-visual objects remain Core-only and do not incur SpriteKit cost.
- **Rationale**: Sets a concrete ceiling for host teams so they understand when to split scenes or rely on pooling. The hierarchy-mirror plus dirty-flag approach supports this scale without rewriting Core.
- **Alternatives considered**: (a) Leave scale undefined (would block planning and QA load tests); (b) cap at Pacman-sized scenes (would render feature obsolete for more complex demos).

## Decision 5: Public API Surface Resides Exclusively in New Host Module (MINOR bump)

- **Decision**: Introduce public types (`SpriteKitSceneAdapter`, `SpriteView`, `LabelView`, `ShapeView`, `ContainerView`, debug overlays) inside a new SwiftPM target `SwiftrixSpriteKitRendering`. SwiftrixCore contracts remain unchanged, so semantic version impact is MINOR (new functionality, backward-compatible).
- **Rationale**: Keeps core target clean while still delivering a supported adapter for Apple hosts. Declaring SemVer impact early satisfies Constitution requirements.
- **Alternatives considered**: (a) Adding SpriteKit-specific hooks to SwiftrixCore (would violate core-only rule); (b) shipping adapter as example code only (would not meet “module” scope or testing mandates).

## Decision 6: Bidirectional Mapping via Stable IDs + Node Registry

- **Decision**: Each `GameObject` exposes/receives a stable UUID from Core (existing identifier). The adapter maintains two dictionaries:
  - `objectID -> NodeBinding` (contains `SKNode`, View metadata, dirty flags)
  - `SKNode -> objectID` (weak references via custom wrapper to avoid retain cycles)
  Node bindings include dirty-flag sets for transform, visibility, asset changes, and track parent IDs so reparenting is O(1).
- **Rationale**: Ensures constant-time lookup for sync and hit-testing while simplifying debug overlays (just inspect binding table). Weak wrappers prevent leaks if SpriteKit nodes outlive their Core peers.
- **Alternatives considered**: (a) Tree traversal without indices (O(n) lookups; fails perf goals); (b) storing IDs on `SKNode.userData` only (hard to invalidate, weak semantics for tests).

## Decision 7: Camera & Debug Observability Strategy

- **Decision**: Provide a minimal `CameraController` inside the adapter that either follows a designated `GameObject` (using Core transform) or remains static. Debug overlays (bounds, anchors, names) are rendered via optional `SKShapeNode` children toggled by adapter configuration, and mapping inspection is serviced through a `NodeInspector` utility that dumps node/object relationships.
- **Rationale**: Meets observability principle without burdening Core. Using SpriteKit-native nodes keeps overlays cheap and accessible from the host debug UI.
- **Alternatives considered**: (a) Building a custom debug UI layer (too heavy for v1); (b) using console logging only (insufficient for visual debugging).
