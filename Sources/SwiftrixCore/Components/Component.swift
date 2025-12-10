import Foundation

/// Base class for attachable behaviors on game objects.
open class Component: Updatable {
    public weak var gameObject: GameObject?
    public var isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    open func update(deltaTime: TimeInterval) {}
}
