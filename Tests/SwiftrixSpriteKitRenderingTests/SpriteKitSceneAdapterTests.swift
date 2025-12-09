import XCTest
import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class SpriteKitSceneAdapterTests: XCTestCase {
    func testBindsHierarchyAndSyncsTransform() {
        let harness = SpriteKitTestHarness()

        let root = DefaultGameObject(name: "root", transform: Transform2D(position: Vector2(x: 3, y: 4)))
        root.addComponent(ContainerView())

        let child = DefaultGameObject(name: "child")
        child.localTransform = Transform2D(position: Vector2(x: 10, y: -2), rotation: 0.25, scale: Vector2(x: 2, y: 1.5))
        child.addComponent(SpriteView(color: .red, size: CGSize(width: 8, height: 8)))
        root.addChild(child)

        harness.scene.addRootObject(root)
        harness.adapter.start()
        harness.step()

        guard let rootNode = harness.adapter.node(for: root.id) else {
            return XCTFail("Expected a root node binding")
        }
        guard let childNode = harness.adapter.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected a child sprite node binding")
        }

        XCTAssertIdentical(rootNode.parent, harness.adapter.session.skScene)
        XCTAssertIdentical(childNode.parent, rootNode)
        XCTAssertEqual(rootNode.position, CGPoint(x: 3, y: 4))
        XCTAssertEqual(childNode.position, CGPoint(x: 10, y: -2))
        XCTAssertEqual(childNode.zRotation, CGFloat(0.25), accuracy: 0.0001)
        XCTAssertEqual(Double(childNode.xScale), 2, accuracy: 0.0001)
        XCTAssertEqual(Double(childNode.yScale), 1.5, accuracy: 0.0001)

        child.localTransform.position = Vector2(x: 1, y: 2)
        harness.step(deltaTime: 0.02)

        XCTAssertEqual(childNode.position, CGPoint(x: 1, y: 2))
    }

    func testPauseAndResumeControlGameLoop() {
        let harness = SpriteKitTestHarness()

        let root = DefaultGameObject(name: "root")
        let script = CountingScript()
        root.addComponent(script)
        harness.scene.addRootObject(root)

        harness.adapter.start()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 1)

        harness.adapter.pause()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 1, "Paused adapter should not tick the game loop")

        harness.adapter.resume()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 2)
    }

    func testDestroyedObjectsAreRemovedFromScene() {
        let harness = SpriteKitTestHarness()

        let root = DefaultGameObject(name: "root")
        let child = DefaultGameObject(name: "child")
        child.addComponent(ContainerView())
        root.addChild(child)
        harness.scene.addRootObject(root)

        harness.adapter.start()
        harness.step()
        XCTAssertNotNil(harness.adapter.node(for: child.id))

        child.destroy()
        harness.step()

        XCTAssertNil(harness.adapter.node(for: child.id))
    }

    func testDisablingObjectHidesNode() {
        let harness = SpriteKitTestHarness()

        let root = DefaultGameObject(name: "root")
        let child = DefaultGameObject(name: "child")
        child.addComponent(SpriteView(color: .blue, size: CGSize(width: 4, height: 4)))
        root.addChild(child)
        harness.scene.addRootObject(root)

        harness.adapter.start()
        harness.step()
        XCTAssertFalse((harness.adapter.node(for: child.id)?.isHidden) ?? true)

        child.isEnabled = false
        harness.step()
        XCTAssertTrue(harness.adapter.node(for: child.id)?.isHidden ?? false)
    }

    func testReparentMovesNode() {
        let harness = SpriteKitTestHarness()

        let rootA = DefaultGameObject(name: "rootA")
        rootA.addComponent(ContainerView())
        let rootB = DefaultGameObject(name: "rootB")
        rootB.addComponent(ContainerView())
        let child = DefaultGameObject(name: "child")
        child.addComponent(SpriteView(color: .green))

        rootA.addChild(child)
        harness.scene.addRootObject(rootA)
        harness.scene.addRootObject(rootB)

        harness.adapter.start()
        harness.step()

        guard let initialParent = harness.adapter.node(for: child.id)?.parent else {
            return XCTFail("Child should be parented initially")
        }
        XCTAssertEqual(initialParent.name, rootA.name)

        rootA.removeChild(child)
        rootB.addChild(child)
        harness.step()

        let newParent = harness.adapter.node(for: child.id)?.parent
        XCTAssertEqual(newParent?.name, rootB.name)
    }

    func testPerformanceBudgetLimitsSyncPerFrame() {
        let harness = SpriteKitTestHarness(performanceBudget: PerformanceBudget(maxSyncOpsPerFrame: 1))

        let root = DefaultGameObject(name: "root")
        root.addComponent(ContainerView())
        let childA = DefaultGameObject(name: "A")
        childA.localTransform = Transform2D(position: Vector2(x: 0, y: 0))
        childA.addComponent(SpriteView(color: .red))
        let childB = DefaultGameObject(name: "B")
        childB.localTransform = Transform2D(position: Vector2(x: 0, y: 0))
        childB.addComponent(SpriteView(color: .yellow))

        root.addChild(childA)
        root.addChild(childB)
        harness.scene.addRootObject(root)

        harness.adapter.start()
        harness.step()

        childA.localTransform.position = Vector2(x: 5, y: 0)
        childB.localTransform.position = Vector2(x: 9, y: 0)

        harness.step()
        let posA = harness.adapter.node(for: childA.id)?.position
        let posB = harness.adapter.node(for: childB.id)?.position
        let updatedAFirst = posA == CGPoint(x: 5, y: 0) && posB == CGPoint(x: 0, y: 0)
        let updatedBFirst = posA == CGPoint(x: 0, y: 0) && posB == CGPoint(x: 9, y: 0)
        XCTAssertTrue(updatedAFirst || updatedBFirst, "Only one child should be updated per frame under budget")

        harness.step()
        XCTAssertEqual(harness.adapter.node(for: childA.id)?.position, CGPoint(x: 5, y: 0))
        XCTAssertEqual(harness.adapter.node(for: childB.id)?.position, CGPoint(x: 9, y: 0))
    }
}
