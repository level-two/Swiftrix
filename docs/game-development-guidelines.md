# Swiftrix Game Development Guidelines

This document describes recommended patterns for building games on top of the Swiftrix engine. It is **project‑agnostic** and intended as engine-level guidance for organizing gameplay code, scenes, and host integration.

Goals:

- Keep Swiftrix scenes easy to understand and refactor.
- Preserve clear boundaries between engine core, adapters, and game code.
- Encourage deterministic, testable gameplay code.

If you’re contributing to the engine itself (not just a game), see `docs/unit-test-coverage.md` for a checklist of unit tests to add/extend while implementing features.

---

## 1. Architectural Boundaries

- **Engine core (`SwiftrixCore`)**
  - Platform-agnostic types: `Scene`, `GameObject`, `Component`, `Script`, `Collider`, `GameLoop`, `EventBus`, `InputSystem`, `PhysicsWorld`.
  - Must not depend on SpriteKit/UIKit/SwiftUI/etc.

- **Host adapters (optional, e.g. `SwiftrixSpriteKitRendering`)**
  - Bridge core state to a platform renderer and input system.
  - Example: `SpriteKitScene` mirrors a core `Scene` into `SKScene`.

- **Game code (per game)**
  - Prefabs (reusable `GameObject` compositions).
  - Gameplay scripts (`Script` subclasses).
  - Scene assembly (builders / bootstrapping).
  - Host app glue (view controllers, lifecycle wiring, asset bundling).

Rule of thumb:

- Put **rules, state, and simulation** in core + game scripts.
- Put **rendering, platform input, and lifecycle** in hosts/adapters.

---

## 2. GameObjects as “Prefabs”

### 2.1 Prefer `GameObject` subclasses for reusable objects

Define prefabs as `final class` `GameObject` subclasses with stable default names:

```swift
import SwiftrixCore

final class Player: GameObject {
    init(name: String = "Player") {
        super.init(name: name)
        // Compose components and children here.
    }
}
```

### 2.2 Separate composition from placement

- Prefab initializers should build internal hierarchy and attach components.
- Avoid hard-coding world-space `position`/`rotation`/`scale` in prefab initializers.
- Set world-space transforms in:
  - `SpriteKitScene.bootstrapScene()` (when using the SpriteKit bridge), or
  - a dedicated “scene builder” type, or
  - spawning scripts/controllers.

---

## 3. Scripts: Keep Behaviors Small and Deterministic

`Script` subclasses are the main way to implement gameplay behavior. Prefer:

- One behavior per script (movement, AI, flashing, timed destruction, spawning).
- Constructor parameters for tunable values (speed, lifetime, radii).
- Private stored properties for runtime state (timers, phase, cached origin).
- Transform bridges (`position`, `rotation`, `scale`, and global variants) instead of poking `gameObject` directly.

Avoid non-deterministic time sources inside `update(deltaTime:)` (like `Date()`); accumulate time from `deltaTime` instead:

```swift
import Foundation
import SwiftrixCore

final class PulseScript: Script {
    private let speed: Double
    private var phase: Double = 0

    init(speed: Double) {
        self.speed = speed
        super.init()
    }

    override func update(deltaTime: TimeInterval) {
        phase += deltaTime * speed
        rotation = sin(phase) * 0.2
    }
}
```

---

## 4. Scenes and “Builders”

### 4.1 If you use `SwiftrixSpriteKitRendering`

- Create an `SKScene` subclass by inheriting from `SpriteKitScene`.
- Build the core hierarchy in `bootstrapScene()`.
- Call `start()` in `didMove(to:)`, and `stop()` in `willMove(from:)`.

```swift
import SwiftrixCore
import SwiftrixSpriteKitRendering

final class GameScene: SpriteKitScene {
    override func bootstrapScene() {
        let worldRoot = GameObject(name: "WorldRoot")
        worldRoot.addComponent(ContainerView())

        let player = Player()
        player.position = Vector2(x: 0, y: 0)
        worldRoot.addChild(player)

        addRootObject(worldRoot)
    }
}
```

### 4.2 If you do manual host integration

Use `GameLoop` and map `View` components to your renderer yourself (SpriteKit, Metal, etc.). This is the most portable approach, because your gameplay code can avoid importing any platform frameworks.

See `docs/host-integration-spritekit.md` for both patterns.

---

## 5. Physics and Colliders

### 5.1 Registering colliders

`Scene.addRootObject(_:)` registers existing colliders for the entire subtree at the time you add the root.

- If your prefab has colliders, attach them **before** adding the object tree to the scene.
- If you spawn objects at runtime and attach colliders after the scene is already running, register them with `scene.corePhysicsWorld`:

```swift
let collider = BoxCollider(size: Vector2(x: 32, y: 32), isTrigger: true)
spawn.addComponent(collider)
scene.corePhysicsWorld.addCollider(collider)
```

### 5.2 Defaults

Prefer omitting default arguments unless you are changing them:

- `localOffset: .zero`
- `collisionGroup: .environment`
- `isTrigger: false`
- `isEnabled: true`

---

## 6. Views and Rendering

- In core, `View` is intentionally abstract: hosts interpret it.
- If you use `SwiftrixSpriteKitRendering`, prefer using adapter views like `SpriteView` and `ContainerView`, and keep SpriteKit concerns inside the host/app module.
- If you want platform-agnostic gameplay code, avoid importing SpriteKit in gameplay modules; instead, use manual mapping (or define your own portable `View` data and map it in the host).

---

## 7. Project Organization (Game Code)

Recommended per-game layout (example):

```text
Game/
  Scenes/
    GameScene.swift
    MainSceneBuilder.swift
  GameObjects/
    Player/
      Player.swift
      PlayerControlScript.swift
    Enemies/
      Enemy.swift
      PatrolScript.swift
    Common/
      TimedDestroyScript.swift
      SpinScript.swift
```

Guidelines:

- One top-level type per file.
- Prefabs own composition; builders/controllers own placement and orchestration.
- Keep adapter/host imports (SpriteKit/UIKit) out of shared gameplay modules when portability matters.

---

## 8. Feature Checklist

When adding a new gameplay element:

1. Create a prefab `GameObject` subclass (stable default `name`).
2. Add behavior via small `Script` components with tunable init params.
3. Integrate via builder/bootstrap or spawning scripts.
4. If it needs collisions, ensure colliders are registered (see §5.1).
5. Keep the host responsible for camera, input mapping, diagnostics, and UI.
