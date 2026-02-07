import XCTest
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class CameraAspectRatioTests: XCTestCase {
    func testAspectRatioUpdatesFromSceneSize() {
        let harness = SpriteKitTestHarness(size: CGSize(width: 200, height: 100))
        let cameraObject = GameObject(name: "camera")
        let camera = Camera()
        cameraObject.addComponent(camera)
        harness.scene.addRootObject(cameraObject)

        harness.scene.start()
        harness.step()

        XCTAssertEqual(camera.aspectRatio, 2.0, accuracy: 0.0001)
        XCTAssertEqual(camera.viewportSize, Vector2(x: 200, y: 100))

        harness.scene.size = CGSize(width: 300, height: 200)
        harness.step()

        XCTAssertEqual(camera.aspectRatio, 1.5, accuracy: 0.0001)
        XCTAssertEqual(camera.viewportSize, Vector2(x: 300, y: 200))
    }
}
