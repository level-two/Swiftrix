# Implementation Plan: Dedicated Camera Component (Unity-like)

**Feature**: `002-camera-component`  
**Date**: 2026-02-04  
**Input**: `specs/002-camera-component/spec.md`

## Summary

Add a renderer-agnostic `Camera` component in `SwiftrixCore` with `zoomScale`, `depth`, and read-only `aspectRatio`. Update the SpriteKit adapter to discover cameras in the Core scene graph, choose an active camera deterministically, and drive an `SKCameraNode` from the selected camera’s owning `GameObject` transform. Remove the legacy SpriteKit-only camera API (`CameraController` / `configureCamera`).

## Technical Context

- **Language/Version**: Swift 5.9 (SwiftPM package)
- **Core constraints**: `SwiftrixCore` must not import SpriteKit/UIKit/SwiftUI/Metal/etc.
- **Host adapter**: `SwiftrixSpriteKitRendering` may import SpriteKit and is responsible for rendering behavior and host-derived values (aspect ratio).

## Public API (proposed)

### SwiftrixCore

- `public protocol CameraComponent: AnyObject`
  - `var zoomScale: Double { get set }`
  - `var depth: Double { get set }`
  - `var aspectRatio: Double { get }` (read-only)
- `public final class Camera: Component, CameraComponent`
  - Default: `zoomScale == 1.0`, `depth == 0`, `aspectRatio == 1.0`
  - Holds backing storage and validation helpers (e.g., sanitize zoomScale, store aspectRatio).

### SwiftrixSpriteKitRendering (public surface)

- No camera controller types.
- Camera behavior is driven purely by discovering Core `Camera`/`CameraComponent` components in the scene graph.

## Data Model & Invariants

### Camera selection

- Candidate camera = `GameObject` that:
  - is not destroyed
  - `gameObject.isEnabled == true`
  - has at least one attached `CameraComponent` where `camera.isEnabled == true`
- Chosen camera:
  - highest `camera.depth`
  - tie-breaker: first encountered in stable traversal order

### Zoom semantics

- `zoomScale` maps directly to SpriteKit `SKCameraNode.setScale`.
  - `1.0` = default scale
  - `> 1.0` = zoom out (world appears smaller)
  - `0 < zoomScale < 1.0` = zoom in
- Invalid values (≤0, NaN, infinity) must be sanitized to a safe default (recommend `1.0`).

### Aspect ratio semantics

- Exposed as `Double` where:
  - `aspectRatio = width / height`
  - safe default: `1.0` when height is 0 or unknown
- Updated by the host adapter:
  - at minimum once per frame, or
  - on `SKScene.didChangeSize(_:)` plus any other relevant lifecycle points

## SpriteKit Adapter Implementation Strategy

### Where camera updates happen

- After the Core tick and after node sync, in the same place the current adapter updates overlays.
- Update order:
  1. Core loop tick
  2. rebuild bindings / dirty queue sync
  3. select active camera
  4. update `SKCameraNode` transform + zoom scale
  5. update camera component `aspectRatio`

### Transform mapping

- Use Core `GameObject.globalTransform` to set camera:
  - `cameraNode.position = CGPoint(x: global.position.x, y: global.position.y)`
  - `cameraNode.zRotation = CGFloat(global.rotation)`
- Do not depend on a view component being present on the camera object.

### No camera present

- If no enabled camera exists:
  - set `scene.camera = nil`
  - remove any previously created camera node from the scene

## Removal / Cleanup Plan

- Delete:
  - `Sources/SwiftrixSpriteKitRendering/Camera/CameraController.swift`
- Remove from `SpriteKitScene`:
  - `public var cameraController`
  - `configureCamera(_:)`
  - per-frame callsite `cameraController?.update(...)`
- Update documentation:
  - `docs/public-api.md`
  - `docs/api-reference.md`
  - `docs/host-integration-spritekit.md`
  - `specs/001-spritekit-renderer/tasks.md` (remove/replace the camera-controller task)

## Testing Plan

### SwiftrixCore tests (unit)

- `Camera` default values are correct.
- `Camera` is a `Component` and respects `isEnabled` semantics (covered indirectly by existing component tests; add direct test for completeness).
- `aspectRatio` is readable publicly and not directly settable by consumers; it changes only through package-level update hook(s).

### SwiftrixSpriteKitRendering tests (unit/integration headless)

- Active camera selection:
  - highest depth wins
  - disabled camera ignored
  - disabled owning object ignored
  - tie-breaker stable
- Camera transform application:
  - moving/rotating camera object moves/rotates `scene.camera` node
- Aspect ratio update:
  - after a `didChangeSize` or resize simulation, `camera.aspectRatio` updates
- Legacy tests referencing `configureCamera` must be updated to use the new component.

## Implementation Guidelines (for a weaker agent)

- Keep changes small and staged: implement core types + tests first, then adapter changes + tests, then docs cleanup.
- Avoid “smart” abstractions. One traversal + simple selection rules.
- Use `package` access for adapter hooks needed to set `aspectRatio`.
- Do not import SpriteKit in core; do not add `SK*` types in core APIs.
