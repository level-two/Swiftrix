# Swiftrix API Reference (Markdown)

This document is a single, AI-friendly Markdown reference for the **public interfaces** of Swiftrix.

Swiftrix ships as two SwiftPM libraries:

- `SwiftrixCore` — platform-agnostic engine core.
- `SwiftrixSpriteKitRendering` — optional SpriteKit adapter (Apple platforms).

Related docs:

- Public API tour: `docs/public-api.md`
- Engine concepts (model + update flow): `docs/engine-concepts.md`
- SpriteKit integration guide: `docs/host-integration-spritekit.md`

---

## Quickstart (Core)

```swift
import SwiftrixCore

final class MoveRight: Script {
    override func update(deltaTime: TimeInterval) {
        guard let gameObject else { return }
        var t = gameObject.localTransform
        t.position.x += 2.0 * deltaTime
        gameObject.localTransform = t
    }
}

let scene = Scene()
let player = GameObject(name: "Player")
player.addComponent(MoveRight())
scene.addRootObject(player)

let loop = GameLoop(scene: scene)
loop.tick(deltaTime: 1.0 / 60.0)
```

---

## Module: SwiftrixCore

### Core protocols (`Sources/SwiftrixCore/Core/CoreProtocols.swift`)

- `IdentifiableObject`
  - `id: UUID`
- `Named`
  - `name: String { get set }`
- `Updatable`
  - `update(deltaTime: TimeInterval)`
- `FixedUpdatable`
  - `fixedUpdate(fixedDeltaTime: TimeInterval)`
- `Destroyable`
  - `isDestroyed: Bool`
  - `destroy()`

### Scene (`Sources/SwiftrixCore/Scene/Scene.swift`)

Type:

- `open class Scene: Updatable`

State:

- `rootObjects: [GameObject]` (read-only)
- `eventBus: EventBus`
- `inputSystem: InputSystem?`
- `physicsWorld: PhysicsWorld`

Lifecycle/entry points:

- `init(eventBus:inputSystem:physicsWorld:)`
- `addRootObject(_:)`
  - Registers any `Collider` components found in the added subtree into `physicsWorld`.
- `removeRootObject(_:)`
  - Unregisters colliders in that subtree from `physicsWorld`.
- `update(deltaTime:)`
  - Polls input (`inputSystem.update()`), dispatches pending `ControlEvent`s to `ControlComponent`s, then runs update traversal.
- `fixedUpdate(fixedDeltaTime:)`
  - Steps physics (`physicsWorld.step`) then runs fixed update traversal.
- `draw()`
  - Runs draw traversal (Core does not render; it only calls `View.draw()`).

### GameObject (`Sources/SwiftrixCore/GameObject/GameObject.swift`)

Type:

- `open class GameObject: IdentifiableObject, Named, Updatable, Destroyable`

Identity + hierarchy:

- `id: UUID`
- `name: String`
- `parent: GameObject?` (read-only)
- `children: [GameObject]` (read-only)
- `addChild(_:)` / `removeChild(_:)` / `removeFromParent()`
  - Prevents self-parenting, cycles, and duplicate child entries.

Transform:

- `localTransform: Transform2D`
- `globalTransform: Transform2D` (derived; parent-first composition)
- Convenience accessors (`Sources/SwiftrixCore/GameObject/GameObject+helpers.swift`):
  - `position: Vector2`
  - `rotation: Double` (radians)
  - `scale: Vector2`
  - `globalPosition`, `globalRotation`, `globalScale`

Components:

- `components: [Component]` (read-only)
- `addComponent(_:)` / `removeComponent(_:)`
- `getComponent(_:)` / `getComponents(_:)`

Lifecycle:

- `isEnabled: Bool`
- `isDestroyed: Bool` (read-only)
- `destroy()`
- Hooks:
  - `open func onStart()`
  - `open func onDestroy()`

### Components (`Sources/SwiftrixCore/Components/*`)

#### Component

- `open class Component: Updatable`
- `gameObject: GameObject!` (weak; set by `GameObject.addComponent`)
- `isEnabled: Bool`
- `open func update(deltaTime:)`

#### Script

- `open class Script: Component`
- Override points:
  - `open func preUpdate(deltaTime:)`
  - `open func onStart()`
  - `open func onDestroy()`
  - `open func onControl(_ event: ControlEvent)`
  - `open func onCollision(with other: Collider)`
  - `open override func update(deltaTime:)` (inherited)
  - `open func postUpdate(deltaTime:)`
- Convenience bridges:
  - hierarchy: `parent`, `children`, `addChild`, `removeChild`, `removeFromParent`
  - components: `components`, `getComponent`, `getComponents`, `addComponent`, `removeComponent`
  - transforms: `position`, `rotation`, `scale`, `localTransform`, `globalTransform`

Notes:

- `preUpdate` is called once per frame before any `Component.update` runs for the owning `GameObject`.
- `postUpdate` is called once per frame after all `Component.update` calls have completed for the owning `GameObject`.
- If a `GameObject` is destroyed (via `destroy()`) before or during an update phase, the remaining phases for that object (and its child updates for that frame) are skipped.
- Scripts receive `onControl` only when events are dispatched (via `Scene.update` + `InputSystem.pendingEvents` + traversal).
- Scripts receive `onCollision` from the default physics world (`DefaultPhysicsWorld`) when overlaps are detected.

