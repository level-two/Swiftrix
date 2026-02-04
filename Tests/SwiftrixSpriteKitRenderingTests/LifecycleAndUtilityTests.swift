import XCTest
import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class LifecycleAndUtilityTests: XCTestCase {
    func testResetClearsBindingsAndAllowsRestart() {
        let harness = SpriteKitTestHarness()
        let root = GameObject(name: "root")
        root.addComponent(SpriteView(color: .red, size: CGSize(width: 8, height: 8)))
        harness.scene.addRootObject(root)

        harness.scene.start()
        harness.step()
        XCTAssertNotNil(harness.scene.node(for: root.id))

        harness.scene.reset()
        XCTAssertNil(harness.scene.node(for: root.id))
        XCTAssertEqual(harness.scene.state, .idle)

        harness.scene.start()
        harness.step()
        XCTAssertNotNil(harness.scene.node(for: root.id))
    }

    func testHitTestReturnsObjectID() {
        let harness = SpriteKitTestHarness()
        harness.scene.size = CGSize(width: 100, height: 100)

        let root = GameObject(name: "root")
        let sprite = SpriteView(color: .cyan, size: CGSize(width: 20, height: 20))
        root.addComponent(sprite)
        harness.scene.addRootObject(root)

        harness.scene.start()
        harness.step()

        let hit = harness.scene.hitTestObjectID(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(hit, root.id)
    }

    func testHitTestReturnsNilWhenNoNode() {
        let harness = SpriteKitTestHarness()
        harness.scene.size = CGSize(width: 100, height: 100)

        harness.scene.start()
        harness.step()

        let hit = harness.scene.hitTestObjectID(at: CGPoint(x: 0, y: 0))
        XCTAssertNil(hit)
    }

    func testHitTestPrefersTopmostNode() {
        let harness = SpriteKitTestHarness()
        harness.scene.size = CGSize(width: 100, height: 100)

        let back = GameObject(name: "back")
        let backSprite = SpriteView(color: .red, size: CGSize(width: 20, height: 20))
        backSprite.zPosition = 0
        back.addComponent(backSprite)

        let front = GameObject(name: "front")
        let frontSprite = SpriteView(color: .blue, size: CGSize(width: 20, height: 20))
        frontSprite.zPosition = 10
        front.addComponent(frontSprite)

        harness.scene.addRootObject(back)
        harness.scene.addRootObject(front)

        harness.scene.start()
        harness.step()

        let hit = harness.scene.hitTestObjectID(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(hit, front.id)
    }

    func testCameraFollowsObject() {
        let harness = SpriteKitTestHarness()
        harness.scene.size = CGSize(width: 200, height: 200)

        let root = GameObject(name: "root", transform: Transform2D(position: Vector2(x: 50, y: 20)))
        root.addComponent(ContainerView())
        root.addComponent(Camera())
        harness.scene.addRootObject(root)

        harness.scene.start()
        harness.step()

        let cameraPosition = harness.scene.camera?.position
        XCTAssertEqual(cameraPosition, CGPoint(x: 50, y: 20))
    }
}
