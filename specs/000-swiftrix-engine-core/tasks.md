---

description: "Task list for Swiftrix Engine Core implementation"
---

# Tasks: Swiftrix Engine Core

**Input**: Design documents from `/specs/000-swiftrix-engine-core/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Unit tests are MANDATORY for all new engine behavior. Additional
test types (e.g., contract or integration tests) are OPTIONAL and only included
if explicitly requested in the feature specification. Observability-related
work (e.g., debug views, structured logging, introspection helpers) SHOULD be
captured as tasks when it materially improves engine clarity or AI-assisted
workflows.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story?] Description with file path`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for Swiftrix Engine Core

- [ ] T001 Create SwiftPM package structure for SwiftrixCore in Package.swift
- [ ] T002 Create base library target `SwiftrixCore` in Package.swift
- [ ] T003 Create test target `SwiftrixCoreTests` in Package.swift
- [ ] T004 [P] Initialize source folders for core modules in Sources/SwiftrixCore/
- [ ] T005 [P] Initialize test folders for core modules in Tests/SwiftrixCoreTests/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T006 Define math primitives Vector2 and Transform2D in Sources/SwiftrixCore/Math/
- [ ] T007 [P] Add unit tests for Vector2 and Transform2D behavior in Tests/SwiftrixCoreTests/MathTests.swift
- [ ] T008 Define core protocols IdentifiableObject, Named, Updatable, FixedUpdatable, Destroyable in Sources/SwiftrixCore/Core/
- [ ] T009 [P] Add unit tests for lifecycle and destroy semantics in Tests/SwiftrixCoreTests/CoreProtocolsTests.swift
- [ ] T010 Define GameObject protocol and GameObject implementation in Sources/SwiftrixCore/GameObject/
- [ ] T011 Add unit tests for GameObject hierarchy, transforms, and component attachment in Tests/SwiftrixCoreTests/GameObjectTests.swift
- [ ] T012 Define Component base class and Script, View, Collider, ControlComponent classes in Sources/SwiftrixCore/Components/
- [ ] T013 [P] Add unit tests for component enabling, disabling, and update dispatch in Tests/SwiftrixCoreTests/ComponentTests.swift
- [ ] T014 Define Scene base class with update/fixedUpdate/draw hooks in Sources/SwiftrixCore/Scene/Scene.swift
- [ ] T015 Add unit tests for Scene root object management and traversal ordering in Tests/SwiftrixCoreTests/SceneTests.swift
- [ ] T016 Define GameEvent protocol and EventBus interface in Sources/SwiftrixCore/Events/
- [ ] T017 [P] Implement DefaultEventBus with AsyncStream-based subscriptions in Sources/SwiftrixCore/Events/DefaultEventBus.swift
- [ ] T018 [P] Add unit tests for DefaultEventBus publish/subscribe behavior in Tests/SwiftrixCoreTests/EventBusTests.swift
- [ ] T019 Introduce DebugIntrospection utilities for scenes and game object trees in Sources/SwiftrixCore/Introspection/DebugIntrospection.swift
- [ ] T020 [P] Add unit tests verifying that DebugIntrospection exposes scene graph state for tools in Tests/SwiftrixCoreTests/IntrospectionTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Minimal Playable Scene (Priority: P1) 🎯 MVP

**Goal**: Allow developers to create a simple scene with a player object, attach basic scripts and views, and run a deterministic update loop.

**Independent Test**: A minimal sample can be built where a single GameObject moves or animates in response to time progression, using only core APIs and without integrating rendering or input backends.

### Tests for User Story 1 (unit tests, mandatory)

- [ ] T021 [P] [US1] Add unit tests for SceneGraphTraversal (depth-first update order) in Tests/SwiftrixCoreTests/SceneTraversalTests.swift
- [ ] T022 [P] [US1] Add unit tests for Script update behavior and lifecycle hooks in Tests/SwiftrixCoreTests/ScriptTests.swift
- [ ] T023 [P] [US1] Add unit tests for GameLoop fixed/update sequencing using a stub Scene in Tests/SwiftrixCoreTests/GameLoopTests.swift

### Implementation for User Story 1

