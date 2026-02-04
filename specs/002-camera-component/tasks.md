---
description: "Task list for introducing a dedicated Camera component (Unity-like)"
---

# Tasks: Dedicated Camera Component (Unity-like)

**Input**: `specs/002-camera-component/spec.md`, `specs/002-camera-component/plan.md`  
**Tests**: Unit tests are mandatory for new behavior.

## Format: `[ID] [P?] [Story?] Description (file paths)`

- **[P]**: can run in parallel (different files, minimal coupling)
- **[Story]**: US1/US2/US3

## Phase 1: SwiftrixCore (Camera API + backing)

- [ ] T001 [US1] Add `CameraComponent` protocol and `Camera` component (Sources/SwiftrixCore/Components/Camera.swift)
- [ ] T002 [US1] Add package-scoped backing `CameraCore` with validation and aspect ratio storage (Sources/SwiftrixCore/Components/CameraCore.swift)
- [ ] T003 [P] [US1] Add unit tests for Camera defaults + zoomScale validation (Tests/SwiftrixCoreTests/CameraTests.swift)
- [ ] T004 [P] [US3] Add unit tests for `aspectRatio` read-only behavior + package update hook usage (Tests/SwiftrixCoreTests/CameraAspectRatioTests.swift)

## Phase 2: SpriteKit adapter (selection + SKCameraNode)

- [ ] T005 [US1] Remove legacy camera controller API (delete Sources/SwiftrixSpriteKitRendering/Camera/CameraController.swift)
- [ ] T006 [US1] Remove `cameraController` and `configureCamera(_:)` from SpriteKitScene (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T007 [US1,US2] Implement camera discovery + deterministic selection (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T008 [US1] Implement camera node creation/teardown and transform + zoom application (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T009 [US3] Update camera aspect ratio from SpriteKit scene size (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)

## Phase 3: Tests (adapter)

- [ ] T010 [P] [US2] Add tests for deterministic camera selection rules (Tests/SwiftrixSpriteKitRenderingTests/CameraSelectionTests.swift)
- [ ] T011 [P] [US1] Add tests for camera transform + zoom application (Tests/SwiftrixSpriteKitRenderingTests/CameraTransformTests.swift)
- [ ] T012 [P] [US3] Add tests for aspect ratio update on resize (Tests/SwiftrixSpriteKitRenderingTests/CameraAspectRatioTests.swift)
- [ ] T013 [US1] Update existing tests referencing `configureCamera` to use the new `Camera` component (Tests/SwiftrixSpriteKitRenderingTests/LifecycleAndUtilityTests.swift)

## Phase 4: Docs/spec cleanup

- [ ] T014 Update public docs to reflect new camera API and remove `CameraController` references (docs/public-api.md)
- [ ] T015 Update API reference docs to reflect new camera API and remove `CameraController` references (docs/api-reference.md)
- [ ] T016 Update SpriteKit host integration guide (docs/host-integration-spritekit.md)
- [ ] T017 Update `specs/001-spritekit-renderer/tasks.md` to remove/replace the camera-controller task (specs/001-spritekit-renderer/tasks.md)

## Validation

- [ ] T018 Run `swift test` from repo root and keep all tests green

