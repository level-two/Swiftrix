import XCTest
@testable import SwiftrixCore

final class InputSystemTests: XCTestCase {
    func testButtonStatesAndPendingEvents() {
        let input = DefaultInputSystem()
        input.send(event: .buttonDown("Jump"))
        XCTAssertTrue(input.isButtonDown("Jump"))
        XCTAssertTrue(input.isButtonPressed("Jump"))

        let events = input.pendingEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first, .buttonDown("Jump"))

        // After update, pressed should clear
        input.update()
        XCTAssertFalse(input.isButtonPressed("Jump"))
    }

    func testAxisValuesUpdate() {
        let input = DefaultInputSystem()
        input.send(event: .axisChanged(name: "Horizontal", value: AxisValue(value: 0.5)))
        XCTAssertEqual(input.axis(named: "Horizontal"), AxisValue(value: 0.5))
    }

    func testButtonPressedTrueOnlyOnFirstFrame() {
        let input = DefaultInputSystem()
        input.send(event: .buttonDown("Jump"))

        XCTAssertTrue(input.isButtonPressed("Jump"))
        XCTAssertTrue(input.isButtonDown("Jump"))

        // After update, pressed should clear but down remains
        input.update()
        XCTAssertFalse(input.isButtonPressed("Jump"))
        XCTAssertTrue(input.isButtonDown("Jump"))

        // Button up clears down
        input.send(event: .buttonUp("Jump"))
        XCTAssertFalse(input.isButtonDown("Jump"))
    }
}
