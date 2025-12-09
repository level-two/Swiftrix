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
}
