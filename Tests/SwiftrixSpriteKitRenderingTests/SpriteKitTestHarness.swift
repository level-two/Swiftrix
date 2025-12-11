import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

/// Lightweight harness used to construct SpriteKit-backed scenes for tests.
final class SpriteKitTestHarness {
    let scene: SpriteKitScene

    init(
        fixedDeltaTime: TimeInterval = 1.0 / 60.0,
        performanceBudget: PerformanceBudget = .default,
        size: CGSize = CGSize(width: 320, height: 480)
    ) {
        self.scene = SpriteKitScene(
            size: size,
            fixedDeltaTime: fixedDeltaTime,
            performanceBudget: performanceBudget
        )
    }

    func step(deltaTime: TimeInterval = 1.0 / 60.0) {
        scene.step(deltaTime: deltaTime)
    }
}
