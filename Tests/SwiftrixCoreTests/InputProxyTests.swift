import XCTest
@testable import SwiftrixCore

final class InputProxyTests: XCTestCase {
    func testInputProxyDefaultsWhenNoSystem() {
        let input = InputProxy(nil)

        XCTAssertEqual(input.touches.count, 0)
        XCTAssertEqual(input.axis(named: "Horizontal"), AxisValue(value: 0))
        XCTAssertFalse(input.isButtonDown("Jump"))
        XCTAssertTrue(input.isButtonUp("Jump"))
        XCTAssertFalse(input.isButtonPressed("Jump"))
    }
}
