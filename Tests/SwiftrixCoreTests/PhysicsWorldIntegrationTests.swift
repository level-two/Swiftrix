import XCTest
import CoreGraphics
@testable import SwiftrixCore

private final class CountingPhysicsWorld: PhysicsWorld {
    var stepCount = 0
    func addCollider(_ collider: Collider) {}
    func removeCollider(_ collider: Collider) {}
    func step(fixedDeltaTime: TimeInterval, eventBus: EventBus) { stepCount += 1 }
    func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider] { [] }
}

final class PhysicsWorldIntegrationTests: XCTestCase {
    func testSceneFixedUpdateCallsPhysicsWorld() {
        let physics = CountingPhysicsWorld()
        let scene = Scene(physicsWorld: physics)
        scene.fixedUpdate(fixedDeltaTime: 0.016)
        XCTAssertEqual(physics.stepCount, 1)
    }
}
