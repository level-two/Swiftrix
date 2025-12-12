# Unit Test Coverage Plan

This document is a contributor-focused checklist of engine mechanisms to cover
with unit tests. It is intended to be used as a “red → green” guide while
implementing new features or tightening semantics in Swiftrix.

Scope:

- `SwiftrixCore` tests live under `Tests/SwiftrixCoreTests` (platform-agnostic).
- `SwiftrixSpriteKitRendering` tests live under `Tests/SwiftrixSpriteKitRenderingTests`.

Non-goals:

- end-to-end rendering tests (prefer adapter unit tests + manual smoke tests)
- platform integration tests in `SwiftrixCore` (no SpriteKit/UIKit/etc in core)

---

## What’s already covered (high level)

Core (`Tests/SwiftrixCoreTests`):

- scene traversal order and hierarchy basics
- component enabled/disabled behavior
- script update enable/disable behavior
- game loop fixed-step accumulation
- default input system state and queued events
- physics world: overlap query, registration, collision event posting
- event bus basic subscribe/post
- debug introspection hierarchy listing

SpriteKit adapter (`Tests/SwiftrixSpriteKitRenderingTests`):

- binding a hierarchy and syncing transforms
- pause/resume driving the game loop
- destroyed object removal, disabled object visibility
- reparenting updates the mirrored node tree
- hit-testing and camera follow
- per-frame sync budget limiting

---

## Core engine: test matrix

### 1) Scene graph invariants (`GameObject`)

Basic structure:

- `testAddChild_setsParent_andAppendsToChildren`
- `testRemoveChild_clearsParent_andRemovesFromChildren`
- `testRemoveFromParent_noopWhenParentNil`
- `testGetComponent_returnsFirstMatchingType`
- `testGetComponents_returnsAllMatchingType`
- `testAddComponent_setsBackReference`
- `testRemoveComponent_clearsBackReference`

Complex hierarchy / corner cases (recommended to define explicit semantics):

- `testReparenting_removesChildFromOldParent_andUpdatesParentPointer`
  - Current code does not enforce this; decide whether reparent is supported as a
    single call or requires explicit `removeFromParent()` first.
- `testAddChild_rejectsAddingSelf`
- `testAddChild_rejectsAddingAncestorOrDescendant` (cycle prevention)
- `testAddChild_duplicateChild_isIdempotent_orThrows`
- `testRemoveChild_notAChild_isNoop`
- `testDeepHierarchy_globalTransform_isStable` (e.g. depth 50+)

Update gating:

- `testUpdate_skipsDisabledGameObject_andItsSubtree`
- `testUpdate_skipsDestroyedGameObject_andItsSubtree`
- `testUpdate_callsEnabledComponentsOnly`

Mutation during traversal (define semantics; tests should drive the decision):

- `testUpdate_componentAddedDuringUpdate_isNotUpdatedUntilNextFrame`
- `testUpdate_componentRemovedDuringUpdate_doesNotCrash_andHasDefinedOutcome`
- `testUpdate_childAddedDuringUpdate_isNotUpdatedUntilNextFrame`
- `testUpdate_childRemovedDuringUpdate_doesNotCrash_andHasDefinedOutcome`

### 2) Transforms (`Vector2`, `Transform2D`, `GameObject+helpers`, `Script`)

Math correctness / composition:

- `testTransformApplying_combinesPositionScaleRotation` (incl. nested scale)
- `testGlobalTransform_matchesParentApplyingLocalTransform`
- `testGlobalHelpers_matchGlobalTransformProperties`

Script bridges (important for gameplay ergonomics):

- `testScript_localTransformBridges_mutateGameObject`
- `testScript_globalTransformBridges_reflectHierarchy`
- `testScript_globalPositionRotationScale_reflectHierarchy`

Corner cases:

- `testTransform_identityIsNeutralElement`
- `testVector2_arithmetic_isAssociativeWithinTolerance` (if/when floats used)

### 3) Scene orchestration (`Scene`, `SceneGraphTraversal`)

Update sequencing:

- `testSceneUpdate_callsInputSystemUpdate_beforeDispatch`
- `testSceneUpdate_dispatchesPendingEvents_depthFirst`
- `testSceneUpdate_doesNothing_whenInputSystemNil`

Traversal order (with complex trees):

- `testDepthFirstUpdate_isPreorder_forComplexHierarchy`
- `testDepthFirstDraw_visitsViewsPreorder_andSkipsDisabled`
- `testDispatchControlEvents_skipsDisabledOrDestroyedSubtrees`

