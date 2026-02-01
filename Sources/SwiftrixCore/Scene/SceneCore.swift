import Foundation

/// Package-scoped backing implementation for `Scene` adapters.
package final class SceneCore {
    package private(set) var rootObjects: [GameObject] = []
    package let eventBus: EventBus
    package var inputSystem: InputSystem?
    package let corePhysicsWorld: PhysicsWorld

    package init(
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        self.eventBus = eventBus
        self.inputSystem = inputSystem
        self.corePhysicsWorld = physicsWorld
    }

    package func addRootObject(_ object: GameObject) {
        rootObjects.append(object)
        registerColliders(in: object)
    }

    package func removeRootObject(_ object: GameObject) {
        rootObjects.removeAll { $0.id == object.id }
        unregisterColliders(in: object)
    }

    package func update(deltaTime: TimeInterval) {
        inputSystem?.update()
        if let events = inputSystem?.pendingEvents() {
            SceneGraphTraversal.dispatchControlEvents(events, to: rootObjects)
        }
        SceneGraphTraversal.depthFirstUpdate(objects: rootObjects, deltaTime: deltaTime)
    }

    package func fixedUpdate(fixedDeltaTime: TimeInterval) {
        corePhysicsWorld.step(fixedDeltaTime: fixedDeltaTime, eventBus: eventBus)
        SceneGraphTraversal.depthFirstFixedUpdate(objects: rootObjects, fixedDeltaTime: fixedDeltaTime)
    }

    package func draw() {
        SceneGraphTraversal.depthFirstDraw(objects: rootObjects)
    }

    // MARK: - Collider registration
    private func registerColliders(in object: GameObject) {
        object.components.compactMap { $0 as? Collider }.forEach { corePhysicsWorld.addCollider($0) }
        object.children.forEach { registerColliders(in: $0) }
    }

    private func unregisterColliders(in object: GameObject) {
        object.components.compactMap { $0 as? Collider }.forEach { corePhysicsWorld.removeCollider($0) }
        object.children.forEach { unregisterColliders(in: $0) }
    }
}
