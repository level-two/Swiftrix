# Quickstart — Swiftrix SpriteKit Rendering Adapter

## 1. Add the module to your host app

1. Update `Package.swift`:
   ```swift
   .package(path: "../Swiftrix"),
   ```
2. Add `SwiftrixSpriteKitRendering` to the host target dependencies:
   ```swift
   .target(
     name: "PacmanHost",
     dependencies: ["SwiftrixCore", "SwiftrixSpriteKitRendering"]
   )
   ```

## 2. Create the adapter + SpriteKit scene

```swift
let adapter = SpriteKitSceneAdapter(
  performanceBudget: .init(maxNodes: 500, maxHierarchyDepth: 6, maxSyncOpsPerFrame: 200),
  debugOverlay: .disabled
)
let skView = SKView(frame: UIScreen.main.bounds)
skView.ignoresSiblingOrder = true
skView.presentScene(adapter.skScene)
```

## 3. Bind a Core scene

```swift
let coreScene = DefaultScene()
// populate GameObjects + Views as usual
adapter.bind(coreScene: coreScene, rootObject: coreScene.root)
adapter.start()
```

## 4. Drive the loop

- The adapter installs a `CADisplayLink` automatically.
- To pause/resume (e.g., app lifecycle):
  ```swift
  adapter.pause(reason: .backgrounded)
  adapter.resume()
  ```
- Call `adapter.stop()` when unloading to release nodes.

## 5. Enable debug overlays & inspection

```swift
adapter.debugOverlay = .init(
  enabled: true,
  showBounds: true,
  showAnchors: true,
  highlightObjectIds: [player.id]
)

let inspector = adapter.makeInspector()
let mapping = inspector.mapping(for: player.id)
print(mapping.nodePath)
```

## 6. Run automated tests

- Import `SwiftrixSpriteKitRenderingTestsSupport` helper (shipped with the module) to spin up a headless `SKView`.
- Use `SpriteKitTestHarness` to tick the adapter deterministically:
  ```swift
  harness.tick(frames: 1) // runs fixed+variable update + sync
  ```
- Assert node mirrors:
  ```swift
  XCTAssertEqual(harness.node(for: player.id)?.position, CGPoint(x: 42, y: 0))
  ```

## 7. Handling camera follow

```swift
adapter.camera.follow(objectID: player.id, damping: 0.15)
```

Set `adapter.camera.mode = .static(offset: .zero)` to reset.

## 8. Touch / hit testing (optional)

1. Enable mapping:
   ```swift
   adapter.enableHitTesting()
   ```
2. In your `SKView` delegate:
   ```swift
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     touches.forEach { adapter.handleTouch($0, phase: .began) }
   }
   ```
3. Adapter emits Core input events with the originating `GameObject` ID.
