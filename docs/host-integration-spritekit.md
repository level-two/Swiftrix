# Host Integration with SpriteKit

This guide shows how to run SwiftrixCore inside a SpriteKit-based app. There are two main patterns:

- **Manual integration** using `GameLoop` inside your own `SKScene`.
- **Adapter integration** using `SwiftrixSpriteKitRendering` and `SpriteKitScene`.

Use manual integration if you want full control over nodes and rendering. Use the SpriteKitScene bridge if you want a higher-level integration that keeps SpriteKit concerns out of your game logic.

---

## 1. Package Setup

In the host app’s `Package.swift`:

```swift
dependencies: [
    .package(path: "../Swiftrix"),
],
targets: [
    .target(
        name: "YourGame",
        dependencies: [
            .product(name: "SwiftrixCore", package: "Swiftrix"),
            .product(name: "SwiftrixSpriteKitRendering", package: "Swiftrix"), // optional SpriteKit bridge
        ]
    )
]
```

---

## 2. Pattern A — Manual GameLoop Integration

In this pattern, SpriteKit owns all nodes. SwiftrixCore runs the game loop; you manually mirror state into `SKNode`s.

```swift
import SpriteKit
import SwiftrixCore

final class GameScene: SKScene {
    private var swiftrixScene: Scene!
    private var loop: GameLoop!
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        let input = DefaultInputSystem()
        swiftrixScene = Scene(inputSystem: input)
        loop = GameLoop(scene: swiftrixScene)

        let player = GameObject(name: "Player")
        // Attach components (Script, View, Collider, etc.)
        swiftrixScene.addRootObject(player)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        loop.tick(deltaTime: delta)
        renderSwiftrixObjects()
    }

    private func renderSwiftrixObjects() {
        // Traverse swiftrixScene.rootObjects and update/create SKNodes.
        // You decide how View components map to SpriteKit nodes.
    }
}
```

**When to use:**

- You need a very custom SpriteKit hierarchy or bespoke rendering.
- You want minimal dependencies and are fine writing your own mapping layer.

---

## 3. Pattern B — SpriteKitScene Integration

In this pattern, you use the `SwiftrixSpriteKitRendering` module to mirror the scene into SpriteKit and drive the loop for you via `SpriteKitScene`.

```swift
import SpriteKit
import SwiftrixCore
import SwiftrixSpriteKitRendering

final class GameScene: SpriteKitScene {
    override func bootstrapScene() {
        let player = GameObject(name: "Player")
        player.addComponent(SpriteView(textureName: "player", size: CGSize(width: 24, height: 24)))
        coreScene.addRootObject(player)
    }
}

final class GameViewController: UIViewController {
    private var spriteKitScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        spriteKitScene = GameScene()

        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.presentScene(spriteKitScene)
        view.addSubview(skView)

        spriteKitScene.start()
    }
}
```

### Lifecycle

```swift
// Pause/resume (e.g. app background/foreground)
spriteKitScene.pause()
spriteKitScene.resume()

// Stop when you tear down the view
spriteKitScene.stop()

// Reset clears mappings and returns the bridge to idle
spriteKitScene.reset()
```

You can also use `HostLifecycleBridge` to wire app lifecycle events:

```swift
let lifecycle = HostLifecycleBridge(scene: spriteKitScene)

func applicationDidEnterBackground(_ application: UIApplication) {
    lifecycle.applicationDidEnterBackground()
}

func applicationWillEnterForeground(_ application: UIApplication) {
    lifecycle.applicationWillEnterForeground()
}
```

### Camera and Debug Overlays

```swift
// Camera follow
spriteKitScene.configureCamera(
    CameraConfig(mode: .followObject(player.id, offset: .zero), zoom: 1.0)
)

// Debug overlays
spriteKitScene.setDebugOverlayConfig(DebugOverlayConfig(
    isEnabled: true,
    showBounds: true,
    showAnchors: true
))
```

Notes:

- Bounds and anchor markers are drawn in scene space (so they stay correct under nested transforms).
- Anchor markers indicate the mirrored node position (for sprites, this corresponds to `SKSpriteNode.anchorPoint`).

### Hit Testing

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: spriteKitScene)
    if let objectID = spriteKitScene.hitTestObjectID(at: location) {
        // Map to your Core input system using the objectID.
    }
}
```

**When to use:**

- You want SwiftrixCore as your game state and logic, and SpriteKit as a thin rendering/input shell.
- You’d like built-in lifecycle handling, mapping, and debug overlays without reimplementing them.

---

## 4. Choosing Between A and B

- Start with **SpriteKitScene** for most demos and games; it keeps your gameplay code focused on SwiftrixCore.
- Drop down to the **manual GameLoop pattern** if:
  - you need custom rendering that doesn’t map well to the bridge, or
  - you’re targeting a non-SpriteKit renderer and want a very similar pattern.

### Anchors and bounds

- `View.anchor` and `Collider.anchor` default to `(0.5, 0.5)` (center). `(0,0)` is top-left, `(1,1)` is bottom-right in local bounds.
- `SpriteView.anchor` maps directly to `SKSpriteNode.anchorPoint`. Changing it at runtime will update the bound node on the next sync.
- Bounds and anchor markers drawn by the debug overlay are computed in scene space to stay correct under nested transforms.

### Sprite animations

- `SpriteView.animate(with:timePerFrame:repeatForever:)` starts an `SKAction`-backed texture animation on the bound `SKSpriteNode`. Call it after configuring your texture array:

```swift
let walkFrames: [SKTexture] = loadWalkTextures()
spriteView.animate(with: walkFrames, timePerFrame: 0.08) // defaults to repeatForever = true
```

- You can also call `spriteView.animate(textureNames:timePerFrame:repeatForever:)` to build textures by name on your behalf.
- Call `spriteView.stopAnimation()` to remove the running animation.
- Animation requests are applied on the next sync tick; they will also run when the node is (re)created.
