---
description: "Task list for Unity-like touch input (touches array + phases)"
---

# Tasks: Touch Input (Unity-like)

**Input**: `specs/003-touch-input/spec.md`, `specs/003-touch-input/plan.md`  
**Tests**: Unit tests are mandatory for new Core behavior.

## Format: `[ID] [P?] [Story?] Description (file paths)`

- **[P]**: can run in parallel (different files, minimal coupling)
- **[Story]**: US1/US2/US3

## Phase 1: SwiftrixCore (types + query surface)

- [ ] T001 [US1,US2] Add `TouchPhase` + `Touch` types (Sources/SwiftrixCore/Input/Touch.swift)
- [ ] T002 [US1] Extend `InputSystem` with `touches()` defaulting to `[]` (Sources/SwiftrixCore/Input/InputSystem.swift)
- [ ] T003 [US1] Add `InputProxy` wrapper and `Scene.input` convenience (Sources/SwiftrixCore/Input/InputProxy.swift, Sources/SwiftrixCore/Scene/Scene.swift)

## Phase 2: SwiftrixCore (scene access from gameplay code)

- [ ] T004 [US3] Add `GameObject.scene` back-reference (Sources/SwiftrixCore/GameObject/GameObject.swift)
- [ ] T005 [US3] Wire scene back-reference on add/remove root objects (Sources/SwiftrixCore/Scene/SceneCore.swift)
- [ ] T006 [P] [US3] Add `Script.scene` / `Script.input` conveniences (Sources/SwiftrixCore/Components/Script.swift)

## Phase 3: SwiftrixCore tests

- [ ] T007 [P] [US1] Add tests for `InputProxy` safe defaults (Tests/SwiftrixCoreTests/InputProxyTests.swift)
- [ ] T008 [P] [US3] Add tests for GameObject scene back-reference propagation (Tests/SwiftrixCoreTests/GameObjectSceneReferenceTests.swift)
- [ ] T009 [US1] Add sequencing test: input sampling happens during `Scene.update` after fixed updates (Tests/SwiftrixCoreTests/GameLoopInputSamplingTests.swift)

## Phase 4: SpriteKit adapter (optional follow-up)

- [ ] T010 [US1,US2] Implement SpriteKit touch input bridge that produces core `Touch` snapshots (Sources/SwiftrixSpriteKitRendering/Input/SpriteKitTouchInputSystem.swift)
- [ ] T011 [P] [US1,US2] Add tests for SpriteKit → core touch translation (Tests/SwiftrixSpriteKitRenderingTests/TouchInputBridgeTests.swift)

## Validation

- [ ] T012 Run `swift test` from repo root and keep all tests green
