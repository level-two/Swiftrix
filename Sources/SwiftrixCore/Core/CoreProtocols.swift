import Foundation

/// Identifiable engine object.
public protocol IdentifiableObject: AnyObject {
    var id: UUID { get }
}

/// Named element used for introspection and debugging.
public protocol Named {
    var name: String { get set }
}

/// Receives per-frame updates.
public protocol Updatable {
    func update(deltaTime: TimeInterval)
}

/// Receives fixed step updates (e.g., physics).
public protocol FixedUpdatable {
    func fixedUpdate(fixedDeltaTime: TimeInterval)
}

/// Represents things that can be destroyed or removed from the scene.
public protocol Destroyable: AnyObject {
    var isDestroyed: Bool { get }
    func destroy()
}
