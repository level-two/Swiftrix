import XCTest
import CoreGraphics
@testable import SwiftrixCore

final class PhysicsWorldQueryTests: XCTestCase {
    func testOverlapQueryFindsColliders() {
        let world = DefaultPhysicsWorld()
        let go = GameObject(name: "Box", transform: Transform2D(position: Vector2(x: 1, y: 1)))
        let collider = BoxCollider(size: Vector2(x: 1, y: 1))
        go.addComponent(collider)
        world.addCollider(collider)

        let results = world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil)
        XCTAssertEqual(results.count, 1)
    }

    func testQueryRespectsCollisionGroup() {
        let world = DefaultPhysicsWorld()

        let a = GameObject(name: "A")
        let colliderA = BoxCollider(size: Vector2(x: 1, y: 1), collisionGroup: .player)
        a.addComponent(colliderA)
        world.addCollider(colliderA)

        let b = GameObject(name: "B")
        let colliderB = BoxCollider(size: Vector2(x: 1, y: 1), collisionGroup: .enemy)
        b.addComponent(colliderB)
        world.addCollider(colliderB)

        let rect = CGRect(x: -1, y: -1, width: 3, height: 3)
        XCTAssertEqual(world.query(overlap: rect, in: .player).count, 1)
        XCTAssertEqual(world.query(overlap: rect, in: .enemy).count, 1)
        XCTAssertEqual(world.query(overlap: rect, in: nil).count, 2)
    }

    func testLocalOffsetAffectsQuery() {
        let world = DefaultPhysicsWorld()

        let go = GameObject(name: "Offset")
        let collider = BoxCollider(size: Vector2(x: 1, y: 1), localOffset: Vector2(x: 5, y: 0))
        go.addComponent(collider)
        world.addCollider(collider)

        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil).count, 0)
        XCTAssertEqual(world.query(overlap: CGRect(x: 5, y: 0, width: 1, height: 1), in: nil).count, 1)
    }

    func testDefaultAnchorCentersColliderOnObject() {
        let world = DefaultPhysicsWorld()

        let go = GameObject(name: "Centered")
        let collider = BoxCollider(size: Vector2(x: 2, y: 2))
        go.addComponent(collider)
        world.addCollider(collider)

        // With a centered anchor, the collider extends equally around the object's position.
        XCTAssertEqual(world.query(overlap: CGRect(x: -1.1, y: -1.1, width: 0.2, height: 0.2), in: nil).count, 1)
    }

    func testCustomAnchorShiftsColliderOrigin() {
        let world = DefaultPhysicsWorld()

        let go = GameObject(name: "TopLeft")
        let collider = BoxCollider(
            size: Vector2(x: 2, y: 2),
            anchor: Vector2(x: 0, y: 0),
            localOffset: Vector2(x: 2, y: 0)
        )
        go.addComponent(collider)
        world.addCollider(collider)

        // Anchor (0,0) uses the game object's position + offset as the top-left corner.
        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 1, height: 1), in: nil).count, 0)
        XCTAssertEqual(world.query(overlap: CGRect(x: 2, y: 0, width: 1, height: 1), in: nil).count, 1)
    }
}