Root object management:

- `testAddRootObject_preservesInsertionOrder`
- `testRemoveRootObject_removesByIdentity_andIsIdempotent`
- `testDestroyedRootObject_isSkippedButStillPresentUntilRemoved` (documented behavior)

### 4) Game loop (`GameLoop`)

Fixed-step accumulation:

- `testTick_runsExpectedFixedUpdateCount_forFractionalAccumulation`
- `testTick_preservesAccumulatorRemainder_acrossTicks`
- `testTick_withZeroDelta_runsUpdateAndDraw_only`
- `testTick_withVeryLargeDelta_limitsFixedSteps_orDocumentsNoLimit`

Determinism guidance:

- `testTick_withSameDeltaSequence_producesSameFixedUpdateCounts`

### 5) Events (`DefaultEventBus`)

Typed delivery:

- `testPost_deliversOnlyToMatchingEventTypeSubscribers`
- `testMultipleSubscribers_receiveSameEvent`
- `testCancelOneSubscriber_doesNotAffectOthers`

Ordering and termination semantics:

- `testSubscriber_receivesEventsInPostOrder` (single publisher thread)
- `testTerminatedSubscriber_doesNotReceiveFurtherEvents`
- `testPostingWithNoSubscribers_isNoop`

Concurrency (optional; keep deterministic where possible):

- `testConcurrentPosts_doNotCrash` (if you explicitly want thread-safety)

### 6) Input (`DefaultInputSystem`, `ControlComponent`, `SceneGraphTraversal.dispatchControlEvents`)

State machine:

- `testButtonPressed_isTrueOnlyForFrameAfterButtonDown_thenClearsOnUpdate`
- `testButtonUp_down_pressed_semantics_forPressReleaseSequence`
- `testAxisDefaultsToZero_andUpdatesOnAxisChanged`

Event transport:

- `testPendingEvents_returnsAndClearsQueue`
- `testEventsStream_yieldsAllSentEvents`

Dispatch:

- `testControlComponents_receiveEvents_inDepthFirstOrder`
- `testDisabledControlComponents_doNotReceiveEvents`

### 7) Physics (`DefaultPhysicsWorld`, `Collider`)

Registration/lifecycle filtering:

- `testStep_ignoresDisabledColliders`
- `testStep_ignoresDisabledOrDestroyedGameObjects`
- `testStep_prunesReleasedColliders` (weak entries get dropped)
- `testRemoveCollider_idempotent`
- `testAddCollider_duplicateAdd_isDefined_orPrevented`

Collision semantics:

- `testStep_postsCollisionEvent_oncePerOverlappingPairPerStep`
- `testStep_notifiesScripts_onBothSides`
- `testStep_noEventWhenNotOverlapping`

Geometry:

- `testLocalOffset_affectsColliderRect`
- `testGlobalTransform_position_affectsColliderRect_inHierarchy`
- `testQuery_groupFilter_returnsOnlyMatchingGroups`
- `testQuery_excludesDisabledOrDestroyedObjects` (if intended; currently step does)

Scene integration:

- `testSceneAddRoot_registersColliders_inEntireSubtree`
- `testSceneRemoveRoot_unregistersColliders_inEntireSubtree`
- `testRuntimeAddedCollider_requiresExplicitPhysicsWorldRegistration` (current documented behavior)
- `testRuntimeAddedChildWithCollider_requiresExplicitRegistration` (current documented behavior)

### 8) Debugging / introspection (`DebugIntrospection`)

- `testDescribeObject_includesIndentation_andComponentCounts`
- `testDescribeScene_appendsSortedInputAxisNames_whenDefaultInputSystemPresent`
- `testDescribeScene_handlesEmptyScene`

---

## SpriteKit adapter: additional tests to add (beyond existing)

Hierarchy edge cases:

- `testMirroring_skipsDisabledOrDestroyedSubtrees_consistently`
- `testMirroring_handlesLargeHierarchy_withBudget` (budget + eventual convergence)
- `testMirroring_reparentingAcrossRoots_updatesZOrder_orParentingRules` (if applicable)

Transform fidelity:

- `testRotationAndScale_syncCorrectly` (if adapter supports them)
- `testAnchorPoint_orAlignment_rules_areDocumented_andTested` (if present)

Hit testing:

- `testHitTest_returnsNilWhenNoNode`
- `testHitTest_prefersTopmostNode_whenOverlappingNodes`

Lifecycle:

- `testReset_isIdempotent_andDoesNotLeakNodes`
- `testPause_doesNotAdvanceCoreTime`

