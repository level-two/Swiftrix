import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

/// Lightweight harness used to construct SpriteKit-backed scenes for tests.
final class SpriteKitTestHarness {
    let scene: SpriteKitScene
    let manualDriver: ManualDisplayLinkDriver

    init(fixedDeltaTime: TimeInterval = 1.0 / 60.0, performanceBudget: PerformanceBudget = .default) {
        self.manualDriver = ManualDisplayLinkDriver()
        self.scene = SpriteKitScene(
            displayLinkDriver: manualDriver,
            fixedDeltaTime: fixedDeltaTime,
            performanceBudget: performanceBudget
        )
    }

    func step(deltaTime: TimeInterval = 1.0 / 60.0) {
        manualDriver.tick(deltaTime: deltaTime)
    }
}
