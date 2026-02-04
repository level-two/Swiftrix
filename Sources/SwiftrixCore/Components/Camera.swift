import Foundation

public protocol CameraComponent: AnyObject {
    var isEnabled: Bool { get set }
    var zoomScale: Double { get set }
    var depth: Double { get set }
    var aspectRatio: Double { get }
}

package protocol CameraAspectRatioUpdatable: CameraComponent {
    func updateAspectRatio(_ value: Double)
}

/// Default camera component. Attach to a `GameObject` to mark it as a render camera.
public final class Camera: Component, CameraComponent, CameraAspectRatioUpdatable {
    public var zoomScale: Double {
        get { storedZoomScale }
        set { storedZoomScale = Camera.sanitizeZoomScale(newValue) }
    }
    public var depth: Double
    private var storedZoomScale: Double
    private var storedAspectRatio: Double

    public var aspectRatio: Double { storedAspectRatio }

    public init(zoomScale: Double = 1.0, depth: Double = 0.0, isEnabled: Bool = true) {
        self.storedZoomScale = Camera.sanitizeZoomScale(zoomScale)
        self.depth = depth
        self.storedAspectRatio = Camera.sanitizeAspectRatio(1.0)
        super.init(isEnabled: isEnabled)
    }

    package func updateAspectRatio(_ value: Double) {
        storedAspectRatio = Camera.sanitizeAspectRatio(value)
    }

    private static func sanitizeZoomScale(_ value: Double) -> Double {
        guard value.isFinite, value > 0 else { return 1.0 }
        return value
    }

    private static func sanitizeAspectRatio(_ value: Double) -> Double {
        guard value.isFinite, value > 0 else { return 1.0 }
        return value
    }
}
