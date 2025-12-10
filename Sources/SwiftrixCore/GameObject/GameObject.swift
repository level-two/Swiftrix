import Foundation

/// Default concrete implementation of `GameObjectInterface` used by the engine core.
open class GameObject: GameObjectInterface {
    public let id = UUID()
    public var name: String

    public private(set) weak var parent: GameObjectInterface?
    public private(set) var children: [GameObjectInterface] = []

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

    public init(name: String, transform: Transform2D = .identity) {
        self.name = name
        self.localTransform = transform
    }

    // MARK: - Hierarchy

    public func addChild(_ child: GameObjectInterface) {
        children.append(child)
        if let defaultChild = child as? GameObject {
            defaultChild.parent = self
        }
    }

    public func removeChild(_ child: GameObjectInterface) {
        children.removeAll { $0.id == child.id }
        if let defaultChild = child as? GameObject, defaultChild.parent === self {
            defaultChild.parent = nil
        }
    }

    public func removeFromParent() {
        parent?.removeChild(self)
    }

    // MARK: - Components

    public func addComponent(_ component: Component) {
        components.append(component)
        component.gameObject = self
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
        for component in components where component.isEnabled {
            component.update(deltaTime: deltaTime)
        }
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }

    public func destroy() {
        isDestroyed = true
    }
}
