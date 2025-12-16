import XCTest
import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class SpriteKitSceneTests: XCTestCase {
    func testBindsHierarchyAndSyncsTransform() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root", transform: Transform2D(position: Vector2(x: 3, y: 4)))
        root.addComponent(ContainerView())

        let child = GameObject(name: "child")
        child.localTransform = Transform2D(position: Vector2(x: 10, y: -2), rotation: 0.25, scale: Vector2(x: 2, y: 1.5))
        child.addComponent(SpriteView(color: .red, size: CGSize(width: 8, height: 8)))
        root.addChild(child)

        harness.scene.coreScene.addRootObject(root)
        harness.scene.start()
        harness.step()

        guard let rootNode = harness.scene.node(for: root.id) else {
            return XCTFail("Expected a root node binding")
        }
        guard let childNode = harness.scene.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected a child sprite node binding")
        }

        XCTAssertIdentical(rootNode.parent, harness.scene)
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

        let root = GameObject(name: "root")
        let script = CountingScript()
        root.addComponent(script)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 1)

        harness.scene.pause()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 1, "Paused adapter should not tick the game loop")

        harness.scene.resume()
        harness.step(deltaTime: 0.016)
        XCTAssertEqual(script.updateCount, 2)
    }

    func testDestroyedObjectsAreRemovedFromScene() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        child.addComponent(ContainerView())
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step()
        XCTAssertNotNil(harness.scene.node(for: child.id))

        child.destroy()
        harness.step()

        XCTAssertNil(harness.scene.node(for: child.id))
    }

    func testDisablingObjectHidesNode() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        child.addComponent(SpriteView(color: .blue, size: CGSize(width: 4, height: 4)))
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step()
        XCTAssertFalse((harness.scene.node(for: child.id)?.isHidden) ?? true)

        child.isEnabled = false
        harness.step()
        XCTAssertTrue(harness.scene.node(for: child.id)?.isHidden ?? false)
    }

    func testDisablingParentHidesChildNodes() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        child.addComponent(SpriteView(color: .blue, size: CGSize(width: 4, height: 4)))
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step()
        XCTAssertFalse(harness.scene.node(for: child.id)?.isHidden ?? true)

        root.isEnabled = false
        harness.step()
        XCTAssertTrue(harness.scene.node(for: child.id)?.isHidden ?? false)
    }

    func testReparentMovesNode() {
        let harness = SpriteKitTestHarness()

        let rootA = GameObject(name: "rootA")
        rootA.addComponent(ContainerView())
        let rootB = GameObject(name: "rootB")
        rootB.addComponent(ContainerView())
        let child = GameObject(name: "child")
        child.addComponent(SpriteView(color: .green))

        rootA.addChild(child)
        harness.scene.coreScene.addRootObject(rootA)
        harness.scene.coreScene.addRootObject(rootB)

        harness.scene.start()
        harness.step()

        guard let initialParent = harness.scene.node(for: child.id)?.parent else {
            return XCTFail("Child should be parented initially")
        }
        XCTAssertEqual(initialParent.name, rootA.name)

        rootA.removeChild(child)
        rootB.addChild(child)
        harness.step()

        let newParent = harness.scene.node(for: child.id)?.parent
        XCTAssertEqual(newParent?.name, rootB.name)
    }

    func testPerformanceBudgetLimitsSyncPerFrame() {
        let harness = SpriteKitTestHarness(performanceBudget: PerformanceBudget(maxSyncOpsPerFrame: 1))

        let root = GameObject(name: "root")
        root.addComponent(ContainerView())
        let childA = GameObject(name: "A")
        childA.localTransform = Transform2D(position: Vector2(x: 0, y: 0))
        childA.addComponent(SpriteView(color: .red))
        let childB = GameObject(name: "B")
        childB.localTransform = Transform2D(position: Vector2(x: 0, y: 0))
        childB.addComponent(SpriteView(color: .yellow))

        root.addChild(childA)
        root.addChild(childB)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step()

        childA.localTransform.position = Vector2(x: 5, y: 0)
        childB.localTransform.position = Vector2(x: 9, y: 0)

        harness.step()
        let posA = harness.scene.node(for: childA.id)?.position
        let posB = harness.scene.node(for: childB.id)?.position
        let updatedAFirst = posA == CGPoint(x: 5, y: 0) && posB == CGPoint(x: 0, y: 0)
        let updatedBFirst = posA == CGPoint(x: 0, y: 0) && posB == CGPoint(x: 9, y: 0)
        XCTAssertTrue(updatedAFirst || updatedBFirst, "Only one child should be updated per frame under budget")

        harness.step()
        XCTAssertEqual(harness.scene.node(for: childA.id)?.position, CGPoint(x: 5, y: 0))
        XCTAssertEqual(harness.scene.node(for: childB.id)?.position, CGPoint(x: 9, y: 0))
    }

    func testSpriteViewAnchorPointUpdatesFromAnchor() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        let spriteView = SpriteView(color: .white, size: CGSize(width: 4, height: 4), anchor: Vector2(x: 0, y: 0))
        child.addComponent(spriteView)
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        harness.scene.start()
        harness.step()

        guard let node = harness.scene.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected sprite node")
        }
        XCTAssertEqual(node.anchorPoint, CGPoint(x: 0, y: 0))

        spriteView.anchor = Vector2(x: 1, y: 1)
        harness.step()

        XCTAssertEqual(node.anchorPoint, CGPoint(x: 1, y: 1))
    }

    func testSpriteViewAnimateStartsActionOnNode() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        let spriteView = SpriteView(color: .white, size: CGSize(width: 4, height: 4))
        child.addComponent(spriteView)
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        let textures = [
            SKTexture(noiseWithSmoothness: 0.2, size: CGSize(width: 2, height: 2), grayscale: true),
            SKTexture(noiseWithSmoothness: 0.8, size: CGSize(width: 2, height: 2), grayscale: false)
        ]
        spriteView.animate(with: textures, timePerFrame: 0.05)

        harness.scene.start()
        harness.step()

        guard let node = harness.scene.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected sprite node")
        }

        XCTAssertNotNil(node.action(forKey: SpriteView.animationKey))
    }

    func testSpriteViewStopAnimationRemovesAction() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        let spriteView = SpriteView(color: .white, size: CGSize(width: 4, height: 4))
        child.addComponent(spriteView)
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        let textures = [
            SKTexture(noiseWithSmoothness: 0.2, size: CGSize(width: 2, height: 2), grayscale: true),
            SKTexture(noiseWithSmoothness: 0.8, size: CGSize(width: 2, height: 2), grayscale: false)
        ]
        spriteView.animate(with: textures, timePerFrame: 0.05)

        harness.scene.start()
        harness.step()

        spriteView.stopAnimation()
        harness.step()

        guard let node = harness.scene.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected sprite node")
        }

        XCTAssertNil(node.action(forKey: SpriteView.animationKey))
    }

    func testSpriteViewAnimateByTextureNamesStartsAction() {
        let harness = SpriteKitTestHarness()

        let root = GameObject(name: "root")
        let child = GameObject(name: "child")
        let spriteView = SpriteView(color: .white, size: CGSize(width: 4, height: 4))
        child.addComponent(spriteView)
        root.addChild(child)
        harness.scene.coreScene.addRootObject(root)

        spriteView.animate(textureNames: ["frameA", "frameB"], timePerFrame: 0.05)

        harness.scene.start()
        harness.step()

        guard let node = harness.scene.node(for: child.id) as? SKSpriteNode else {
            return XCTFail("Expected sprite node")
        }

        XCTAssertNotNil(node.action(forKey: SpriteView.animationKey))
    }
}
