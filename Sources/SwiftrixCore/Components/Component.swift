import Foundation

/// Base protocol for attachable behaviors on game objects.
public protocol Component: AnyObject, Updatable {
    var gameObject: GameObjectInterface? { get set }
    var isEnabled: Bool { get set }
}

public extension Component {
    func update(deltaTime: TimeInterval) {}
}
