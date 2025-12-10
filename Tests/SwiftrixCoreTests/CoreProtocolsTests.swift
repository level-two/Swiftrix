import XCTest
@testable import SwiftrixCore

final class CoreProtocolsTests: XCTestCase {
    func testDestroyableMarksObject() {
        let go = GameObject(name: "Temp")
        XCTAssertFalse(go.isDestroyed)
        go.destroy()
        XCTAssertTrue(go.isDestroyed)
    }
}
