import Foundation

/// A script provides custom behavior for a game object.
open class Script: Component {
    // MARK: - GameObject bridges

    public var parent: GameObject? { gameObject?.parent }
    public var children: [GameObject] { gameObject?.children ?? [] }

    public var localTransform: Transform2D {
        get { gameObject?.localTransform ?? .identity }
        set { gameObject?.localTransform = newValue }
    }

    public var globalTransform: Transform2D {
        gameObject?.globalTransform ?? .identity
    }

    public var components: [Component] {
        gameObject?.components ?? []
    }

    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        gameObject?.getComponent(type)
    }

    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        gameObject?.getComponents(type) ?? []
    }

    // MARK: - Transform helpers

    public var position: Vector2 {
        get { localTransform.position }
        set {
            var transform = localTransform
            transform.position = newValue
            localTransform = transform
        }
    }

    public var rotation: Double {
        get { localTransform.rotation }
        set {
            var transform = localTransform
            transform.rotation = newValue
            localTransform = transform
        }
    }

    public var scale: Vector2 {
        get { localTransform.scale }
        set {
            var transform = localTransform
            transform.scale = newValue
            localTransform = transform
        }
    }

    public var globalPosition: Vector2 { globalTransform.position }
    public var globalRotation: Double { globalTransform.rotation }
    public var globalScale: Vector2 { globalTransform.scale }

    open func onCollision(with other: Collider) {}
    open func onControl(_ event: ControlEvent) {}
}
