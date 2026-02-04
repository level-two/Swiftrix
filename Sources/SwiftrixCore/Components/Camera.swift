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
    private let core: CameraCore

    public var zoomScale: Double {
        get { core.zoomScale }
        set { core.zoomScale = newValue }
    }

    public var depth: Double {
        get { core.depth }
        set { core.depth = newValue }
    }

    public var aspectRatio: Double { core.aspectRatio }

    public init(zoomScale: Double = 1.0, depth: Double = 0.0, isEnabled: Bool = true) {
        self.core = CameraCore(zoomScale: zoomScale, depth: depth)
        super.init(isEnabled: isEnabled)
    }

    package func updateAspectRatio(_ value: Double) {
        core.aspectRatio = value
    }
}

