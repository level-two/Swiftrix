import Foundation

/// A script provides custom behavior for a game object.
open class Script: Component {
    open func onCollision(with other: Collider) {}
    open func onControl(_ event: ControlEvent) {}

    // MARK: - GameObject bridges
    public var parent: GameObject? { gameObject.parent }
    public var children: [GameObject] { gameObject.children }

    public func addChild(_ child: GameObject) {
        gameObject.addChild(child)
    }

    public func removeChild(_ child: GameObject) {
        gameObject.removeChild(child)
    }

    public func removeFromParent() {
        gameObject.removeFromParent()
    }

    // MARK: - Components
    public var components: [Component] {
        gameObject.components
    }

    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        gameObject.getComponent(type)
    }

    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        gameObject.getComponents(type)
    }

    public func addComponent(_ component: Component) {
        gameObject.addComponent(component)
    }

    public func removeComponent(_ component: Component) {
        gameObject.removeComponent(component)
    }

    // MARK: - Transform helpers

    public var position: Vector2 {
        get { gameObject.position }
        set { gameObject.position = newValue }
    }

    public var rotation: Double {
        get { gameObject.rotation }
        set { gameObject.rotation = newValue }
    }

    public var scale: Vector2 {
        get { gameObject.scale }
        set { gameObject.scale = newValue }
    }

    public var globalPosition: Vector2 { gameObject.position }
    public var globalRotation: Double { gameObject.rotation }
    public var globalScale: Vector2 { gameObject.scale }

    public var localTransform: Transform2D {
        get { gameObject.localTransform }
        set { gameObject.localTransform = newValue }
    }

    public var globalTransform: Transform2D { gameObject.globalTransform }
}
