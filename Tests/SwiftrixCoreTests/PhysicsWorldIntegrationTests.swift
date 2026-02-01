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
        let scene = DefaultScene(physicsWorld: physics)
        scene.fixedUpdate(fixedDeltaTime: 0.016)
        XCTAssertEqual(physics.stepCount, 1)
    }

    func testStepIgnoresDisabledCollidersAndDestroyedObjects() {
        let world = DefaultPhysicsWorld()
        let bus = DefaultEventBus()

        let goA = GameObject(name: "A")
        let colliderA = BoxCollider(size: Vector2(x: 1, y: 1))
        let scriptA = CollisionCountingScript()
        goA.addComponent(colliderA)
        goA.addComponent(scriptA)

        let goB = GameObject(name: "B")
        let colliderB = BoxCollider(size: Vector2(x: 1, y: 1))
        goB.addComponent(colliderB)

        world.addCollider(colliderA)
        world.addCollider(colliderB)

        colliderB.isEnabled = false
        world.step(fixedDeltaTime: 0.016, eventBus: bus)
        XCTAssertEqual(scriptA.collisions, 0)

        colliderB.isEnabled = true
        world.step(fixedDeltaTime: 0.016, eventBus: bus)
        XCTAssertEqual(scriptA.collisions, 1)

        goA.destroy()
        world.step(fixedDeltaTime: 0.016, eventBus: bus)
        XCTAssertEqual(scriptA.collisions, 1)
    }

    func testReleasedCollidersArePrunedOnStep() {
        let world = DefaultPhysicsWorld()
        let bus = DefaultEventBus()

        var go: GameObject? = GameObject(name: "Box")
        var collider: BoxCollider? = BoxCollider(size: Vector2(x: 1, y: 1))
        go?.addComponent(collider!)

        world.addCollider(collider!)
        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil).count, 1)

        go = nil
        collider = nil

        world.step(fixedDeltaTime: 0.016, eventBus: bus)
        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil).count, 0)
    }
}

private final class CollisionCountingScript: Script {
    var collisions = 0
    override func onCollision(with other: Collider) { collisions += 1 }
}
