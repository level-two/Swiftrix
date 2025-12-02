import XCTest
@testable import SwiftrixCore

final class CoreProtocolsTests: XCTestCase {
    func testDestroyableMarksObject() {
        let go = DefaultGameObject(name: "Temp")
        XCTAssertFalse(go.isDestroyed)
        go.destroy()
        XCTAssertTrue(go.isDestroyed)
    }
}
