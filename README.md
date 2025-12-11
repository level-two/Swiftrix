# SwiftrixCore — Lightweight Swift Game Engine

SwiftrixCore is a small, focused game engine written in Swift 5.9.  
It provides a clear, component-based model for building interactive 2D worlds
without tying you to any specific rendering, input, or audio framework.

- **Scene graph** with hierarchical game objects
- **Component-based design** (scripts, views, colliders, controls)
- **Deterministic game loop** with fixed-step physics
- **Event bus** for decoupled gameplay logic
- **Pluggable input and physics** via protocols
- **Introspection utilities** for debugging and tools

The engine is intended for rapid prototyping, small-to-medium games, and
AI-assisted workflows where clarity and testability matter more than features.

---

## Installation

SwiftrixCore is a Swift Package Manager (SwiftPM) library. The repository also
ships an optional SpriteKit adapter module for Apple-platform hosts.

### Requirements

- Swift 5.9+
- macOS 13+ or iOS 16+ (per `Package.swift`)

### Adding the package

Add SwiftrixCore to your `Package.swift` either via a local path or your Git
remote:

```swift
// Example Package.swift snippet
dependencies: [
    // Using your own remote URL or fork:
    .package(url: "https://github.com/<your-account>/Swiftrix.git", branch: "main"),

    // or, if you keep Swiftrix as a local package:
    // .package(path: "../Swiftrix"),
],
targets: [
    .target(
        name: "YourGame",
        dependencies: [
            .product(name: "SwiftrixCore", package: "Swiftrix")
        ]
    )
]
```

Adjust the package name, URL, and path to match how you host this repository.

---

## Core Concepts

### Scene

`Scene` represents a world containing a tree of game objects and coordinating
systems such as input, physics, and events.

The engine provides an open `Scene` class, which wires together:

- `EventBus` (default: `DefaultEventBus`)
- `InputSystem` (default: `DefaultInputSystem` or a host-provided implementation)
- `PhysicsWorld` (default: `DefaultPhysicsWorld`)

### GameObject

`GameObject` is a node in the scene graph:

- has a name and unique identifier
- holds a `Transform2D` for position/rotation/scale
- can have children
- can own multiple components

The standard concrete implementation is `GameObject`.

### Components

Components attach behaviour and data to game objects. Key component classes:

- `Component` — base class for attachable behaviors
- `Script` — custom gameplay logic (movement, AI, reactions)
- `View` — rendering-related state (to be interpreted by your host)
- `Collider` — 2D collision shapes used by `PhysicsWorld`
- `ControlComponent` — maps high-level input to gameplay responses

`Script` subclasses can access their `gameObject`’s hierarchy and transforms via
bridged properties: `parent`, `children`, `localTransform`/`globalTransform`,
`position`, `rotation`, `scale`, `globalPosition`,
`globalRotation`, `globalScale`, plus component helpers
`getComponent(_:)` / `getComponents(_:)`.

### Game Loop

`GameLoop` drives a `Scene` using a fixed timestep for deterministic systems
and a variable update for scripts:

- `fixedUpdate(fixedDeltaTime:)` for physics and other deterministic systems
- `update(deltaTime:)` for scripts and general logic
- `draw()` for rendering hooks

You can embed `GameLoop` into your host application (e.g. SpriteKit or a custom
rendering layer) and decide how often to call `tick(deltaTime:)`.

### Events and Input

- `GameEvent` and `EventBus` (`DefaultEventBus`) provide a simple event pipeline
  for decoupled communication.
- `InputSystem` is an abstraction for logical input state; hosts implement it
  to translate platform-specific input into engine-level axes and actions.

---

## Quickstart Example

The following minimal example shows how to create a scene, add a game object
with a custom script, and drive it with `GameLoop`. You can run a variant of
this from your own app target or test target.

```swift
import SwiftrixCore

// 1. Define a simple script
final class MoveRightScript: Script {
    override func update(deltaTime: TimeInterval) {
        guard let gameObject else { return }
        var transform = gameObject.localTransform
        transform.position.x += 1.0 * deltaTime
        gameObject.localTransform = transform
    }
}

// 2. Bootstrap scene and loop
let scene = Scene()
let root = GameObject(name: "Player")
root.addComponent(MoveRightScript())
scene.addRootObject(root)

let loop = GameLoop(scene: scene)

// 3. Step the loop from your host (e.g. 60 FPS)
loop.tick(deltaTime: 1.0 / 60.0)
```

In a real application, you would:

- integrate a rendering backend (e.g. SpriteKit) and interpret `View`
  components for drawing,
- implement or wrap an `InputSystem` to feed input into your scene,
- call `tick(deltaTime:)` from your platform’s frame/update callback.

---

## Embedding with SpriteKit (Host Example)

The engine core stays independent of SpriteKit; you integrate it from a host
app target. The snippet below shows one way to drive `GameLoop` from an
`SKScene`:

