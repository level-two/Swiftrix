import Foundation

/// A node in the scene graph.
///
/// `GameObject` models:
/// - hierarchy (parent/children)
/// - transform composition (`localTransform` → `globalTransform`)
/// - composition via attachable `Component`s
/// - lifecycle (`onStart` and `onDestroy`)
///
/// Objects are updated depth-first by default traversal.
open class GameObject: IdentifiableObject, Named, Updatable, Destroyable {
    public let id = UUID()
    public var name: String

    public private(set) weak var parent: GameObject?
    public private(set) var children: [GameObject] = []

    public var localTransform: Transform2D
    public var globalTransform: Transform2D {
        if let parent {
            return parent.globalTransform.applying(localTransform)
        }
        return localTransform
    }

    public private(set) var components: [Component] = []
    public private(set) var isDestroyed: Bool = false
    public var isEnabled: Bool = true

    private var hasStarted: Bool = false
    private var hasNotifiedDestroy: Bool = false

    /// Creates a new game object.
    public init(name: String, transform: Transform2D = .identity) {
        self.name = name
        self.localTransform = transform
    }

    // MARK: - Hierarchy

    /// Adds `child` as a direct child, preventing cycles and duplicates.
    public func addChild(_ child: GameObject) {
        // Prevent self-parenting
        guard child !== self else { return }
        // Prevent cycles (adding an ancestor as a child)
        guard !self.isDescendant(of: child) else { return }
        // Prevent duplicate entries
        guard !children.contains(where: { $0 === child }) else { return }

        // If the child already has a different parent, detach it first
        if let currentParent = child.parent, currentParent !== self {
            currentParent.removeChild(child)
        }

        children.append(child)
        child.parent = self
    }

    /// Removes `child` from the receiver’s children list.
    public func removeChild(_ child: GameObject) {
        children.removeAll { $0.id == child.id }
        if child.parent === self {
            child.parent = nil
        }
    }

    public func removeFromParent() {
        parent?.removeChild(self)
    }

    private func isDescendant(of possibleAncestor: GameObject) -> Bool {
        if parent === possibleAncestor { return true }
        return parent?.isDescendant(of: possibleAncestor) ?? false
    }

    // MARK: - Components

    /// Attaches a component to this object and sets `component.gameObject`.
    public func addComponent(_ component: Component) {
        components.append(component)
        component.gameObject = self

        if let script = component as? Script, hasStarted, !isDestroyed {
            script.startIfNeeded()
        }
    }

    /// Detaches a component from this object and clears `component.gameObject` if it matches.
    public func removeComponent(_ component: Component) {
        components.removeAll { $0 === component }
        if component.gameObject === self {
            component.gameObject = nil
        }
    }

    /// Returns the first attached component of the requested type.
    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        components.compactMap { $0 as? T }.first
    }

    /// Returns all attached components of the requested type.
    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        components.compactMap { $0 as? T }
    }

    // MARK: - Lifecycle

    /// Updates this object and its subtree if enabled and not destroyed.
    public func update(deltaTime: TimeInterval) {
        guard !isDestroyed, isEnabled else { return }

        startIfNeeded()
        for component in components where component.isEnabled {
            component.update(deltaTime: deltaTime)
        }
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }

    /// Marks this object as destroyed and triggers destroy hooks once.
    public func destroy() {
        guard !isDestroyed else { return }
        isDestroyed = true
        notifyDestroyIfNeeded()
    }

    // MARK: - Hooks

    /// Called once, lazily, before the first update of this object (or any attached script).
    open func onStart() {}
    /// Called once when `destroy()` is invoked.
    open func onDestroy() {}

    private func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        onStart()
        components.compactMap { $0 as? Script }.forEach { $0.startIfNeeded() }
    }

    private func notifyDestroyIfNeeded() {
        guard !hasNotifiedDestroy else { return }
        hasNotifiedDestroy = true
        onDestroy()
        components.compactMap { $0 as? Script }.forEach { $0.notifyDestroyIfNeeded() }
    }
}
