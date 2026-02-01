/// A world container that owns root objects and coordinates engine systems.
///
/// `Scene` is the central object you embed into a host application:
/// - host code drives it (typically via `GameLoop`)
/// - host code supplies an `InputSystem` (or uses `DefaultInputSystem` for tests)
/// - the scene steps physics via `PhysicsWorld` and publishes events via `EventBus`
public protocol Scene: AnyObject, Updatable, FixedUpdatable {
    var rootObjects: [GameObject] { get }
    var eventBus: EventBus { get }
    var inputSystem: InputSystem? { get }
    var corePhysicsWorld: PhysicsWorld { get }

    func addRootObject(_ object: GameObject)
    func removeRootObject(_ object: GameObject)
    func draw()
}