#### View

- `open class View: Component`
- `anchor: Vector2` (normalized: `(0,0)` top-left, `(0.5,0.5)` center)
- `open func draw()`

#### Collider / BoxCollider

- `open class Collider: Component`
  - `size: Vector2` (AABB width/height)
  - `anchor: Vector2` (normalized; default `(0.5, 0.5)`)
  - `localOffset: Vector2`
  - `collisionGroup: CollisionGroup`
  - `isTrigger: Bool` (currently advisory; default physics treats all overlaps the same)
- `open class BoxCollider: Collider` (convenience alias)
- `public enum CollisionGroup: Hashable`
  - `.player`, `.enemy`, `.environment`, `.custom(Int)`

#### ControlComponent

- `open class ControlComponent: Component`
- `open func handle(event: ControlEvent)`

### Game loop (`Sources/SwiftrixCore/Loop/GameLoop.swift`)

- `public final class GameLoop`
- `init(scene:fixedDeltaTime:)`
- `tick(deltaTime:)`
  - Accumulates time and runs `Scene.fixedUpdate` in fixed steps (`fixedDeltaTime`), then runs `Scene.update`, then `Scene.draw`.

### Events (`Sources/SwiftrixCore/Events/*`)

- `public protocol GameEvent`
- `public protocol EventBus`
  - `post(_ event: GameEvent)`
  - `subscribe(_ type: T.Type) -> AsyncStream<T>`
- `public final class DefaultEventBus: EventBus`

Physics-related event:

- `public struct CollisionEvent: GameEvent`
  - `a: Collider`, `b: Collider`

### Input (`Sources/SwiftrixCore/Input/*`)

- `public protocol InputSystem`
  - `update()`
  - `axis(named:) -> AxisValue`
  - `isButtonDown(_:)`, `isButtonUp(_:)`, `isButtonPressed(_:)`
  - `eventsStream() -> AsyncStream<ControlEvent>`
  - `pendingEvents() -> [ControlEvent]` (default returns `[]`)
- `public final class DefaultInputSystem: InputSystem`
  - `send(event:)` (helper for tests/hosts)
  - `snapshotAxes() -> [String: AxisValue]` (debug helper)
- `public enum ControlEvent`
  - `.buttonDown(String)`, `.buttonUp(String)`, `.axisChanged(name:value:)`
- `public struct AxisValue`
  - `value: Double`
- `public struct AxisConfig`
  - `name`, `positiveKeys`, `negativeKeys`, `sensitivity`
- `public enum InputKey`
  - arrow keys, `space`, `.custom(String)`

### Physics (`Sources/SwiftrixCore/Physics/*`)

- `public protocol PhysicsWorld`
  - `addCollider(_:)` / `removeCollider(_:)`
  - `step(fixedDeltaTime:eventBus:)`
  - `query(overlap:in:) -> [Collider]`
- `public final class DefaultPhysicsWorld: PhysicsWorld`
  - AABB overlap checks; ignores rotation for shape.

### Math (`Sources/SwiftrixCore/Math/*`)

- `public struct Vector2: Equatable, Codable`
  - `x`, `y`
  - `.zero`
  - operators: `+`, `-`, `* (vector * scalar)`
- `public struct Transform2D: Equatable, Codable`
  - `position: Vector2`, `rotation: Double` (radians), `scale: Vector2`
  - `.identity`
  - `applying(_ child:) -> Transform2D`

### Debugging (`Sources/SwiftrixCore/Introspection/DebugIntrospection.swift`)

- `public enum DebugIntrospection`
  - `describeScene(_:) -> String`
  - `describeObject(_:indent:) -> [String]`

---

## Module: SwiftrixSpriteKitRendering

This module is a **host-side adapter**. It imports SpriteKit and mirrors Core objects into `SKNode`s.

### SpriteKitScene (`Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift`)

Key types:

- `public enum SceneAdapterState { idle, running, paused, stopped }`
- `public struct PerformanceBudget { maxSyncOpsPerFrame: Int? }`
- `open class SpriteKitScene: SKScene`

Core state and configuration:

- `coreScene: Scene`
- `state: SceneAdapterState` (read-only)
- `performanceBudget: PerformanceBudget`
- `onDiagnostic: ((String) -> Void)?` (e.g. missing textures)
- `debugOverlayConfig: DebugOverlayConfig?`
- `cameraController: CameraController?`

Lifecycle:

- `start()`, `pause()`, `resume()`, `stop()`, `reset()`, `restart()`
- `bootstrapScene()` (override point; called once on first `start()`)
- `step(deltaTime:)` (manual stepping for tests/tools)

Debug/host helpers:

- `node(for objectID: UUID) -> SKNode?`
- `setDebugOverlayConfig(_:)`
- `configureCamera(_:)`
- `hitTestObjectID(at:) -> UUID?`

### Rendering components (`Sources/SwiftrixSpriteKitRendering/Views/*`)

