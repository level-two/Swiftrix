import Foundation

/// Default scene implementation orchestrating game objects and update loops.
public final class DefaultScene: Scene {
    public private(set) var rootObjects: [GameObject] = []
    public let eventBus: EventBus
    public var inputSystem: InputSystem?

    public init(eventBus: EventBus = DefaultEventBus(), inputSystem: InputSystem? = nil) {
        self.eventBus = eventBus
        self.inputSystem = inputSystem
    }

    public func addRootObject(_ object: GameObject) {
        rootObjects.append(object)
    }

    public func removeRootObject(_ object: GameObject) {
        rootObjects.removeAll { $0.id == object.id }
    }

    public func update(deltaTime: TimeInterval) {
        inputSystem?.update()
        SceneGraphTraversal.depthFirstUpdate(objects: rootObjects, deltaTime: deltaTime)
    }

    public func fixedUpdate(fixedDeltaTime: TimeInterval) {
        // Physics integration can hook here in future stories.
        SceneGraphTraversal.depthFirstFixedUpdate(objects: rootObjects, fixedDeltaTime: fixedDeltaTime)
    }

    public func draw() {
        SceneGraphTraversal.depthFirstDraw(objects: rootObjects)
    }
}
