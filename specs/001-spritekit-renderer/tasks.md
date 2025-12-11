# Tasks: Swiftrix SpriteKit Rendering Scene

**Input**: Design documents from `/specs/001-spritekit-renderer/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Unit tests are required for SpriteKitScene behavior (mapping logic, lifecycle, dirty-flag sync). Integration tests using a headless `SKView` harness are planned where they materially increase confidence. Observability work (debug overlays, inspectors, metrics) is captured as first-class tasks.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Extend the Swift package with a SpriteKit-backed scene target and matching test target.

- [ ] T001 Update `Package.swift` to add `SwiftrixSpriteKitRendering` library target and `SwiftrixSpriteKitRenderingTests` test target (Package.swift)
- [ ] T002 [P] Create adapter source folder structure in Sources/SwiftrixSpriteKitRendering (Sources/SwiftrixSpriteKitRendering/)
- [ ] T003 [P] Create test folder structure in Tests/SwiftrixSpriteKitRenderingTests (Tests/SwiftrixSpriteKitRenderingTests/)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core SpriteKit bridge scaffolding, clocking, and mapping infrastructure required by all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 Design and document SpriteKitScene public entry points and types in a top-level Swift file (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T005 [P] Implement performance budget configuration structures (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T006 [P] Implement bidirectional mapping registry (`NodeBinding`, `ViewRepresentationMap`, `SpriteGraphMirror`) (Sources/SwiftrixSpriteKitRendering/NodeBindingRegistry.swift)
- [ ] T007 Implement dirty-sync queue infrastructure for batching node updates per frame (Sources/SwiftrixSpriteKitRendering/DirtySyncQueue.swift)
- [ ] T008 Add XCTest harness types for headless `SKView` and fake `CADisplayLink` driver (Tests/SwiftrixSpriteKitRenderingTests/SpriteKitTestHarness.swift)
- [ ] T009 Add baseline unit tests for `SpriteKitScene` lifecycle and mapping registry creation (Tests/SwiftrixSpriteKitRenderingTests/SpriteKitSceneLifecycleTests.swift)

**Checkpoint**: SpriteKit bridge target builds, basic mapping structures exist, and tests can run headless.

---

## Phase 3: User Story 1 - Run Core scenes inside a SpriteKit host (Priority: P1) 🎯 MVP

**Goal**: Allow a host app to run a Swiftrix Core scene inside a SpriteKit view and see the game object hierarchy rendered without changing gameplay code.

**Independent Test**: Wire the adapter into a sample SpriteKit host, start a Core scene, and verify the SpriteKit view displays all baseline game objects with matching transforms and a controllable pause/resume lifecycle.

### Tests for User Story 1

- [ ] T010 [P] [US1] Add unit tests to verify `SpriteKitScene` binds a Core scene and exposes a configured `SKScene` (Tests/SwiftrixSpriteKitRenderingTests/SpriteKitSceneBindingTests.swift)
- [ ] T011 [P] [US1] Add headless integration test to render a minimal Core scene and assert node hierarchy mirrors the Core root graph (Tests/SwiftrixSpriteKitRenderingTests/SceneBindingIntegrationTests.swift)

### Implementation for User Story 1

- [ ] T012 [P] [US1] Implement `SpriteKitScene` as an `SKScene` subclass that wraps a Core `Scene` and manages binding/sync (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T013 [P] [US1] Implement creation and configuration of the root `SKScene` and root node hierarchy (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T014 [US1] Implement binding API to attach game objects into the mirrored SpriteKit hierarchy (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T015 [US1] Implement `CADisplayLink`-driven loop that triggers Core fixed/variable updates then syncs to SpriteKit (Sources/SwiftrixSpriteKitRendering/DisplayLinkDriver.swift)
- [ ] T016 [US1] Implement pause/resume/stop controls on the SpriteKitScene and propagate lifecycle changes to the display link (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T017 [US1] Add quickstart validation snippet in `quickstart.md` showing binding code path compiles against adapter API (specs/001-spritekit-renderer/quickstart.md)

**Checkpoint**: A sample SpriteKit host can present `SpriteKitScene` directly, run the CADisplayLink loop (or SKScene update), and see a basic Core scene rendered and controllable.

---

## Phase 4: User Story 2 - Keep visuals synchronized with Core changes (Priority: P2)

**Goal**: Ensure any Core-side transform, hierarchy change, or visual property update is reflected on the next rendered frame in the SpriteKit node tree.

**Independent Test**: Drive scripted Core updates that move, rotate, reparent, and destroy objects while verifying each change appears in the SpriteKit view within one frame budget.

### Tests for User Story 2

- [ ] T018 [P] [US2] Add unit tests for transform, visibility, and z-order dirty-flag propagation from Core `View` components to `SKNode` (Tests/SwiftrixSpriteKitRenderingTests/ViewSyncTests.swift)
- [ ] T019 [P] [US2] Add unit tests for hierarchy changes (create/destroy/reparent) updating the SpriteKit node tree correctly (Tests/SwiftrixSpriteKitRenderingTests/HierarchySyncTests.swift)
- [ ] T020 [P] [US2] Add headless integration test that runs scripted Core animations and asserts sync within one frame (Tests/SwiftrixSpriteKitRenderingTests/SyncTimingIntegrationTests.swift)

### Implementation for User Story 2

- [ ] T021 [P] [US2] Implement `SpriteView` wrapping `SKSpriteNode` with Core-visible properties (texture, tint, size, anchor, z-order, alpha) (Sources/SwiftrixSpriteKitRendering/Views/SpriteView.swift)
- [ ] T022 [P] [US2] Implement `ContainerView` wrapping `SKNode` for pure transform-only game objects (Sources/SwiftrixSpriteKitRendering/Views/ContainerView.swift)
- [ ] T023 [US2] Implement sync pipeline that applies dirty `NodeBinding` flags to associated `SKNode` instances each frame (Sources/SwiftrixSpriteKitRendering/Sync/SpriteKitSyncEngine.swift)
- [ ] T024 [US2] Implement hierarchy management that mirrors Core parent/child changes into the SpriteKit node tree (Sources/SwiftrixSpriteKitRendering/Sync/HierarchySynchronizer.swift)
- [ ] T025 [US2] Implement enable/disable handling that maps Core `View.isEnabled` to SpriteKit visibility (e.g., `isHidden`/alpha) (Sources/SwiftrixSpriteKitRendering/Sync/VisibilitySynchronizer.swift)
- [ ] T026 [US2] Implement z-order and layering support that keeps draw order consistent with Core expectations (Sources/SwiftrixSpriteKitRendering/Sync/ZOrderSynchronizer.swift)
- [ ] T027 [US2] Add logging hooks or callbacks for missing assets, unsupported view types, and sync delays (Sources/SwiftrixSpriteKitRendering/Diagnostics/SyncDiagnostics.swift)

**Checkpoint**: Core-side changes appear reliably in the SpriteKit view; mapping is stable and debuggable during gameplay.

---

## Phase 5: User Story 3 - Recover from lifecycle interruptions (Priority: P3)

**Goal**: Allow hosts to pause, resume, reset, and swap scenes without leaking resources or leaving Core and SpriteKit out of sync.

**Independent Test**: Run a loop that pauses the adapter, tears down the Core scene, loads a new scene, and resumes rendering while verifying memory usage and node counts return to baseline each cycle.

### Tests for User Story 3

- [ ] T028 [P] [US3] Add unit tests for scene pause/resume semantics ensuring Core updates stop and restart exactly once (Tests/SwiftrixSpriteKitRenderingTests/LifecyclePauseResumeTests.swift)
- [ ] T029 [P] [US3] Add unit tests for scene reset/teardown ensuring mappings and SpriteKit nodes are fully released (Tests/SwiftrixSpriteKitRenderingTests/SceneTeardownTests.swift)
- [ ] T030 [P] [US3] Add integration test that repeatedly swaps scenes and asserts no growth in node count or memory footprint (Tests/SwiftrixSpriteKitRenderingTests/SceneSwapIntegrationTests.swift)

### Implementation for User Story 3

- [ ] T031 [P] [US3] Implement safe teardown path that stops the display link, clears mappings, and removes SpriteKitScene-owned nodes (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T032 [US3] Implement scene reset API that unloads the current Core scene and primes a new scene without leaking nodes (Sources/SwiftrixSpriteKitRendering/SpriteKitScene.swift)
- [ ] T033 [US3] Implement reactions to host lifecycle events (foreground/background) to suspend/resume Core updates appropriately (Sources/SwiftrixSpriteKitRendering/HostLifecycleBridge.swift)
- [ ] T034 [US3] Implement guardrails to prevent duplicate display links or double-started sessions (Sources/SwiftrixSpriteKitRendering/DisplayLinkDriver.swift)

**Checkpoint**: Hosts can safely pause, resume, and swap scenes during long-running sessions without instability.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Observability, camera behavior, hit-testing, documentation, and performance tuning that benefit all stories.

- [ ] T035 [P] Implement minimal camera controller with static and follow-object modes mapped to `SKCameraNode` (Sources/SwiftrixSpriteKitRendering/Camera/CameraController.swift)
- [ ] T036 [P] Implement debug overlay rendering (bounds, anchors, names, selection highlight) using `SKShapeNode` (Sources/SwiftrixSpriteKitRendering/Debug/DebugOverlayRenderer.swift)
- [ ] T037 Implement node inspector utility that can dump Core object ↔ SKNode mappings for tooling (Sources/SwiftrixSpriteKitRendering/Debug/NodeInspector.swift)
- [ ] T038 [P] Implement optional hit-testing bridge from SpriteKit touches back to Core `GameObject` IDs (Sources/SwiftrixSpriteKitRendering/Input/HitTestBridge.swift)
- [ ] T039 [P] Add documentation comments for all public SpriteKit bridge types and methods (Sources/SwiftrixSpriteKitRendering/)
- [ ] T040 Update `quickstart.md` and any host sample docs to reflect final APIs and recommended setup (specs/001-spritekit-renderer/quickstart.md)
- [ ] T041 Run performance profiling on reference scenes and tune sync batch sizes to maintain 60 FPS targets (Sources/SwiftrixSpriteKitRendering/Sync/)
- [ ] T042 Add any missing unit tests to reach acceptable coverage for adapter behavior (Tests/SwiftrixSpriteKitRenderingTests/)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies – can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 completion – blocks all user stories.
- **User Stories (Phases 3–5)**: Depend on Phase 2 completion; US1 (P1) is the MVP and should complete first, with US2 and US3 allowed to proceed in parallel once their prerequisites are met.
- **Polish (Phase 6)**: Depends on all desired user stories being complete or at least functionally stable.

### User Story Dependencies

- **User Story 1 (P1)**: Depends on foundational adapter scaffolding; no dependencies on other user stories.
- **User Story 2 (P2)**: Depends on US1 binding and basic loop so that sync behavior has a live scene to target; otherwise independently testable via its own tests.
- **User Story 3 (P3)**: Depends on US1 lifecycle wiring; can be developed alongside US2 once foundational lifecycle hooks exist.

### Parallel Opportunities

- Setup tasks T002–T003 can run in parallel after `Package.swift` is updated.
- Foundational tasks T005–T008 are largely parallelizable, provided the public API design in T004 is stable.
- Within each user story, tests marked [P] (T010–T011, T018–T020, T028–T030) can be authored in parallel, and view implementations (e.g., T021–T022) can proceed alongside sync engine work (T023–T027) with coordination on interfaces.
- US2 and US3 implementation tasks can be developed in parallel after US1’s binding and lifecycle are in place.

### MVP Scope

- The minimum viable product consists of completing Phases 1–3 (up through T017), enabling a host app to bind a Core scene, render it via SpriteKit, and control the adapter lifecycle with basic tests validating this behavior.
