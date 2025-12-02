import XCTest
@testable import SwiftrixCore

final class InputConfigTests: XCTestCase {
    func testAxisConfigEquality() {
        let a = AxisConfig(name: "Horizontal", positiveKeys: [.rightArrow], negativeKeys: [.leftArrow], sensitivity: 1)
        let b = AxisConfig(name: "Horizontal", positiveKeys: [.rightArrow], negativeKeys: [.leftArrow], sensitivity: 1)
        XCTAssertEqual(a, b)
    }
}
