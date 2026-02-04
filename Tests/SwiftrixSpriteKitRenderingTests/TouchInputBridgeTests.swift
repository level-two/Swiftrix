import XCTest
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class TouchInputBridgeTests: XCTestCase {
    func testTouchLifecycleTransitions() {
        let input = SpriteKitTouchInputSystem()

        input.beginTouch(id: 1, position: Vector2(x: 1, y: 1))
        input.update()
        XCTAssertEqual(input.touches().first?.phase, .began)

        input.update()
        XCTAssertEqual(input.touches().first?.phase, .stationary)

        input.moveTouch(id: 1, position: Vector2(x: 2, y: 3))
        input.update()
        XCTAssertEqual(input.touches().first?.phase, .moved)
        XCTAssertEqual(input.touches().first?.position, Vector2(x: 2, y: 3))

        input.update()
        XCTAssertEqual(input.touches().first?.phase, .stationary)

        input.endTouch(id: 1, position: Vector2(x: 2, y: 3))
        input.update()
        XCTAssertEqual(input.touches().first?.phase, .ended)

        input.update()
        XCTAssertTrue(input.touches().isEmpty)
    }

    func testTouchesSortedById() {
        let input = SpriteKitTouchInputSystem()
        input.beginTouch(id: 2, position: Vector2(x: 0, y: 0))
        input.beginTouch(id: 1, position: Vector2(x: 0, y: 0))
        input.update()

        let touches = input.touches()
        XCTAssertEqual(touches.map(\.id), [1, 2])
    }
}
