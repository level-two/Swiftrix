import XCTest
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class CameraSelectionTests: XCTestCase {
    func testHighestDepthCameraWins() {
        let harness = SpriteKitTestHarness()

        let near = GameObject(name: "near", transform: Transform2D(position: Vector2(x: 10, y: 0)))
        let nearCamera = Camera(depth: 0)
        near.addComponent(nearCamera)

        let far = GameObject(name: "far", transform: Transform2D(position: Vector2(x: 50, y: 0)))
        let farCamera = Camera(depth: 10)
        far.addComponent(farCamera)

        harness.scene.addRootObject(near)
        harness.scene.addRootObject(far)
        harness.scene.start()
        harness.step()

        XCTAssertEqual(harness.scene.camera?.position, CGPoint(x: 50, y: 0))
    }

    func testDisabledCameraIsIgnored() {
        let harness = SpriteKitTestHarness()

        let disabled = GameObject(name: "disabled", transform: Transform2D(position: Vector2(x: 10, y: 0)))
        let disabledCamera = Camera(depth: 10, isEnabled: false)
        disabled.addComponent(disabledCamera)

        let active = GameObject(name: "active", transform: Transform2D(position: Vector2(x: 25, y: 0)))
        let activeCamera = Camera(depth: 0)
        active.addComponent(activeCamera)

        harness.scene.addRootObject(disabled)
        harness.scene.addRootObject(active)
        harness.scene.start()
        harness.step()

        XCTAssertEqual(harness.scene.camera?.position, CGPoint(x: 25, y: 0))
    }

    func testTieBreakUsesTraversalOrder() {
        let harness = SpriteKitTestHarness()

        let first = GameObject(name: "first", transform: Transform2D(position: Vector2(x: 5, y: 0)))
        first.addComponent(Camera(depth: 1))
        let second = GameObject(name: "second", transform: Transform2D(position: Vector2(x: 30, y: 0)))
        second.addComponent(Camera(depth: 1))

        harness.scene.addRootObject(first)
        harness.scene.addRootObject(second)
        harness.scene.start()
        harness.step()

        XCTAssertEqual(harness.scene.camera?.position, CGPoint(x: 5, y: 0))
    }
}

