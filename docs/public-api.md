# Public API Tour (Swiftrix)

This document walks through the *public interfaces* exported by Swiftrix so clients can quickly find the right types to use.

Swiftrix is split into two modules:

- `SwiftrixCore` (engine core, platform-agnostic)
- `SwiftrixSpriteKitRendering` (optional SpriteKit adapter)

---

## SwiftrixCore

### Core protocols (shared vocabulary)

Defined in `Sources/SwiftrixCore/Core/CoreProtocols.swift`:

- `IdentifiableObject`: stable `id: UUID` used for binding, lookup, and tooling.
- `Named`: `name` for debugging/introspection.
- `Updatable`: `update(deltaTime:)` called once per tick.
- `FixedUpdatable`: `fixedUpdate(fixedDeltaTime:)` called in fixed steps (determinism).
- `Destroyable`: supports `destroy()` and `isDestroyed`.

You rarely conform to these directly; they mostly define the engine’s internal contracts.

### Scene (world container)

Defined in `Sources/SwiftrixCore/Scene/Scene.swift`:

- `Scene` (protocol): owns `rootObjects`, and wires together:
  - `eventBus: EventBus` (default `DefaultEventBus`)
  - `inputSystem: InputSystem?` (host-provided or `DefaultInputSystem` in tests)
  - `corePhysicsWorld: PhysicsWorld` (default `DefaultPhysicsWorld`)
- Key entry points:
  - `addRootObject(_:)` / `removeRootObject(_:)`
  - `update(deltaTime:)`, `fixedUpdate(fixedDeltaTime:)`, `draw()`
  - Use `SceneGraphTraversal` to perform the default traversals from your own `Scene` implementation.

**Important behavior (recommended default):** when implementing `Scene`, adding/removing root objects should register/unregister `Collider` components with the `PhysicsWorld`.

### GameObject (scene graph node)

Defined in `Sources/SwiftrixCore/GameObject/GameObject.swift` and `Sources/SwiftrixCore/GameObject/GameObject+helpers.swift`:

- `GameObject`: hierarchical node with:
  - `children` / `parent` graph structure (cycle-safe)
  - `localTransform: Transform2D` and derived `globalTransform`
  - `components: [Component]`
  - lifecycle hooks `onStart()` and `onDestroy()`
  - fixed-step hook `fixedUpdate(fixedDeltaTime:)` (deterministic systems)
- Convenience transform accessors:
  - `position`, `rotation`, `scale`
  - `globalPosition`, `globalRotation`, `globalScale`
- Component helpers:
  - `addComponent(_:)`, `removeComponent(_:)`
  - `getComponent(_:)`, `getComponents(_:)`

### Components (behavior/data attachments)

Defined in `Sources/SwiftrixCore/Components/*`:

- `Component`: base class with `gameObject` (set automatically) and `isEnabled`.
- `Script`: gameplay logic; override:
  - `preUpdate(deltaTime:)` (runs before any components update for the owning object)
  - `fixedUpdate(fixedDeltaTime:)` (runs during fixed-step traversal)
  - `update(deltaTime:)` (inherited from `Component`)
  - `postUpdate(deltaTime:)` (runs after all components update for the owning object)
  - `onStart()` / `onDestroy()` (script lifecycle)
  - `onControl(_:)` (control events)
  - `onCollision(with:)` (physics callback)
  - Also exposes convenient bridges to hierarchy, transforms, and component lookup.
- `View`: rendering-facing state interpreted by the host (Core never renders).
  - `anchor` is a normalized point inside view bounds (`(0.5, 0.5)` is center).
  - `draw()` is called during draw traversal.
- `Collider` / `BoxCollider`: AABB collision shape for `PhysicsWorld`.
  - `size`, `anchor`, `localOffset`, `collisionGroup`, `isTrigger`.
- `ControlComponent`: receives `ControlEvent` after input mapping.

