import Foundation

/// A node in the scene graph that can own components and children.
/// Default implementation is provided by `DefaultGameObject`.
public protocol GameObject: IdentifiableObject, Named, Updatable, Destroyable {
    var parent: GameObject? { get }
    var children: [GameObject] { get }
    var localTransform: Transform2D { get set }
    var globalTransform: Transform2D { get }
    var components: [Component] { get }
    var isEnabled: Bool { get set }

    func addChild(_ child: GameObject)
    func removeChild(_ child: GameObject)
    func removeFromParent()

    func addComponent(_ component: Component)
    func removeComponent(_ component: Component)
    func getComponent<T: Component>(_ type: T.Type) -> T?
    func getComponents<T: Component>(_ type: T.Type) -> [T]
}
