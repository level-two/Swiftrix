import Foundation
@testable import SwiftrixCore

final class TestScene: Scene {
    private let core: SceneCore

    var rootObjects: [GameObject] { core.rootObjects }
    var eventBus: EventBus { core.eventBus }
    var inputSystem: InputSystem? {
        get { core.inputSystem }
        set { core.inputSystem = newValue }
    }
    var corePhysicsWorld: PhysicsWorld { core.corePhysicsWorld }

    init(
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        self.core = SceneCore(
            eventBus: eventBus,
            inputSystem: inputSystem,
            physicsWorld: physicsWorld
        )
    }

    func addRootObject(_ object: GameObject) {
        core.addRootObject(object)
    }

    func removeRootObject(_ object: GameObject) {
        core.removeRootObject(object)
    }

    func update(deltaTime: TimeInterval) {
        core.update(deltaTime: deltaTime)
    }

    func fixedUpdate(fixedDeltaTime: TimeInterval) {
        core.fixedUpdate(fixedDeltaTime: fixedDeltaTime)
    }

    func draw() {
        core.draw()
    }
}
