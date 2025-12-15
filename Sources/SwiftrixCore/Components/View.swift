import Foundation

/// Visual representation of a game object. Host apps provide rendering.
open class View: Component {
    /// Normalized anchor within the view's bounds. (0,0) is top-left, (0.5,0.5) is center, (1,1) is bottom-right.
    public var anchor: Vector2

    public init(anchor: Vector2 = Vector2(x: 0.5, y: 0.5), isEnabled: Bool = true) {
        self.anchor = anchor
        super.init(isEnabled: isEnabled)
    }

    open func draw() {}
}
