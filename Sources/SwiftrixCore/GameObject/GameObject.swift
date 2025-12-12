import Foundation

/// Core game object type used by the engine.
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

    public init(name: String, transform: Transform2D = .identity) {
        self.name = name
        self.localTransform = transform
    }

    // MARK: - Hierarchy

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

    public func addComponent(_ component: Component) {
        components.append(component)
        component.gameObject = self

        if let script = component as? Script, hasStarted, !isDestroyed {
            script.startIfNeeded()
        }
    }

    public func removeComponent(_ component: Component) {
        components.removeAll { $0 === component }
        if component.gameObject === self {
            component.gameObject = nil
        }
    }

    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        components.compactMap { $0 as? T }.first
    }

    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        components.compactMap { $0 as? T }
    }

    // MARK: - Lifecycle

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

    public func destroy() {
        guard !isDestroyed else { return }
        isDestroyed = true
        notifyDestroyIfNeeded()
    }

    // MARK: - Hooks

    open func onStart() {}
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
