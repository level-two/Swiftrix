# Implementation Plan: Swiftrix Engine Core

**Branch**: `000-swiftrix-engine-core` | **Date**: 2025-12-02 | **Spec**: `specs/000-swiftrix-engine-core/spec.md`  
**Input**: Feature specification from `/specs/000-swiftrix-engine-core/spec.md`

## Summary

Swiftrix Engine Core is a lightweight, modular Swift game engine inspired by
Unity’s component model, targeting rapid prototyping and small‑to‑medium games,
with a clear path to an ECS backend. The core delivers a scene graph,
`GameObject`/`GameObject` hierarchy, a small set of core components (`Script`, `View`,
`Collider`, `ControlComponent`), a predictable update lifecycle
(fixed/update/draw), an event pipeline, and abstraction layers for input,
physics, and rendering. This implementation focuses on a clear, deterministic,
and observable architecture that is ideal for both human developers and
AI‑assisted tooling, while strictly delegating rendering, input, audio, and
resource management to host applications.

## Technical Context

**Language/Version**: Swift 5.9 (or latest stable Swift 5.x, NEEDS CONFIRMATION)  
**Primary Dependencies**: SwiftPM, Foundation; rendering/input/physics backends
are injected by host (SpriteKit/Metal/etc. to be chosen later).  
**Storage**: N/A for core (no built‑in persistence); future scene/prefab
serialization planned.  
**Testing**: XCTest with high unit‑test coverage for all public APIs and core
behaviors.  
**Target Platform**: Engine core platform‑agnostic; initial host integrations
likely on Apple platforms (iOS, macOS) with room for Linux and other targets.  
**Project Type**: Single SwiftPM library package (engine core) with test
target(s).  
**Performance Goals**: Stable 60 fps for simple scenes on typical devices;
deterministic fixed‑step physics; predictable frame‑to‑frame behavior under
normal loads.  
**Constraints**: Core remains decoupled from platform frameworks; strict
separation between engine core and host; deterministic update loop; explicit,
inspectable state for tooling and AI.  
**Scale/Scope**: Small‑to‑medium games and tools; initial 2D focus with
3D‑ready abstractions; designed for incremental evolution rather than AAA‑scale
production.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Engine core changes MUST preserve core-only architecture: no new direct
  dependencies on rendering, input, audio, or resource-loading frameworks from
  core modules.
- Planned public API changes MUST be explicitly listed, documented, and mapped
  to a semantic version bump type (MAJOR/MINOR/PATCH) with rationale.
- Every new behavior MUST have planned unit tests that will fail before
  implementation and pass after; plans that omit tests are not acceptable.
- The feature MUST keep the package consumable as a SwiftPM dependency with
  clear target/module boundaries.
- Plans SHOULD consider observability and AI-assisted workflows: new systems
  and features SHOULD expose state and behavior in ways that are inspectable by
  tools and AI agents (e.g., via explicit structures, logs, or debug views).

## Project Structure

### Documentation (this feature)

```text
specs/000-swiftrix-engine-core/
├── spec.md          # High-level engine specification (this document's input)
├── plan.md          # This implementation plan
├── research.md      # Design notes, trade-offs (OO vs ECS, backends)
├── data-model.md    # Core data structures (Scene, GameObject/GameObject, components)
├── quickstart.md    # Minimal examples for embedding Swiftrix in a host app
├── contracts/       # Protocol-level contracts (PhysicsWorld, InputSystem, EventBus)
└── tasks.md         # Execution task list for implementing the core
```

### Source Code (repository root)

```text
Sources/
└── SwiftrixCore/
    ├── Scene/
    │   ├── Scene.swift
    │   ├── DefaultScene.swift
    │   └── SceneGraphTraversal.swift
    ├── GameObject/
    │   ├── GameObject.swift
    │   └── GameObject.swift
    ├── Components/
    │   ├── Component.swift
    │   ├── Script.swift
    │   ├── View.swift
    │   ├── Collider.swift
    │   └── ControlComponent.swift
    ├── Math/
    │   ├── Vector2.swift
    │   └── Transform2D.swift
    ├── Events/
    │   ├── GameEvent.swift
    │   └── DefaultEventBus.swift
    ├── Physics/
    │   └── PhysicsWorld.swift
    ├── Input/
    │   ├── InputSystem.swift
    │   ├── ControlEvent.swift
    │   └── AxisConfig.swift
    ├── Loop/
    │   └── GameLoop.swift
    └── Introspection/
        └── DebugIntrospection.swift

Tests/
└── SwiftrixCoreTests/
    ├── SceneTests.swift
    ├── GameObjectTests.swift
    ├── ComponentTests.swift
    ├── EventBusTests.swift
    ├── PhysicsWorldTests.swift
    ├── InputSystemTests.swift
    └── GameLoopTests.swift
```

**Structure Decision**: Use a single SwiftPM package `SwiftrixCore` with one
primary library target and one test target. Keep modules grouped by domain
(Scene, GameObject/GameObject, Components, Events, Physics, Input, Loop, Introspection) to
make the API surface discoverable and to support future ECS or backend swaps
without disrupting public contracts.

## Complexity Tracking

> Fill only if Constitution Check has violations that must be justified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| *(none yet)* | Swiftrix Engine Core plan currently adheres to constitution boundaries. | N/A |
