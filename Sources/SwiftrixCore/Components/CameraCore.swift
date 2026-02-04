import Foundation

package final class CameraCore {
    package var zoomScale: Double {
        didSet { zoomScale = CameraCore.sanitizeZoomScale(zoomScale) }
    }
    package var depth: Double
    package var aspectRatio: Double {
        didSet { aspectRatio = CameraCore.sanitizeAspectRatio(aspectRatio) }
    }

    package init(zoomScale: Double = 1.0, depth: Double = 0.0, aspectRatio: Double = 1.0) {
        self.zoomScale = CameraCore.sanitizeZoomScale(zoomScale)
        self.depth = depth
        self.aspectRatio = CameraCore.sanitizeAspectRatio(aspectRatio)
    }

    package static func sanitizeZoomScale(_ value: Double) -> Double {
        guard value.isFinite, value > 0 else { return 1.0 }
        return value
    }

    package static func sanitizeAspectRatio(_ value: Double) -> Double {
        guard value.isFinite, value > 0 else { return 1.0 }
        return value
    }
}

