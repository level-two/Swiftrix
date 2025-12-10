import Foundation

/// A script provides custom behavior for a game object.
open class Script: Component {
    open func onCollision(with other: Collider) {}
    open func onControl(_ event: ControlEvent) {}
}
