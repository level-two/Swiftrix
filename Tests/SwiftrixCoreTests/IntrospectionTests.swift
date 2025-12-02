import XCTest
@testable import SwiftrixCore

final class IntrospectionTests: XCTestCase {
    func testDescribeSceneListsHierarchy() {
        let scene = DefaultScene()
        let root = DefaultGameObject(name: "Root")
        let child = DefaultGameObject(name: "Child")
        root.addChild(child)
        scene.addRootObject(root)

        let description = DebugIntrospection.describeScene(scene)
        XCTAssertTrue(description.contains("Root"))
        XCTAssertTrue(description.contains("Child"))
    }
}
