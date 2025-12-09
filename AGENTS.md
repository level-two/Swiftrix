# Swiftrix Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-03

## Active Technologies
- Swift (modern toolchain; align with existing Swiftrix package) + SwiftrixCore engine (SwiftPM package), SpriteKit for rendering in the SwiftrixTest host app (001-pacman-demo-game)
- N/A (all game state is in-memory per Pacman session) (001-pacman-demo-game)
- Swift 5.9 (matches `Package.swift`) + SwiftrixCore engine APIs, SpriteKit (`SKScene`, `SKNode`, `CADisplayLink`), Foundation (001-spritekit-renderer)
- N/A (all state in-memory per scene) (001-spritekit-renderer)

- Swift 5.9 (as defined in `Package.swift`) + SwiftrixCore (game engine), SpriteKit (rendering), XCTest for tests (001-pacman-demo-game)

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
- 001-spritekit-renderer: Added Swift 5.9 (matches `Package.swift`) + SwiftrixCore engine APIs, SpriteKit (`SKScene`, `SKNode`, `CADisplayLink`), Foundation
- 001-pacman-demo-game: Added Swift (modern toolchain; align with existing Swiftrix package) + SwiftrixCore engine (SwiftPM package), SpriteKit for rendering in the SwiftrixTest host app

- 001-pacman-demo-game: Added Swift 5.9 (as defined in `Package.swift`) + SwiftrixCore (game engine), SpriteKit (rendering), XCTest for tests

<!-- MANUAL ADDITIONS START -->
## SwiftrixCore Engine Notes (for AI agents)

Scope: applies to work under `Sources/SwiftrixCore`, `Tests/SwiftrixCoreTests`,
and `specs/000-swiftrix-engine-core`.

- **Language/toolchain**: Swift 5.9, managed by SwiftPM (`Package.swift`).
- **Targets**: single library target `SwiftrixCore` plus `SwiftrixCoreTests`.
- **Core principle**: keep the engine core platform-agnostic. Do **not** add
  direct dependencies on SpriteKit, UIKit, SwiftUI, Metal, AVFoundation, etc.
  inside `SwiftrixCore`. Hosts provide rendering/input/audio as integrations.
- **Allowed imports** in core: `Foundation`, `CoreGraphics`, and internal
  engine modules. Treat any new framework import as suspicious and justify in
  specs before using it.

### Architectural boundaries

- `Scene`, `GameObject`, components, physics, input, events, and loop are all
  defined in `Sources/SwiftrixCore`. Changes here must preserve:
  - deterministic game loop (`GameLoop`)
  - component-based model (`Component`, `Script`, `View`, `Collider`, `ControlComponent`)
  - scene graph semantics (`Scene`, `DefaultScene`, `DefaultGameObject`)
  - protocol-based extension points (`PhysicsWorld`, `InputSystem`, `EventBus`)
- Rendering, platform input, audio, asset loading, and UI belong in host apps
  (e.g. Pacman demo) and should not leak into the core.

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
<!-- MANUAL ADDITIONS END -->
