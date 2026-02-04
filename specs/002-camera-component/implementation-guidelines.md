# Implementation Guidelines (for weaker agent)

This file is intentionally procedural and explicit.

## Guardrails

- Do not import SpriteKit/UIKit/SwiftUI/Metal/AVFoundation into `SwiftrixCore`.
- Prefer simple code over clever code. Avoid new frameworks or heavy abstractions.
- Keep behavior deterministic: selection depends only on Core state and traversal order.
- Do not keep the old camera API: fully remove it (`CameraController`, `CameraConfig`, `SpriteKitScene.configureCamera`).

## Step-by-step (recommended order)

1. **Core first (red → green)**  
   - Add tests for `Camera` defaults and `zoomScale` validation.
   - Implement `CameraComponent` and `Camera` (with validation + aspect ratio storage inside `Camera`).
   - Add a package-level method on `Camera` that the adapter can call to update `aspectRatio` without exposing a public setter.

2. **Adapter selection + application (red → green)**  
   - Add tests in `SwiftrixSpriteKitRenderingTests` for camera selection and transform mapping.
   - Implement in `SpriteKitScene`:
     - discover cameras in Core graph (single traversal)
     - select active by highest `depth`, stable tie-break
     - create/update/remove an `SKCameraNode`
     - apply `globalTransform` (position + rotation) and `zoomScale`
     - update `aspectRatio` from `scene.size`

3. **Remove legacy camera API**  
   - Delete the old camera controller file.
   - Remove any public API surface from `SpriteKitScene` related to the legacy camera.
   - Update any tests that referenced the old API.

4. **Docs + specs cleanup**  
   - Remove `CameraController` references from `docs/*` and `specs/001-spritekit-renderer/*`.

5. **Final validation**
   - Run `swift test` at repo root.

## Common pitfalls

- **Camera object without View**: must still work. Do not require `SpriteKitRenderable`.
- **Invalid zoomScale**: sanitize values (≤0, NaN, ±∞) to `1.0`.
- **No cameras**: ensure `scene.camera` is `nil` and stale camera nodes are removed.
- **Aspect ratio**: avoid division by zero when `size.height == 0`.

## Reference pseudocode (SpriteKitScene)

Camera discovery and selection (single traversal):

```swift
func findActiveCamera() -> (owner: GameObject, camera: CameraComponent)? {
  var best: (GameObject, CameraComponent)? = nil
  walkDepthFirst(rootObjects) { object in
    guard !object.isDestroyed, object.isEnabled else { return }
    for camera in object.getComponents(CameraComponent.self) where camera.isEnabled {
      if best == nil || camera.depth > best!.1.depth {
        best = (object, camera)
      }
    }
  }
  return best
}
```

Applying the active camera:

```swift
if let (owner, camera) = findActiveCamera() {
  ensureCameraNodeAttached()
  let t = owner.globalTransform
  cameraNode.position = CGPoint(x: t.position.x, y: t.position.y)
  cameraNode.zRotation = CGFloat(t.rotation)
  cameraNode.setScale(CGFloat(validated(camera.zoomScale)))
  camera._updateAspectRatio(width: size.width, height: size.height) // via package hook
} else {
  detachCameraNode()
}
```
