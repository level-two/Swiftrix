import XCTest
import CoreGraphics
@testable import SwiftrixCore

private final class CollisionScript: Script {
    weak var gameObject: GameObjectInterface?
    var isEnabled: Bool = true
    var collisions: Int = 0
    func update(deltaTime: TimeInterval) {}
    func onCollision(with other: Collider) { collisions += 1 }
}

final class CollisionEventTests: XCTestCase {
    func testCollisionPostsEventAndNotifiesScripts() async {
        let bus = DefaultEventBus()
        let world = DefaultPhysicsWorld()

        let goA = GameObject(name: "A")
        let colliderA = BoxCollider(size: Vector2(x: 1, y: 1))
        let scriptA = CollisionScript()
        goA.addComponent(colliderA)
        goA.addComponent(scriptA)

        let goB = GameObject(name: "B", transform: Transform2D(position: Vector2(x: 0.5, y: 0)))
        let colliderB = BoxCollider(size: Vector2(x: 1, y: 1))
        let scriptB = CollisionScript()
        goB.addComponent(colliderB)
        goB.addComponent(scriptB)

        world.addCollider(colliderA)
        world.addCollider(colliderB)

        let stream = bus.subscribe(CollisionEvent.self)
        let task = Task { await stream.first(where: { _ in true }) }

        world.step(fixedDeltaTime: 0.016, eventBus: bus)

        let event = await task.value
        XCTAssertNotNil(event)
        XCTAssertEqual(scriptA.collisions, 1)
        XCTAssertEqual(scriptB.collisions, 1)
    }
}