```swift
import SpriteKit
import SwiftrixCore

final class GameScene: SKScene {
    private var swiftrixScene: Scene!
    private var loop: GameLoop!
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        let input = DefaultInputSystem()
        swiftrixScene = Scene(inputSystem: input)
        loop = GameLoop(scene: swiftrixScene)

        let player = GameObject(name: "Player")
        // Attach components (Script, View, Collider, etc.)
        swiftrixScene.addRootObject(player)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        loop.tick(deltaTime: deltaTime)
        renderSwiftrixObjects()
    }

    private func renderSwiftrixObjects() {
        // Traverse swiftrixScene.rootObjects and map View components to SKNodes.
        // This is where you keep SpriteKit concerns, outside SwiftrixCore.
    }
}
```

In this setup:

- `SwiftrixCore` owns game state, logic, and physics.
- The SpriteKit scene owns drawing and platform-level input.
- Communication between the two flows through components (`View`,
  `ControlComponent`) and systems (`InputSystem`, `EventBus`).

## SpriteKit Rendering Scene (Optional Module)

For hosts that want a more turnkey integration on Apple platforms, this
repository includes a separate SwiftPM target:

- `SwiftrixSpriteKitRendering` — a SpriteKit-backed `SpriteKitScene` that:
  - mirrors the core game object hierarchy into an `SKScene`
  - drives the core `GameLoop` from a display-linked clock
  - exposes lifecycle controls (start/pause/resume/stop/reset)
  - provides debug overlays, camera helpers, and basic hit-testing

Minimal setup in a host app:

```swift
import SwiftrixCore
import SwiftrixSpriteKitRendering
import SpriteKit

final class GameScene: SpriteKitScene {
    override func bootstrapScene() {
        let player = GameObject(name: "Player")
        player.addComponent(SpriteView(textureName: "player", size: CGSize(width: 24, height: 24)))
        coreScene.addRootObject(player)
    }
}

let spriteKitScene = GameScene()

let skView = SKView(frame: UIScreen.main.bounds)
skView.presentScene(spriteKitScene)

spriteKitScene.start()
```

For more details (performance budgets, overlays, camera follow, hit-testing),
see `specs/001-spritekit-renderer/quickstart.md`.

---

## Project Layout

Relevant directories in this repository:

- `Sources/SwiftrixCore` — engine core (scenes, game objects, components, events, physics, input, loop, introspection)
- `Sources/SwiftrixSpriteKitRendering` — SpriteKit adapter module (host-side)
- `Tests/SwiftrixCoreTests` — XCTest-based test suite for the engine core
- `Tests/SwiftrixSpriteKitRenderingTests` — tests for the SpriteKit adapter
- `specs/000-swiftrix-engine-core` — high-level specification and design docs for the core
- `specs/001-spritekit-renderer` — spec/plan/quickstart for the SpriteKit adapter

Additional documentation:

- `docs/engine-concepts.md` — overview of core engine concepts and patterns.
- `docs/host-integration-spritekit.md` — detailed host integration examples with SpriteKit.
- `docs/debugging-and-introspection.md` — practical tips for debugging and inspecting Swiftrix scenes and adapter state.

For more detailed architecture notes, see:

- `specs/000-swiftrix-engine-core/spec.md`
- `specs/000-swiftrix-engine-core/plan.md`
- `specs/000-swiftrix-engine-core/tasks.md`

---

## Documentation Map

### For game developers / engine users

- Start here: this `README.md` (installation, concepts, quickstart).
- Learn the model: `docs/engine-concepts.md`.
- Integrate with SpriteKit: `docs/host-integration-spritekit.md`.
- Debug and inspect scenes/adapter state: `docs/debugging-and-introspection.md`.
- Use the adapter’s feature quickstart: `specs/001-spritekit-renderer/quickstart.md`.

### For contributors / engine maintainers

- Contribution workflow and constraints:
  - `CONTRIBUTING.md` — overview of expectations and entry points.
  - `AGENTS.md` — detailed guidelines for humans and AI agents.
- Core engine design:
  - `specs/000-swiftrix-engine-core/spec.md`
  - `specs/000-swiftrix-engine-core/plan.md`
  - `specs/000-swiftrix-engine-core/tasks.md`
- SpriteKit adapter design:
  - `specs/001-spritekit-renderer/spec.md`
  - `specs/001-spritekit-renderer/plan.md`
  - `specs/001-spritekit-renderer/tasks.md`

These “maintainer” docs are authoritative for architecture and API changes; user docs should stay aligned with them.

---

## Running Tests

From the repository root:

```bash
swift test
```

Tests cover core behaviors such as:

- scene traversal and game loop integration
- component lifecycle and game object hierarchy
- physics world registration and collision events
- input system behavior and event dispatch

When making changes to SwiftrixCore, prefer to add or extend tests in
`Tests/SwiftrixCoreTests` to keep coverage high.

---

## Design Goals and Non-Goals

SwiftrixCore focuses on:

- clear, predictable behavior
- small, composable components
- engine core decoupled from any specific rendering or input framework
- being friendly to debugging, tooling, and AI agents

It deliberately does **not** include:

- built-in rendering, audio, or asset loading
- a scene editor or inspector UI
- networking or persistence

Those responsibilities belong to host applications and tooling built on top of
the engine.
