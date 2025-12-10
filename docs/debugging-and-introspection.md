# Debugging & Introspection

This guide covers practical techniques for understanding what SwiftrixCore is doing at runtime and how to debug rendering when using the SpriteKit adapter.

---

## 1. Inspecting Scenes with DebugIntrospection

`DebugIntrospection` provides a textual view of your scene:

```swift
import SwiftrixCore

let description = DebugIntrospection.describeScene(scene)
print(description)
```

Output example:

```text
- Player [2 components]
  - Weapon [1 components]
Input axes: moveX, moveY
```

Use this to quickly answer:

- Which game objects exist?
- How many components does each have?
- Are input axes wired as expected (for `DefaultInputSystem`)?

If things are missing in the description, they’re not in the scene graph.

---

## 2. Common Rendering Issues

When something doesn’t render as expected, check:

1. **Is the object in the scene?**
   - Confirm with `DebugIntrospection.describeScene(scene)`.
2. **Is the object enabled?**
   - `gameObject.isEnabled` must be `true`.
   - Components also respect `isEnabled`.
3. **Are you updating transforms?**
   - Ensure you write back to `gameObject.localTransform` from Scripts.
4. **Are View components present?**
   - At least one `View` (or adapter-specific `SpriteView` / `ContainerView`) should be attached.
5. **Is the host calling the loop?**
   - Verify `GameLoop.tick(deltaTime:)` or the SpriteKit adapter’s display-linked driver is running.

---

## 3. Debugging with the SpriteKit Adapter

When using `SwiftrixSpriteKitRendering`:

### Debug overlays

Enable lightweight overlays to see where the adapter thinks objects are:

```swift
adapter.setDebugOverlayConfig(DebugOverlayConfig(
    isEnabled: true,
    showBounds: true,
    showAnchors: true
))
```

You’ll see:

- bounds rectangles around mirrored nodes
- optional anchor markers

If you see overlays but no textures, you likely have an asset or view configuration issue.

### Diagnostics

Attach a diagnostic callback to log adapter issues (e.g., missing textures):

```swift
adapter.onDiagnostic = { message in
    print("[SwiftrixSpriteKitRendering] \(message)")
}
```

Use this to quickly spot:

- missing texture names
- unexpected view mappings

### Hit-testing

To verify that touches map to the expected game object:

```swift
let location = touch.location(in: adapter.session.skScene)
if let objectID = adapter.hitTestObjectID(at: location) {
    print("Touched object \(objectID)")
} else {
    print("No object under touch")
}
```

If hit-testing doesn’t find your object, check:

- the object has a View component
- the node isn’t `isHidden`
- transforms are where you expect them to be.

---

## 4. Verifying Behavior with Tests

The repo includes tests that are good reference points:

- `Tests/SwiftrixCoreTests` — core behavior (scene traversal, game loop, physics, input).
- `Tests/SwiftrixSpriteKitRenderingTests` — adapter behavior (binding, sync, lifecycle, camera, hit-testing).

You can mirror these patterns in your own tests:

```swift
let harness = SpriteKitTestHarness()
let root = GameObject(name: "root")
root.addComponent(ContainerView())
harness.scene.addRootObject(root)

harness.adapter.start()
harness.step(deltaTime: 1.0 / 60.0)

XCTAssertEqual(harness.adapter.node(for: root.id)?.position, .zero)
```

Running `swift test` regularly helps catch regressions in both engine logic and adapter integration.

---

## 5. When to Add More Introspection

If you find yourself repeatedly asking the same questions during debugging (for example, “which colliders overlap this region?”), consider:

- adding a small, focused function to `DebugIntrospection` or a similar utility type, and
- covering it with a test so future contributors (human or AI) can rely on it safely.

Keep new debugging helpers:

- simple and side-effect free
- focused on **observing** state, not changing it.

