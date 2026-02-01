import XCTest
@testable import SwiftrixCore

final class IntrospectionTests: XCTestCase {
    func testDescribeSceneListsHierarchy() {
        let scene = DefaultScene()
        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        root.addChild(child)
        scene.addRootObject(root)

        let description = DebugIntrospection.describeScene(scene)
        XCTAssertTrue(description.contains("Root"))
        XCTAssertTrue(description.contains("Child"))
    }

    func testDescribeSceneIncludesInputAxes() {
        let input = DefaultInputSystem()
        input.send(event: .axisChanged(name: "Horizontal", value: AxisValue(value: 0.5)))
        input.send(event: .axisChanged(name: "Vertical", value: AxisValue(value: -0.25)))

        let scene = DefaultScene(inputSystem: input)
        let description = DebugIntrospection.describeScene(scene)

        XCTAssertTrue(description.contains("Input axes"))
        // Should list keys in sorted order; check both present.
        XCTAssertTrue(description.contains("Horizontal"))
        XCTAssertTrue(description.contains("Vertical"))
    }
}
