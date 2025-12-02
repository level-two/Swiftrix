import XCTest
import CoreGraphics
@testable import SwiftrixCore

private final class StubScene: Scene {
    var rootObjects: [GameObject] = []
    let eventBus: EventBus = DefaultEventBus()
    var inputSystem: InputSystem?
    let physicsWorld: PhysicsWorld = NoopPhysicsWorld()

    var updateCount = 0
    var fixedCount = 0
    var drawCount = 0

    func addRootObject(_ object: GameObject) { rootObjects.append(object) }
    func removeRootObject(_ object: GameObject) { rootObjects.removeAll { $0.id == object.id } }

    func update(deltaTime: TimeInterval) { updateCount += 1 }
    func fixedUpdate(fixedDeltaTime: TimeInterval) { fixedCount += 1 }
    func draw() { drawCount += 1 }
}

private final class NoopPhysicsWorld: PhysicsWorld {
    func addCollider(_ collider: Collider) {}
    func removeCollider(_ collider: Collider) {}
    func step(fixedDeltaTime: TimeInterval, eventBus: EventBus) {}
    func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider] { [] }
}

final class GameLoopTests: XCTestCase {
    func testTickAdvancesFixedAndUpdate() {
        let scene = StubScene()
        let loop = GameLoop(scene: scene, fixedDeltaTime: 0.1)

        loop.tick(deltaTime: 0.25)

        XCTAssertEqual(scene.fixedCount, 2)
        XCTAssertEqual(scene.updateCount, 1)
        XCTAssertEqual(scene.drawCount, 1)
    }
}
