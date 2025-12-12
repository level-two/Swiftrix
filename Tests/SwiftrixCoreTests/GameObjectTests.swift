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

    func testReparentMovesChildAndClearsOldParent() {
        let parentA = GameObject(name: "A")
        let parentB = GameObject(name: "B")
        let child = GameObject(name: "Child")

        parentA.addChild(child)
        parentB.addChild(child) // should detach from A and attach to B

        XCTAssertTrue(child.parent === parentB)
        XCTAssertFalse(parentA.children.contains { $0 === child })
        XCTAssertTrue(parentB.children.contains { $0 === child })
    }

    func testAddChildPreventsCyclesAndDuplicates() {
        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        let grandchild = GameObject(name: "Grandchild")

        root.addChild(child)
        child.addChild(grandchild)

        // Adding duplicate should be ignored
        root.addChild(child)
        XCTAssertEqual(root.children.count, 1)

        // Prevent self-parenting
        child.addChild(child)
        XCTAssertEqual(child.children.count, 1) // unchanged

        // Prevent cycles (cannot add ancestor as child)
        grandchild.addChild(root)
        XCTAssertFalse(grandchild.children.contains { $0 === root })
    }

    func testOnStartAndOnDestroyAreCalledOncePerObject() {
        final class HookedObject: GameObject {
            var starts = 0
            var destroys = 0
            override func onStart() { starts += 1 }
            override func onDestroy() { destroys += 1 }
        }

        let root = HookedObject(name: "root")
        let child = HookedObject(name: "child")
        root.addChild(child)

        root.update(deltaTime: 1)
        root.update(deltaTime: 1)

        XCTAssertEqual(root.starts, 1)
        XCTAssertEqual(child.starts, 1)

        root.destroy()
        root.destroy()

        XCTAssertEqual(root.destroys, 1)
        XCTAssertEqual(child.destroys, 0, "Destroy should not cascade automatically")
    }

    func testScriptStartAndDestroyFollowObjectLifecycle() {
        final class HookedScript: Script {
            var starts = 0
            var destroys = 0
            override func onStart() { starts += 1 }
            override func onDestroy() { destroys += 1 }
        }

        let root = GameObject(name: "root")
        let script = HookedScript()
        root.addComponent(script)

        root.update(deltaTime: 1)
        root.update(deltaTime: 1)

        XCTAssertEqual(script.starts, 1)

        root.destroy()
        root.destroy()

        XCTAssertEqual(script.destroys, 1)
    }

    func testRuntimeAddedScriptStartsImmediatelyWhenObjectAlreadyStarted() {
        final class HookedScript: Script {
            var starts = 0
            override func onStart() { starts += 1 }
        }

        let root = GameObject(name: "root")
        root.update(deltaTime: 1)

        let script = HookedScript()
        root.addComponent(script)

        XCTAssertEqual(script.starts, 1)
    }
}