- [ ] T024 [US1] Implement SceneGraphTraversal utilities for updating and drawing scenes in Sources/SwiftrixCore/Scene/SceneGraphTraversal.swift
- [ ] T025 [P] [US1] Implement default Script base type with optional hooks in Sources/SwiftrixCore/Components/Script.swift
- [ ] T026 [P] [US1] Implement GameLoop abstraction that drives Scene.update and Scene.fixedUpdate in Sources/SwiftrixCore/Loop/GameLoop.swift
- [ ] T027 [US1] Add minimal example code for constructing a scene and a scripted GameObject in Sources/SwiftrixCore/Examples/MinimalSceneExample.swift
- [ ] T028 [US1] Update DebugIntrospection to provide human-readable dumps of scenes and GameObject hierarchies in Sources/SwiftrixCore/Introspection/DebugIntrospection.swift

**Checkpoint**: At this point, a minimal deterministic scene with scripted behavior can be created and stepped through programmatically using unit tests or small sample code.

---

## Phase 4: User Story 2 - Input and Control Mapping (Priority: P2)

**Goal**: Provide a device-agnostic input layer that exposes axes and actions, and map these into ControlComponent events on GameObjects.

**Independent Test**: A test harness can simulate logical input events (axes/actions) and verify that ControlComponent instances receive the correct ControlEvent stream, without depending on actual keyboard, touch, or gamepad devices.

### Tests for User Story 2 (unit tests, mandatory)

- [ ] T029 [P] [US2] Add unit tests for AxisConfig and InputKey mapping behavior in Tests/SwiftrixCoreTests/InputConfigTests.swift
- [ ] T030 [P] [US2] Add unit tests for InputSystem axis/button state queries in Tests/SwiftrixCoreTests/InputSystemTests.swift
- [ ] T031 [P] [US2] Add unit tests for dispatching ControlEvent streams to ControlComponent instances in Tests/SwiftrixCoreTests/ControlComponentTests.swift

### Implementation for User Story 2

- [ ] T032 [US2] Implement AxisConfig and InputKey types in Sources/SwiftrixCore/Input/AxisConfig.swift
- [ ] T033 [P] [US2] Implement ControlEvent enum and related helpers in Sources/SwiftrixCore/Input/ControlEvent.swift
- [ ] T034 [US2] Implement InputSystem protocol and default implementation using logical axes and actions in Sources/SwiftrixCore/Input/InputSystem.swift
- [ ] T035 [P] [US2] Implement ControlComponent protocol and base utilities in Sources/SwiftrixCore/Components/ControlComponent.swift
-- [ ] T036 [US2] Implement input dispatch from InputSystem to ControlComponent instances in Scene update flow in Sources/SwiftrixCore/Scene/Scene.swift
- [ ] T037 [US2] Update DebugIntrospection to expose current input axis values and recent ControlEvents for tools in Sources/SwiftrixCore/Introspection/DebugIntrospection.swift

**Checkpoint**: At this point, GameObjects can react to logical input axes/actions through ControlComponent and Script APIs, with full test coverage for input mapping and dispatch.

---

## Phase 5: User Story 3 - Physics and Collision Events (Priority: P3)

**Goal**: Provide a minimal physics/collision layer that supports collider registration, overlap queries, and collision events delivered to scripts and the event bus.

**Independent Test**: A test scene with multiple colliders can be stepped through a fixedUpdate loop to verify triggers and solid collisions, with CollisionEvents posted to EventBus and Script.onCollision callbacks invoked correctly.

### Tests for User Story 3 (unit tests, mandatory)

- [ ] T038 [P] [US3] Add unit tests for CollisionGroup behavior and matching in Tests/SwiftrixCoreTests/CollisionGroupTests.swift
- [ ] T039 [P] [US3] Add unit tests for PhysicsWorld collider registration and removal in Tests/SwiftrixCoreTests/PhysicsWorldRegistrationTests.swift
- [ ] T040 [P] [US3] Add unit tests for PhysicsWorld overlap and raycast queries in Tests/SwiftrixCoreTests/PhysicsWorldQueryTests.swift
- [ ] T041 [P] [US3] Add unit tests for collision event dispatch to EventBus and Script.onCollision in Tests/SwiftrixCoreTests/CollisionEventTests.swift

