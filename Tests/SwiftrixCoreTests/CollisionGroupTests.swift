import XCTest
@testable import SwiftrixCore

final class CollisionGroupTests: XCTestCase {
    func testCustomEquality() {
        XCTAssertEqual(CollisionGroup.custom(1), CollisionGroup.custom(1))
        XCTAssertNotEqual(CollisionGroup.custom(1), CollisionGroup.custom(2))
    }
}