- `public protocol SpriteKitRenderable`
  - `makeNode() -> SKNode`
  - `update(node:)`
- `public final class SpriteView: View, SpriteKitRenderable`
  - `textureName: String?`, `color: SKColor`, `size: CGSize?`, `zPosition: CGFloat`
  - animation helpers: `animate(with:timePerFrame:repeatForever:)`, `animate(textureNames:timePerFrame:repeatForever:)`, `stopAnimation()`
  - `anchorPoint: CGPoint` (maps to `View.anchor`)
- `open class ContainerView: View, SpriteKitRenderable`
  - Creates a plain `SKNode` (transform-only container).

### Binding registry (`Sources/SwiftrixSpriteKitRendering/NodeBindingRegistry.swift`)

- `public final class NodeBinding`
  - `objectID: UUID`
  - `gameObject: GameObject?` (weak)
  - `viewComponent: SpriteKitRenderable?`
  - `node: SKNode`
- `public final class NodeBindingRegistry`
  - `binding(for:viewComponent:) -> NodeBinding`
  - `binding(forID:) -> NodeBinding?`
  - `removeUnvisited(excluding:) -> [NodeBinding]`
  - `allBindings() -> [NodeBinding]`
  - `clear()`

### Camera (`Sources/SwiftrixSpriteKitRendering/Camera/CameraController.swift`)

- `public struct CameraConfig`
  - `mode: .staticOffset(CGPoint)` or `.followObject(UUID, offset: CGPoint)`
  - `zoom: CGFloat`
- `public final class CameraController`
  - `cameraNode: SKCameraNode`
  - `update(using:in:)`

### Debug overlays (`Sources/SwiftrixSpriteKitRendering/Debug/*`)

- `public struct DebugOverlayConfig`
  - `isEnabled`, `showBounds`, `showAnchors`, `lineColor`, `lineWidth`
- `public final class DebugOverlayRenderer`
  - `renderOverlay(for:in:config:)`
  - `removeOverlay(for:)`, `clear()`

### Input utilities (`Sources/SwiftrixSpriteKitRendering/Input/HitTestBridge.swift`)

- `public final class HitTestBridge`
  - `objectID(at:in:registry:) -> UUID?`

### Host lifecycle (`Sources/SwiftrixSpriteKitRendering/HostLifecycleBridge.swift`)

- `public final class HostLifecycleBridge`
  - `applicationDidEnterBackground()` → `SpriteKitScene.pause()`
  - `applicationWillEnterForeground()` → `SpriteKitScene.resume()`

### Frame clocks (`Sources/SwiftrixSpriteKitRendering/DisplayLinkDriver.swift`)

- `public protocol DisplayLinkDriving`
  - `onTick: ((TimeInterval) -> Void)?`
  - `preferredFramesPerSecond: Int`
  - `start()`, `pause()`, `resume()`, `stop()`
- `public final class CADisplayLinkDriver: DisplayLinkDriving`
  - Timer-backed on macOS; CADisplayLink-backed elsewhere.
- `public final class ManualDisplayLinkDriver: DisplayLinkDriving`
  - `tick(deltaTime:)` for deterministic tests.

---

## Common Recipes

### 1) Receive collisions in gameplay code

```swift
import SwiftrixCore

final class PlayerCollision: Script {
    override func onCollision(with other: Collider) {
        // respond to overlap
    }
}

let player = GameObject(name: "Player")
player.addComponent(BoxCollider(size: Vector2(x: 24, y: 24), collisionGroup: .player))
player.addComponent(PlayerCollision())
```

### 2) Subscribe to collision events via EventBus

```swift
import SwiftrixCore

let scene = Scene()
let stream = scene.eventBus.subscribe(CollisionEvent.self)

Task {
    for await event in stream {
        // event.a, event.b
    }
}
```

### 3) Feed input in tests with DefaultInputSystem

```swift
import SwiftrixCore

let input = DefaultInputSystem()
let scene = Scene(inputSystem: input)

input.send(event: .buttonDown("jump"))
scene.update(deltaTime: 1.0 / 60.0)
```

### 4) Use SpriteKitScene to keep SpriteKit out of gameplay code

```swift
import SpriteKit
import SwiftrixCore
import SwiftrixSpriteKitRendering

final class GameScene: SpriteKitScene {
    override func bootstrapScene() {
        let player = GameObject(name: "Player")
        player.addComponent(SpriteView(textureName: "player", size: CGSize(width: 24, height: 24)))
        coreScene.addRootObject(player)
    }
}
```

---

## Behavioral Notes (for clients)

- **Core does not render**: `View` is descriptive state + `draw()` hook; hosts decide what to do.
- **Determinism**: fixed stepping is driven by `GameLoop`’s `fixedDeltaTime`. If you need strict determinism, keep input event streams and tick deltas deterministic.
- **Physics**: `DefaultPhysicsWorld` is AABB-only and minimal by design; implement `PhysicsWorld` to swap it out.
- **Threading**: most engine types are not designed as thread-safe; treat engine state as main-thread/loop-thread owned unless you build explicit synchronization in your host.
