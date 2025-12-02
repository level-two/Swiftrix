import XCTest
@testable import SwiftrixCore

final class MathTests: XCTestCase {
    func testVectorAddition() {
        let a = Vector2(x: 1, y: 2)
        let b = Vector2(x: 3, y: 4)
        XCTAssertEqual(a + b, Vector2(x: 4, y: 6))
    }

    func testTransformApplyingUsesParentPositionAndScale() {
        let parent = Transform2D(position: Vector2(x: 1, y: 1), rotation: 0, scale: Vector2(x: 2, y: 2))
        let child = Transform2D(position: Vector2(x: 1, y: 0.5), rotation: 0.1, scale: Vector2(x: 1, y: 1))
        let combined = parent.applying(child)
        XCTAssertEqual(combined.position, Vector2(x: 3, y: 2))
        XCTAssertEqual(combined.rotation, 0.1)
        XCTAssertEqual(combined.scale, Vector2(x: 2, y: 2))
    }
}
