import Foundation
import CoreGraphics

/// A world container that owns root objects and coordinates engine systems.
///
/// `Scene` is the central object you embed into a host application:
/// - host code drives it (typically via `GameLoop`)
/// - host code supplies an `InputSystem` (or uses `DefaultInputSystem` for tests)
/// - the scene steps physics via `PhysicsWorld` and publishes events via `EventBus`
///
/// The default implementation is intentionally small and deterministic.
open class Scene: Updatable {
    public private(set) var rootObjects: [GameObject] = []
    public let eventBus: EventBus
    public var inputSystem: InputSystem?
    public let physicsWorld: PhysicsWorld

    /// Creates a scene with pluggable input/physics/event implementations.
    public init(
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        self.eventBus = eventBus
        self.inputSystem = inputSystem
        self.physicsWorld = physicsWorld
    }

    /// Adds a root object to the scene graph.
    ///
    /// Any `Collider` components found in this subtree are registered into `physicsWorld`.
    open func addRootObject(_ object: GameObject) {
        rootObjects.append(object)
        registerColliders(in: object)
    }

    /// Removes a root object from the scene graph.
    ///
    /// Any `Collider` components found in this subtree are unregistered from `physicsWorld`.
    open func removeRootObject(_ object: GameObject) {
        rootObjects.removeAll { $0.id == object.id }
        unregisterColliders(in: object)
    }

    /// Performs per-frame update:
    /// - polls input (`inputSystem.update()`)
    /// - dispatches control events to `ControlComponent`s
    /// - traverses the scene graph and calls `Component.update(deltaTime:)`
    open func update(deltaTime: TimeInterval) {
        inputSystem?.update()
        if let events = inputSystem?.pendingEvents() {
            SceneGraphTraversal.dispatchControlEvents(events, to: rootObjects)
        }
        SceneGraphTraversal.depthFirstUpdate(objects: rootObjects, deltaTime: deltaTime)
    }

    /// Performs a fixed step update:
    /// - advances physics (`physicsWorld.step`)
    /// - traverses the scene graph and calls `fixedUpdate` hooks
    open func fixedUpdate(fixedDeltaTime: TimeInterval) {
        physicsWorld.step(fixedDeltaTime: fixedDeltaTime, eventBus: eventBus)
        SceneGraphTraversal.depthFirstFixedUpdate(objects: rootObjects, fixedDeltaTime: fixedDeltaTime)
    }

    /// Draw traversal hook for hosts (Core does not render).
    open func draw() {
        SceneGraphTraversal.depthFirstDraw(objects: rootObjects)
    }

    // MARK: - Collider registration
    private func registerColliders(in object: GameObject) {
        object.components.compactMap { $0 as? Collider }.forEach { physicsWorld.addCollider($0) }
        object.children.forEach { registerColliders(in: $0) }
    }

    private func unregisterColliders(in object: GameObject) {
        object.components.compactMap { $0 as? Collider }.forEach { physicsWorld.removeCollider($0) }
        object.children.forEach { unregisterColliders(in: $0) }
    }
}
