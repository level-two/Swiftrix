# ``SwiftrixCore``

SwiftrixCore is the platform-agnostic engine core: a deterministic game loop, a scene graph, and a small set of components and protocols for building 2D gameplay logic.

It intentionally does not include rendering, audio, or platform input. Hosts provide those concerns and feed input into the core.

## Overview

Typical usage looks like:

1. Create a `DefaultScene` (or any type that conforms to `Scene`)
2. Build a tree of `GameObject`s
3. Attach `Component`s (usually `Script`, plus optional `View`/`Collider`)
4. Drive the scene with `GameLoop.tick(deltaTime:)` from your host

Scripts and game objects can also implement `fixedUpdate(fixedDeltaTime:)` for deterministic fixed-step logic (e.g., physics and simulation).

For a conceptual overview, see `docs/engine-concepts.md`. For a public API walkthrough, see `docs/public-api.md`.

## Topics

### Essentials

- ``Scene``
- ``DefaultScene``
- ``GameObject``
- ``GameLoop``

### Components

- ``Component``
- ``Script``
- ``View``
- ``Collider``
- ``BoxCollider``
- ``ControlComponent``

### Input

- ``InputSystem``
- ``DefaultInputSystem``
- ``ControlEvent``
- ``AxisValue``
- ``AxisConfig``
- ``InputKey``

### Events

- ``GameEvent``
- ``EventBus``
- ``DefaultEventBus``
- ``CollisionEvent``

### Physics

- ``PhysicsWorld``
- ``DefaultPhysicsWorld``
- ``CollisionGroup``

### Math and Introspection

- ``Vector2``
- ``Transform2D``
- ``DebugIntrospection``
