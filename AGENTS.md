# Swiftrix Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-03

## Active Technologies
- Swift (modern toolchain; align with existing Swiftrix package) + SwiftrixCore engine (SwiftPM package), optional SpriteKit-based host adapters.
- Swift 5.9 (matches `Package.swift`) + SwiftrixCore engine APIs, SpriteKit (`SKScene`, `SKNode`), Foundation (001-spritekit-renderer).
- N/A (all state in-memory per scene or engine session).

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Swift 5.9 (as defined in `Package.swift`)

## Code Style

Swift 5.9 (as defined in `Package.swift`): Follow standard conventions

## Recent Changes
- 000-swiftrix-engine-core: Initial engine core specification, plan, and tasks for the SwiftrixCore library.

<!-- MANUAL ADDITIONS START -->
## SwiftrixCore Engine Notes (for AI agents)

Scope: applies to work under `Sources/SwiftrixCore`, `Tests/SwiftrixCoreTests`,
and `specs/000-swiftrix-engine-core`.

- **Language/toolchain**: Swift 5.9, managed by SwiftPM (`Package.swift`).
- **Targets**: core library target `SwiftrixCore` plus `SwiftrixCoreTests`.
- **Core principle**: keep the engine core platform-agnostic. Do **not** add
  direct dependencies on SpriteKit, UIKit, SwiftUI, Metal, AVFoundation, etc.
  inside `SwiftrixCore`. Hosts and adapter modules provide rendering/input/audio.
- **Allowed imports** in core: `Foundation`, `CoreGraphics`, and internal
  engine modules. Treat any new framework import as suspicious and justify in
  specs before using it.

### Architectural boundaries

- `Scene`, `GameObjectInterface`, components, physics, input, events, and loop are all
  defined in `Sources/SwiftrixCore`. Changes here must preserve:
  - deterministic game loop (`GameLoop`)
  - component-based model (`Component`, `Script`, `View`, `Collider`, `ControlComponent`)
  - scene graph semantics (`Scene`, `DefaultScene`, `GameObjectInterface`/`GameObject`)
  - protocol-based extension points (`PhysicsWorld`, `InputSystem`, `EventBus`)
- Rendering, platform input, audio, asset loading, and UI belong in host apps
  (e.g. sample game or tooling hosts) and should not leak into the core.

### Workflow expectations

- Before editing core APIs, read:
  - `specs/000-swiftrix-engine-core/spec.md`
  - `specs/000-swiftrix-engine-core/plan.md`
  - `specs/000-swiftrix-engine-core/tasks.md`
- Mirror changes in **tests first** under `Tests/SwiftrixCoreTests` (red → green).
- Run `swift test` from the repo root after changes.
- Keep new public API surface small and coherent; prefer extending existing
  protocols/types over adding parallel concepts.

### Common tasks cheatsheet

- **Run tests**: `swift test`
- **Locate engine code**: `Sources/SwiftrixCore/**`
- **Locate engine tests**: `Tests/SwiftrixCoreTests/**`
- **Find specs**: `specs/000-swiftrix-engine-core/**`

When in doubt, favor simplicity, determinism, and clear data flow over clever
abstractions. This repository is optimized for being easy to understand and
safe to modify (for both humans and AI agents).

## SwiftrixSpriteKitRendering Adapter Notes (for AI agents)

Scope: applies to work under `Sources/SwiftrixSpriteKitRendering`,
`Tests/SwiftrixSpriteKitRenderingTests`, and `specs/001-spritekit-renderer`.

- **Purpose**: host-side adapter that mirrors SwiftrixCore scenes into
  SpriteKit (`SKScene`/`SKNode`) and drives the core `GameLoop` using a
  display-linked clock (Timer on macOS, `CADisplayLink` where available).
- **Dependencies**: may import SpriteKit and related Apple frameworks, but
  must not leak those dependencies back into `SwiftrixCore`.
- **Key types**: `SpriteKitSceneAdapter`, `SpriteView`, `ContainerView`,
  `CameraController`, `DebugOverlayRenderer`, `HitTestBridge`.
- **Behavioral constraints**:
  - keep adapter logic deterministic and driven by Core state
  - respect performance budgets (per-frame sync limits)
  - treat debug overlays and diagnostics as opt-in and cheap to disable
- **Workflow**:
  - see `specs/001-spritekit-renderer/spec.md` and `quickstart.md` before
    changing public APIs
  - keep adapter tests in `Tests/SwiftrixSpriteKitRenderingTests` green
    (`swift test`) when modifying SpriteKit integration.
<!-- MANUAL ADDITIONS END -->
