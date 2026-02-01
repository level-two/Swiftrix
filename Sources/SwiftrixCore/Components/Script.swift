import Foundation

/// A component intended for gameplay logic.
///
/// Override `update(deltaTime:)` for per-frame behavior, or use:
/// - `onStart()` / `onDestroy()` for lifecycle
/// - `onControl(_:)` for input events (dispatched by the scene)
/// - `onCollision(with:)` for physics callbacks (from the default physics world)
/// - `fixedUpdate(fixedDeltaTime:)` for fixed-step simulation behavior
///
/// If you need more control over update ordering, override:
/// - `preUpdate(deltaTime:)` to run before any components update for this object
/// - `postUpdate(deltaTime:)` to run after all components update for this object
///
/// Scripts also expose convenience “bridges” to their owning `GameObject` for:
/// hierarchy operations, transform access, and component lookup.
open class Script: Component, FixedUpdatable {
    /// Runs before any component updates for the owning `GameObject` during this frame.
    open func preUpdate(deltaTime: TimeInterval) {}

    /// Runs during fixed-step updates for the owning `GameObject`.
    open func fixedUpdate(fixedDeltaTime: TimeInterval) {}

    open func onCollision(with other: Collider) {}
    open func onControl(_ event: ControlEvent) {}
    open func onStart() {}
    open func onDestroy() {}

    /// Runs after all component updates for the owning `GameObject` during this frame.
    open func postUpdate(deltaTime: TimeInterval) {}

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

    // MARK: - Lifecycle
    private var hasStarted: Bool = false
    private var hasNotifiedDestroy: Bool = false

    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        onStart()
    }

    func notifyDestroyIfNeeded() {
        guard !hasNotifiedDestroy else { return }
        hasNotifiedDestroy = true
        onDestroy()
    }
}
