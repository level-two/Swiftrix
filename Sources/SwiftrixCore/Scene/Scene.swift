import Foundation
import CoreGraphics

/// Scene represents the world, orchestrating game objects and update loops.
open class Scene: Updatable {
    public private(set) var rootObjects: [GameObject] = []
    public let eventBus: EventBus
    public var inputSystem: InputSystem?
    public let physicsWorld: PhysicsWorld

    public init(
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        self.eventBus = eventBus
        self.inputSystem = inputSystem
        self.physicsWorld = physicsWorld
    }

    open func addRootObject(_ object: GameObject) {
        rootObjects.append(object)
        registerColliders(in: object)
    }

    open func removeRootObject(_ object: GameObject) {
        rootObjects.removeAll { $0.id == object.id }
        unregisterColliders(in: object)
    }

    open func update(deltaTime: TimeInterval) {
        inputSystem?.update()
        if let events = inputSystem?.pendingEvents() {
            SceneGraphTraversal.dispatchControlEvents(events, to: rootObjects)
        }
        SceneGraphTraversal.depthFirstUpdate(objects: rootObjects, deltaTime: deltaTime)
    }

    open func fixedUpdate(fixedDeltaTime: TimeInterval) {
        physicsWorld.step(fixedDeltaTime: fixedDeltaTime, eventBus: eventBus)
        SceneGraphTraversal.depthFirstFixedUpdate(objects: rootObjects, fixedDeltaTime: fixedDeltaTime)
    }

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
