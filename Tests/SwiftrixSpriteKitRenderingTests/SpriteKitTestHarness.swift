import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

/// Lightweight harness used to construct scenes and adapters for tests.
final class SpriteKitTestHarness {
    let scene: DefaultScene
    let adapter: SpriteKitSceneAdapter
    let manualDriver: ManualDisplayLinkDriver

    init(fixedDeltaTime: TimeInterval = 1.0 / 60.0) {
        self.scene = DefaultScene()
        self.manualDriver = ManualDisplayLinkDriver()
        self.adapter = SpriteKitSceneAdapter(
            scene: scene,
            displayLinkDriver: manualDriver,
            fixedDeltaTime: fixedDeltaTime
        )
    }

    func step(deltaTime: TimeInterval = 1.0 / 60.0) {
        manualDriver.tick(deltaTime: deltaTime)
    }
}
