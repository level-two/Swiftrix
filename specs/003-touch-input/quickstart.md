# Quickstart — Touch Input (Unity-like)

## 1. Read touches from a Script

```swift
import SwiftrixCore

final class TouchDebugScript: Script {
  override func update(deltaTime: TimeInterval) {
    for touch in input.touches {
      _ = touch.position
      switch touch.phase {
      case .began:
        // start gesture
        break
      case .moved, .stationary:
        // continue gesture
        break
      case .ended, .cancelled:
        // finish gesture
        break
      }
    }
  }
}
```

## 2. Provide touch input from a host (conceptual)

The host adapter is responsible for translating physical touch callbacks into core `Touch` snapshots and exposing them through the scene’s `inputSystem`.

For SpriteKit, this is typically done by:

- capturing `touchesBegan/Moved/Ended/Cancelled`
- mapping each `UITouch` to a stable `Touch.id`
- reporting `Touch(position:, phase:)` through a touch-capable input system

## 3. Sampling point (important)

Touches are sampled once per rendered frame:

- after all `fixedUpdate` steps
- right before the scene’s `update(deltaTime:)` traversal

This means fixed-step systems observe the previous frame’s input snapshot (Unity-like).
