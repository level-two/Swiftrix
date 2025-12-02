import Foundation

public protocol Scene: AnyObject, Updatable {
    var rootObjects: [GameObject] { get }
    var eventBus: EventBus { get }
    var inputSystem: InputSystem? { get set }

    func addRootObject(_ object: GameObject)
    func removeRootObject(_ object: GameObject)
    func fixedUpdate(fixedDeltaTime: TimeInterval)
    func draw()
}
