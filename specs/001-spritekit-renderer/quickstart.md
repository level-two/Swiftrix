# Quickstart — Swiftrix SpriteKit Rendering Adapter

## 1. Add the module to your host app

1. Update `Package.swift`:
   ```swift
   .package(path: "../Swiftrix"),
   ```
2. Add `SwiftrixSpriteKitRendering` to the host target dependencies:
   ```swift
   .target(
     name: "GameHost",
     dependencies: ["SwiftrixCore", "SwiftrixSpriteKitRendering"]
   )
   ```

## 2. Create the SpriteKit scene

```swift
import SwiftrixCore
import SwiftrixSpriteKitRendering

let spriteKitScene = SpriteKitScene(
  performanceBudget: .init(maxSyncOpsPerFrame: 200)
)

let skView = SKView(frame: UIScreen.main.bounds)
skView.ignoresSiblingOrder = true
skView.presentScene(spriteKitScene)
```

## 3. Build your Core scene and start rendering

```swift
// Build GameObjects + View components
let player = GameObject(name: "Player")
player.addComponent(SpriteView(textureName: "player", size: CGSize(width: 24, height: 24)))
spriteKitScene.coreScene.addRootObject(player)

spriteKitScene.start() // begins the display-linked loop and syncs nodes
```

## 4. Drive the loop and handle lifecycle

- The bridge runs via SpriteKit’s `update(_:)` or an injected driver.
- To pause/resume (e.g., app background/foreground):
  ```swift
  spriteKitScene.pause()
  spriteKitScene.resume()
  ```
- Call `spriteKitScene.stop()` when unloading, or `spriteKitScene.reset()` to clear mappings and return to idle.
- Optional: wire a `HostLifecycleBridge(scene:)` and forward app lifecycle callbacks.

## 5. Enable debug overlays

```swift
spriteKitScene.setDebugOverlayConfig(DebugOverlayConfig(
  isEnabled: true,
  showBounds: true,
  showAnchors: true
))
```

## 6. Configure the camera

```swift
// Follow a specific GameObject
spriteKitScene.configureCamera(CameraConfig(mode: .followObject(player.id, offset: .zero), zoom: 1.0))

// Or pin the camera
spriteKitScene.configureCamera(CameraConfig(mode: .staticOffset(CGPoint(x: 0, y: 0))))
```

## 7. Touch / hit testing (optional)

Use the bridge’s hit-test helper to map a SpriteKit touch location to a Core `GameObject` ID:

```swift
let location = touch.location(in: spriteKitScene)
if let objectID = spriteKitScene.hitTestObjectID(at: location) {
  // Dispatch to your Core input system with this objectID
}
```

## 8. Deterministic tests with the harness

`SpriteKitTestHarness` (in the test target) runs headless:

```swift
let harness = SpriteKitTestHarness()
let root = GameObject(name: "root")
root.addComponent(ContainerView())
harness.scene.coreScene.addRootObject(root)
harness.scene.start()
harness.step(deltaTime: 1.0 / 60.0) // deterministic tick

XCTAssertEqual(harness.scene.node(for: root.id)?.position, .zero)
```

This mirrors the runtime bridge API so your tests exercise real mapping and sync behavior.