### Implementation for User Story 3

- [ ] T042 [US3] Define CollisionGroup enum and Collider protocol in Sources/SwiftrixCore/Components/Collider.swift
- [ ] T043 [P] [US3] Define PhysicsWorld protocol with step and query APIs in Sources/SwiftrixCore/Physics/PhysicsWorld.swift
- [ ] T044 [US3] Implement a minimal default PhysicsWorld with simple 2D collider overlap detection in Sources/SwiftrixCore/Physics/DefaultPhysicsWorld.swift
- [ ] T045 [P] [US3] Wire PhysicsWorld.step into Scene.fixedUpdate so colliders are updated and collisions computed in Sources/SwiftrixCore/Scene/Scene.swift
- [ ] T046 [US3] Implement collision handling that posts CollisionEvent to EventBus and calls Script.onCollision on affected GameObjects in Sources/SwiftrixCore/Physics/DefaultPhysicsWorld.swift
- [ ] T047 [US3] Update DebugIntrospection to expose active colliders and recent CollisionEvents in Sources/SwiftrixCore/Introspection/DebugIntrospection.swift

**Checkpoint**: All core physics and collision features are independently testable, and games can react to collisions via scripts and event streams without relying on a specific rendering backend.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and overall engine quality

- [ ] T048 Document public APIs for Scene, GameObject, and Components in Sources/SwiftrixCore/** (Swift documentation comments)
- [ ] T049 Add quickstart examples showing minimal scenes and input/physics usage in specs/000-swiftrix-engine-core/quickstart.md
- [ ] T050 [P] Add additional unit tests for edge cases in scene traversal, input mapping, and collision handling in Tests/SwiftrixCoreTests/AdditionalCoverageTests.swift
- [ ] T051 [P] Add basic performance-oriented benchmarks or stress tests (if supported) for update and fixedUpdate loops in Tests/SwiftrixCoreTests/PerformanceTests.swift
- [ ] T052 [P] Refine DebugIntrospection output formats for AI tools (e.g., JSON-like snapshots) in Sources/SwiftrixCore/Introspection/DebugIntrospection.swift
- [ ] T053 Ensure all new files are integrated into Package.swift targets and test targets in Package.swift

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories.
- **User Stories (Phase 3+)**: All depend on Foundational phase completion.
  - User stories can then proceed in parallel (if staffed).
  - Or sequentially in priority order (P1 → P2 → P3).
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - no dependencies on other stories.
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - may integrate with US1 but should be independently testable.
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - may integrate with US1/US2 but should be independently testable.

### Within Each User Story

- Unit tests MUST be written and FAIL before implementation.
- Core data structures and protocols before systems that depend on them.
- Systems before integration into Scene and GameLoop.
- Debug/observability hooks can be implemented in parallel once structures are in place.
- Story is complete when tests pass and independent test criteria are met.

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel where they touch different files (T004, T005).
- In Foundational phase, tasks T007, T009, T013, T017, T018, T020 can run in parallel once their corresponding types exist.
- For User Story 1, tasks T021–T023 can run in parallel; likewise T025 and T026 can run in parallel after foundational protocols exist.
- For User Story 2, tasks T029–T031, T033, and T035 can run in parallel where they modify different files.
- For User Story 3, tasks T038–T041 and T043 can run in parallel once CollisionGroup and Collider are defined.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories).
3. Complete Phase 3: User Story 1 (Minimal Playable Scene).
4. **STOP and VALIDATE**: Use unit tests and quick examples to validate scene graph, GameObject, and Script behavior.
5. Publish an initial SwiftrixCore package version suitable for experimental projects.

### Incremental Delivery

1. Complete Setup + Foundational → foundation ready.
2. Add User Story 1 → test independently → publish or tag as first engine preview.
3. Add User Story 2 → test independently → publish updated version with input/Control mapping.
4. Add User Story 3 → test independently → publish updated version with physics and collision events.
5. Each story adds value without breaking previous capabilities, respecting semantic versioning and constitution rules.
