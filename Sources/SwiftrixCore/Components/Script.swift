import Foundation

/// A script provides custom behavior for a game object.
public protocol Script: Component {
    func onCollision(with other: Collider)
    func onControl(_ event: ControlEvent)
}

public extension Script {
    func onCollision(with other: Collider) {}
    func onControl(_ event: ControlEvent) {}
}
