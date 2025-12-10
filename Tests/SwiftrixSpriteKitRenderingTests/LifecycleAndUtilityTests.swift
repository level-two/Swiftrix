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

        harness.adapter.start()
        harness.step()
        XCTAssertNotNil(harness.adapter.node(for: root.id))

        harness.adapter.reset()
        XCTAssertNil(harness.adapter.node(for: root.id))
        XCTAssertEqual(harness.adapter.session.state, .idle)

        harness.adapter.start()
        harness.step()
        XCTAssertNotNil(harness.adapter.node(for: root.id))
    }

    func testHitTestReturnsObjectID() {
        let harness = SpriteKitTestHarness()
        harness.adapter.session.skScene.size = CGSize(width: 100, height: 100)

        let root = GameObject(name: "root")
        let sprite = SpriteView(color: .cyan, size: CGSize(width: 20, height: 20))
        root.addComponent(sprite)
        harness.scene.addRootObject(root)

        harness.adapter.start()
        harness.step()

        let hit = harness.adapter.hitTestObjectID(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(hit, root.id)
    }

    func testCameraFollowsObject() {
        let harness = SpriteKitTestHarness()
        harness.adapter.session.skScene.size = CGSize(width: 200, height: 200)

        let root = GameObject(name: "root", transform: Transform2D(position: Vector2(x: 50, y: 20)))
        root.addComponent(ContainerView())
        harness.scene.addRootObject(root)

        harness.adapter.configureCamera(CameraConfig(mode: .followObject(root.id, offset: CGPoint(x: 10, y: 0))))
        harness.adapter.start()
        harness.step()

        let cameraPosition = harness.adapter.session.skScene.camera?.position
        XCTAssertEqual(cameraPosition, CGPoint(x: 60, y: 20))
    }
}