### Game loop (deterministic stepping)

Defined in `Sources/SwiftrixCore/Loop/GameLoop.swift`:

- `GameLoop(scene:fixedDeltaTime:)`
- `tick(deltaTime:)`:
  - accumulates time and runs `scene.fixedUpdate` in fixed steps
  - then runs `scene.update` and `scene.draw`

Hosts call `tick(deltaTime:)` once per rendered frame (or from a test harness).

### Events

Defined in `Sources/SwiftrixCore/Events/*`:

- `GameEvent`: marker protocol.
- `EventBus`: `post(_:)` + `subscribe(_:) -> AsyncStream`.
- `DefaultEventBus`: simple in-memory implementation.

The built-in physics system posts `CollisionEvent` events via the bus.

### Input

Defined in `Sources/SwiftrixCore/Input/*`:

- `InputSystem`: host-owned abstraction for logical axes/buttons and event delivery.
- `DefaultInputSystem`: simple in-memory input system (useful in tests and prototypes).
- `ControlEvent`: `.buttonDown`, `.buttonUp`, `.axisChanged`.
- `AxisValue`: wrapper for normalized axis values.
- `AxisConfig` / `InputKey`: helpers for describing logical axes and bindings.

### Physics

Defined in `Sources/SwiftrixCore/Physics/*`:

- `PhysicsWorld`: interface for registering colliders, stepping simulation, and overlap queries.
- `DefaultPhysicsWorld`: AABB overlap checks + emits:
  - `CollisionEvent(a:b:)` (posted on the `EventBus`)
  - `Script.onCollision(with:)` callbacks on the involved objects

### Math + Debugging utilities

- `Vector2` and `Transform2D` in `Sources/SwiftrixCore/Math/*`
- `DebugIntrospection` in `Sources/SwiftrixCore/Introspection/DebugIntrospection.swift`

---

## SwiftrixSpriteKitRendering

This module is a host-side adapter: it mirrors Core’s scene graph into a SpriteKit node tree and optionally drives the core loop via a display-linked clock.

### Main entry point

Defined in `Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift`:

- `SpriteKitScene`: an `SKScene` subclass that also conforms to `Scene`, with:
  - lifecycle: `start()`, `pause()`, `resume()`, `stop()`, `reset()`, `restart()`
  - `bootstrapScene()` override point for constructing your Core objects
  - `setDebugOverlayConfig(_:)`, `hitTestObjectID(at:)`
  - `performanceBudget` to spread sync work across frames

### Views and node binding

Defined in `Sources/SwiftrixSpriteKitRendering/Views/*` and `Sources/SwiftrixSpriteKitRendering/NodeBindingRegistry.swift`:

- `SpriteView`: a Core `View` that renders as `SKSpriteNode` (texture/color/size/anchor/zPosition + basic animation helpers).
- `ContainerView`: a transform-only view that renders as a plain `SKNode`.
- `SpriteKitRenderable`: protocol for Core components that can produce/update an `SKNode`.
- `NodeBindingRegistry` / `NodeBinding`: maps Core `GameObject.id` to `SKNode` instances.

### Camera, debug overlays, hit testing, and clocks

- `Camera` component in `Sources/SwiftrixCore/Components/Camera.swift` (attach to a `GameObject`; SpriteKit adapter auto-selects the active camera)
- `DebugOverlayConfig` + `DebugOverlayRenderer` in `Sources/SwiftrixSpriteKitRendering/Debug/*`
- `HitTestBridge` in `Sources/SwiftrixSpriteKitRendering/Input/HitTestBridge.swift`
- `DisplayLinkDriving`, `CADisplayLinkDriver`, `ManualDisplayLinkDriver` in `Sources/SwiftrixSpriteKitRendering/DisplayLinkDriver.swift`
- `HostLifecycleBridge` in `Sources/SwiftrixSpriteKitRendering/HostLifecycleBridge.swift`
