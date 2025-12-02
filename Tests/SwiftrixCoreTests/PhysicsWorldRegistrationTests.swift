import XCTest
import CoreGraphics
@testable import SwiftrixCore

final class PhysicsWorldRegistrationTests: XCTestCase {
    func testAddAndRemoveCollider() {
        let world = DefaultPhysicsWorld()
        let go = DefaultGameObject(name: "Box")
        let collider = BoxCollider(size: Vector2(x: 1, y: 1))
        go.addComponent(collider)

        world.addCollider(collider)
        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil).count, 1)

        world.removeCollider(collider)
        XCTAssertEqual(world.query(overlap: CGRect(x: 0, y: 0, width: 2, height: 2), in: nil).count, 0)
    }
}
