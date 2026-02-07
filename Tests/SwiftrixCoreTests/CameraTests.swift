import XCTest
@testable import SwiftrixCore

final class CameraTests: XCTestCase {
    func testCameraDefaults() {
        let camera = Camera()
        XCTAssertEqual(camera.zoomScale, 1.0)
        XCTAssertEqual(camera.depth, 0.0)
        XCTAssertEqual(camera.aspectRatio, 1.0)
        XCTAssertEqual(camera.viewportSize, .zero)
        XCTAssertTrue(camera.isEnabled)
    }

    func testZoomScaleIsSanitized() {
        let camera = Camera(zoomScale: -3.0)
        XCTAssertEqual(camera.zoomScale, 1.0)

        camera.zoomScale = 0
        XCTAssertEqual(camera.zoomScale, 1.0)

        camera.zoomScale = .infinity
        XCTAssertEqual(camera.zoomScale, 1.0)

        camera.zoomScale = .nan
        XCTAssertEqual(camera.zoomScale, 1.0)
    }

    func testAspectRatioUpdateIsSanitized() {
        let camera = Camera()
        camera.updateAspectRatio(2.0)
        XCTAssertEqual(camera.aspectRatio, 2.0)

        camera.updateAspectRatio(0)
        XCTAssertEqual(camera.aspectRatio, 1.0)

        camera.updateAspectRatio(.nan)
        XCTAssertEqual(camera.aspectRatio, 1.0)
    }

    func testViewportSizeUpdateIsSanitized() {
        let camera = Camera()
        camera.updateViewportSize(Vector2(x: 200, y: 100))
        XCTAssertEqual(camera.viewportSize, Vector2(x: 200, y: 100))

        camera.updateViewportSize(Vector2(x: -1, y: 100))
        XCTAssertEqual(camera.viewportSize, Vector2(x: 0, y: 100))

        camera.updateViewportSize(Vector2(x: .nan, y: .infinity))
        XCTAssertEqual(camera.viewportSize, .zero)
    }
}
