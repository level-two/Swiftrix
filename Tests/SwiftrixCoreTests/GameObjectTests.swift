import XCTest
@testable import SwiftrixCore

final class GameObjectTests: XCTestCase {
    func testAddChildSetsParent() {
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")
        parent.addChild(child)
        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(parent.children.first === child)
        XCTAssertTrue(child.parent === parent)
    }

    func testGlobalTransformCombinesParentAndChild() {
        let parent = GameObject(name: "Parent", transform: Transform2D(position: Vector2(x: 2, y: 2), scale: Vector2(x: 2, y: 2)))
        let child = GameObject(name: "Child", transform: Transform2D(position: Vector2(x: 1, y: 1)))
        parent.addChild(child)
        XCTAssertEqual(child.globalTransform.position, Vector2(x: 4, y: 4))
    }
}
