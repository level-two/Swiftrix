import Foundation
import CoreGraphics

/// Default scene implementation orchestrating game objects and update loops.
public final class DefaultScene: Scene {
    public private(set) var rootObjects: [GameObjectInterface] = []
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

    public func addRootObject(_ object: GameObjectInterface) {
        rootObjects.append(object)
        registerColliders(in: object)
    }

    public func removeRootObject(_ object: GameObjectInterface) {
        rootObjects.removeAll { $0.id == object.id }
        unregisterColliders(in: object)
    }

    public func update(deltaTime: TimeInterval) {
        inputSystem?.update()
        if let events = inputSystem?.pendingEvents() {
            SceneGraphTraversal.dispatchControlEvents(events, to: rootObjects)
        }
        SceneGraphTraversal.depthFirstUpdate(objects: rootObjects, deltaTime: deltaTime)
    }

    public func fixedUpdate(fixedDeltaTime: TimeInterval) {
        physicsWorld.step(fixedDeltaTime: fixedDeltaTime, eventBus: eventBus)
        SceneGraphTraversal.depthFirstFixedUpdate(objects: rootObjects, fixedDeltaTime: fixedDeltaTime)
    }

    public func draw() {
        SceneGraphTraversal.depthFirstDraw(objects: rootObjects)
    }

    // MARK: - Collider registration
    private func registerColliders(in object: GameObjectInterface) {
        object.components.compactMap { $0 as? Collider }.forEach { physicsWorld.addCollider($0) }
        object.children.forEach { registerColliders(in: $0) }
    }

    private func unregisterColliders(in object: GameObjectInterface) {
        object.components.compactMap { $0 as? Collider }.forEach { physicsWorld.removeCollider($0) }
        object.children.forEach { unregisterColliders(in: $0) }
    }
}
