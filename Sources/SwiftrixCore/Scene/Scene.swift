import Foundation

public protocol Scene: AnyObject, Updatable {
    var rootObjects: [GameObjectInterface] { get }
    var eventBus: EventBus { get }
    var inputSystem: InputSystem? { get set }
    var physicsWorld: PhysicsWorld { get }

    func addRootObject(_ object: GameObjectInterface)
    func removeRootObject(_ object: GameObjectInterface)
    func fixedUpdate(fixedDeltaTime: TimeInterval)
    func draw()
}
