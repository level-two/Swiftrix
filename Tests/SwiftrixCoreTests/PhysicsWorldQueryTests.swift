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
}
