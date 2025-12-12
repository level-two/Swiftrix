import XCTest
import CoreGraphics
@testable import SwiftrixCore

private final class StubScene: Scene {
    var updateCount = 0
    var fixedCount = 0
    var drawCount = 0

    init() {
        super.init(eventBus: DefaultEventBus(), inputSystem: nil, physicsWorld: NoopPhysicsWorld())
    }

    override func update(deltaTime: TimeInterval) { updateCount += 1 }
    override func fixedUpdate(fixedDeltaTime: TimeInterval) { fixedCount += 1 }
    override func draw() { drawCount += 1 }
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

    func testTickPreservesAccumulatorRemainderAcrossTicks() {
        let scene = StubScene()
        let loop = GameLoop(scene: scene, fixedDeltaTime: 0.1)

        loop.tick(deltaTime: 0.15) // runs 1 fixed update, keeps ~0.05 in accumulator
        loop.tick(deltaTime: 0.06) // pushes accumulator over the threshold for another fixed update

        XCTAssertEqual(scene.fixedCount, 2)
        XCTAssertEqual(scene.updateCount, 2)
        XCTAssertEqual(scene.drawCount, 2)
    }

    func testTickWithLargeDeltaRunsManyFixedSteps() {
        let scene = StubScene()
        let loop = GameLoop(scene: scene, fixedDeltaTime: 0.1)

        loop.tick(deltaTime: 1.0) // expect 10 fixed updates

        XCTAssertEqual(scene.fixedCount, 10)
        XCTAssertEqual(scene.updateCount, 1)
        XCTAssertEqual(scene.drawCount, 1)
    }

    func testTickWithZeroDeltaStillCallsUpdateAndDraw() {
        let scene = StubScene()
        let loop = GameLoop(scene: scene, fixedDeltaTime: 0.1)

        loop.tick(deltaTime: 0.0)

        XCTAssertEqual(scene.fixedCount, 0)
        XCTAssertEqual(scene.updateCount, 1)
        XCTAssertEqual(scene.drawCount, 1)
    }
}
