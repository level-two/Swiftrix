import XCTest
import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class CameraTransformTests: XCTestCase {
    func testCameraAppliesTransformAndZoom() {
        let harness = SpriteKitTestHarness()
        let cameraObject = GameObject(
            name: "camera",
            transform: Transform2D(
                position: Vector2(x: 20, y: -5),
                rotation: 0.5,
                scale: Vector2(x: 1, y: 1)
            )
        )
        let camera = Camera(zoomScale: 2.0)
        cameraObject.addComponent(camera)
        harness.scene.addRootObject(cameraObject)

        harness.scene.start()
        harness.step()

        guard let node = harness.scene.camera else {
            return XCTFail("Expected camera node")
        }
        XCTAssertEqual(node.position, CGPoint(x: 20, y: -5))
        XCTAssertEqual(node.zRotation, CGFloat(0.5), accuracy: 0.0001)
        XCTAssertEqual(node.xScale, 2.0, accuracy: 0.0001)
        XCTAssertEqual(node.yScale, 2.0, accuracy: 0.0001)
    }

    func testCameraUpdatesWhenOwnerMoves() {
        let harness = SpriteKitTestHarness()
        let cameraObject = GameObject(name: "camera", transform: Transform2D(position: Vector2(x: 0, y: 0)))
        cameraObject.addComponent(Camera())
        harness.scene.addRootObject(cameraObject)

        harness.scene.start()
        harness.step()

        cameraObject.localTransform.position = Vector2(x: 12, y: 8)
        cameraObject.localTransform.rotation = 1.0
        harness.step()

        guard let node = harness.scene.camera else {
            return XCTFail("Expected camera node")
        }
        XCTAssertEqual(node.position, CGPoint(x: 12, y: 8))
        XCTAssertEqual(node.zRotation, CGFloat(1.0), accuracy: 0.0001)
    }
}

