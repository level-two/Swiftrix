# Engine Concepts & Patterns

This document summarizes the main concepts in SwiftrixCore and shows how they fit together when building a small game.

---

## 1. Core Types

### Scene

`Scene` represents the world:

- owns **root game objects**
- coordinates **input**, **physics**, and **events**
- receives **update**, **fixedUpdate**, and **draw** calls

Default implementation: `DefaultScene` (see `Sources/SwiftrixCore/Scene/DefaultScene.swift`).

### GameObject

`GameObject` is a node in the scene graph:

- has a `name` and `id: UUID`
- has a `localTransform` and derived `globalTransform`
- can have **children** (forming a tree)
- owns a collection of **components**

Default implementation: `GameObject`.

### Components

Components attach behavior and data to game objects:

- `Component` — base protocol; has `gameObject` and `isEnabled`
- `Script` — custom gameplay logic (movement, AI, reactions)
- `View` — rendering-related state; hosts interpret it (e.g., SpriteKit adapter)
- `Collider` — collision shape used by `PhysicsWorld`
- `ControlComponent` — translates input events into gameplay actions

You can attach multiple components of different types to a single object.

### Game Loop

`GameLoop` drives a `Scene`:

- accumulates time and runs `fixedUpdate` with a fixed timestep (physics)
- calls `update(deltaTime:)` for scripts and general logic
- calls `draw()` to let views render

You call `tick(deltaTime:)` from your host once per frame.

### Events & Input

- `EventBus` / `DefaultEventBus` — lightweight event pipeline for game events.
- `InputSystem` / `DefaultInputSystem` — abstract logical input state; hosts
  map platform-specific input into axes and actions.

---

## 2. Typical Object Composition

A common pattern for an interactive object:

- a `GameObject` (default implementation of `GameObject`) with:
  - one or more `Script` components for behavior
  - a `View` component for visuals
  - a `Collider` for physics
  - a `ControlComponent` if it responds directly to input

Example:

```swift
final class PlayerScript: Script {
    weak var gameObject: GameObject?
    var isEnabled: Bool = true

    func update(deltaTime: TimeInterval) {
        guard let gameObject else { return }
        var t = gameObject.localTransform
        t.position.x += 4.0 * deltaTime
        gameObject.localTransform = t
    }
}
```

```swift
let scene = DefaultScene()

let player = GameObject(name: "Player")
player.addComponent(PlayerScript())
// add View / Collider / ControlComponent here as needed

scene.addRootObject(player)
```

---

## 3. Scene Structure Pattern

For small-to-medium games, a practical structure is:

- a small number of **root objects** in `scene.rootObjects`:
  - background / world
  - player and major characters
  - UI root (if you model UI in the scene)
- children for detailed structure:
  - tiles, props, particles, etc.

Example:

```swift
let worldRoot = GameObject(name: "World")
let player = GameObject(name: "Player")
let enemy = GameObject(name: "Enemy")

worldRoot.addChild(player)
worldRoot.addChild(enemy)

scene.addRootObject(worldRoot)
```

This keeps traversal predictable and debugging simple while still allowing deep hierarchies if needed.

---

## 4. Update Flow

On each `GameLoop.tick(deltaTime:)`:

1. Scene pulls input from `inputSystem`.
2. Control events are dispatched to `ControlComponent`s.
3. Fixed update runs (`fixedUpdate`) for physics and other deterministic systems.
4. Regular update runs (`update`) for Scripts and components.
5. Draw traversal runs, calling `View.draw()` on enabled Views.

The **order** is important:

- input → physics → scripts → draw
- this ordering keeps input and physics deterministic while Views always reflect the latest state.

---

## 5. Patterns for Small Games

For a simple game or prototype:

1. Define a few `Script` types for movement, AI, and game rules.
2. Create lightweight `View` components that describe visuals (sprite name, color, size).
3. Add `Collider`s where collisions matter; respond via Scripts or events.
4. Use `DefaultScene` + `GameLoop` and embed in your host (SpriteKit, Metal, etc.).

If you use the SpriteKit adapter:

- focus your game code entirely on SwiftrixCore objects and components.
- let the adapter map Views to `SKNode`s and handle the render loop and camera.

---

## 6. Core vs Adapter Responsibilities (Diagram)

High-level boundaries between SwiftrixCore and a SpriteKit host using the adapter:

```text
 +-----------------------+        +------------------------------+
 |     SwiftrixCore      |        |     SpriteKit Host +        |
 |  (engine, platform-   |        |  SwiftrixSpriteKitRendering |
 |        agnostic)      |        |        (platform-aware)     |
 +-----------------------+        +------------------------------+
 | - Scene / DefaultScene |       | - SKView / SKScene          |
 | - GameObject / GameObject |       | - SpriteKitSceneAdapter     |
 | - Components:          |       | - SpriteView / ContainerView|
 |   Script / View /      |       | - CameraController          |
 |   Collider / Control   |       | - DebugOverlayRenderer      |
 | - GameLoop             |       | - HitTestBridge             |
 | - PhysicsWorld         |       | - Host input + lifecycle    |
 | - EventBus / InputSystem|      |   (AppDelegate, UIKit, etc.)|
 +------------------------+       +-----------------------------+
               ^                               |
               |  tick(deltaTime), input,      |
               |  events, transforms           |
               |                               v
        (gameplay logic, data)         (rendering, platform I/O)
```

- **Core (left)**: owns gameplay state, rules, and deterministic simulation; has no idea about SpriteKit or the platform UI.
- **Adapter + Host (right)**: own rendering, platform input, lifecycle, and presentation; translate Core state into `SKNode`s and user-visible behavior.

When in doubt:

- put **rules, state, and reusable logic** in SwiftrixCore;
- put **rendering, device input, and OS-specific behavior** in the host or adapter.
