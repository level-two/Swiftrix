# Feature Specification: Dedicated Camera Component (Unity-like)

**Feature ID (proposed)**: `002-camera-component`  
**Created**: 2026-02-04  
**Status**: Draft  
**Scope**: SwiftrixCore + SwiftrixSpriteKitRendering

## Summary

Introduce a dedicated **Camera component** that can be attached to a `GameObject`, respects the `GameObject` transform (position/rotation), tolerates `isEnabled`, and is selected by the host renderer as the active camera (Unity-like mental model).

This replaces and **removes** the existing SpriteKit-only camera API (`CameraController` / `configureCamera`).

### Key decisions (confirmed)

- **Zoom model**: `zoomScale` (Unity-like, mapped to SpriteKit `SKCameraNode.setScale` semantics).
- **Viewport**: not modeled at protocol/core level (SpriteKit cannot implement Unity viewport cleanly in v1).
- **Camera properties**: expose **read-only `aspectRatio`** and **`viewportSize`** (computed by host/adapter).
- **Core default camera**: `SwiftrixCore` provides a default `Camera` component with package-level update hooks used by adapters.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Attach a Camera to a GameObject (P1)

Engine users attach a `Camera` component to any `GameObject` and expect the renderer to use that object’s transform as the active camera transform.

**Acceptance Scenarios**

1. **Given** a `GameObject` with `Camera` enabled, **When** the object moves/rotates, **Then** the host renderer camera updates accordingly.
2. **Given** the `Camera.isEnabled == false` or the owning `GameObject.isEnabled == false`, **When** the scene renders, **Then** that camera is ignored.

**Independent Tests**

- Core unit tests verify component shape, defaults, and access control behavior for `aspectRatio` / `viewportSize`.
- SpriteKit adapter tests verify camera selection and transform mapping to `SKCameraNode`.

### User Story 2 — Camera selection is deterministic (P1)

If there are multiple enabled cameras, camera selection must be deterministic and configurable.

**Acceptance Scenarios**

1. **Given** multiple enabled cameras, **When** the scene updates, **Then** the camera with the highest `depth` is selected.
2. **Given** cameras with equal `depth`, **When** selection happens, **Then** selection follows stable depth-first traversal order (first encountered wins).

### User Story 3 — Camera exposes aspect ratio (P2)

Gameplay code needs access to the current camera aspect ratio for UI layout and behavior.

**Acceptance Scenarios**

1. **Given** the host view size changes, **When** the adapter updates, **Then** `camera.aspectRatio` reflects the new value.
2. **Given** there is no host camera update yet, **Then** `camera.aspectRatio` remains a safe default (e.g., `1.0`).

### User Story 4 — Camera exposes viewport size (P2)

Gameplay code needs access to the current camera viewport size for UI layout and behavior.

**Acceptance Scenarios**

1. **Given** the host view size changes, **When** the adapter updates, **Then** `camera.viewportSize` reflects the new value.
2. **Given** there is no host camera update yet, **Then** `camera.viewportSize` remains a safe default (e.g., `Vector2.zero`).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `SwiftrixCore` MUST provide a public `Camera` component that can be attached to a `GameObject`.
- **FR-002**: A camera MUST respect the owning `GameObject` transform (position and rotation). (Scale does not affect camera transform in v1; zoom is controlled by `zoomScale`.)
- **FR-003**: A camera MUST be ignored when either:
  - the camera component is disabled (`camera.isEnabled == false`), or
  - the owning `GameObject` is disabled (`gameObject.isEnabled == false`), or
  - the owning `GameObject` is destroyed.
- **FR-004**: The camera MUST expose a `zoomScale` property. Default MUST be `1.0`.
- **FR-005**: The camera MUST expose a read-only `aspectRatio` property. Its value MUST be provided/updated by the host adapter (SpriteKit) at runtime.
- **FR-005a**: The camera MUST expose a read-only `viewportSize` property. Its value MUST be provided/updated by the host adapter (SpriteKit) at runtime, and in v1 matches the host scene size.
- **FR-006**: The renderer MUST select the active camera deterministically:
  - highest `depth` among enabled cameras wins
  - tie-breaker is stable traversal order (depth-first, first encountered)
- **FR-007**: The existing SpriteKit camera API (`CameraController`, `CameraConfig`, `SpriteKitScene.configureCamera`) MUST be removed from the package and documentation updated accordingly.

### Non-Functional Requirements

- **NFR-001**: Core MUST remain platform-agnostic. No SpriteKit/UIKit/etc imports in `SwiftrixCore`.
- **NFR-002**: Camera selection and application MUST be deterministic and stable frame-to-frame.
- **NFR-003**: Camera update cost per frame MUST be O(n) in number of `GameObject`s (single traversal).

## Notes / Constraints

- Unity-like viewport splitting is out of scope for v1.
- SpriteKit camera updates must occur on main thread (consistent with current adapter constraints).
