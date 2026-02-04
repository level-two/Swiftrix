import XCTest
@testable import SwiftrixCore

final class GameObjectSceneReferenceTests: XCTestCase {
    func testSceneReferenceSetForRootAndChildren() {
        let scene = TestScene()
        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        root.addChild(child)

        scene.addRootObject(root)

        XCTAssertTrue(root.scene === scene)
        XCTAssertTrue(child.scene === scene)
    }

    func testSceneReferencePropagatesWhenAddingChildLater() {
        let scene = TestScene()
        let root = GameObject(name: "Root")
        scene.addRootObject(root)

        let child = GameObject(name: "Child")
        root.addChild(child)

        XCTAssertTrue(child.scene === scene)
    }

    func testSceneReferenceClearsOnRemoveRoot() {
        let scene = TestScene()
        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        root.addChild(child)
        scene.addRootObject(root)

        scene.removeRootObject(root)

        XCTAssertNil(root.scene)
        XCTAssertNil(child.scene)
    }
}
