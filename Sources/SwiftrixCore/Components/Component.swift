import Foundation

/// Base class for attachable behaviors and data on a `GameObject`.
///
/// Components are updated by traversal (`Component.update(deltaTime:)`) when both:
/// - the owning `GameObject` is enabled and not destroyed
/// - the component itself is enabled (`isEnabled == true`)
open class Component: Updatable {
    /// Set automatically when the component is attached via `GameObject.addComponent(_:)`.
    public weak var gameObject: GameObject!
    public var isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    /// Override to implement per-frame behavior.
    open func update(deltaTime: TimeInterval) {}
}
