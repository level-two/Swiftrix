import Foundation
import CoreGraphics

/// Minimal physics world interface for registering colliders and stepping collisions.
///
/// SwiftrixCore provides a simple default implementation (`DefaultPhysicsWorld`),
/// but hosts can swap in custom physics systems by conforming to this protocol.
public protocol PhysicsWorld: AnyObject {
    /// Registers a collider for participation in simulation and queries.
    func addCollider(_ collider: Collider)
    /// Unregisters a collider.
    func removeCollider(_ collider: Collider)
    /// Advances the physics simulation by a fixed delta time and posts any events to the provided bus.
    func step(fixedDeltaTime: TimeInterval, eventBus: EventBus)
    /// Returns colliders whose shapes overlap the provided rect, optionally filtered by group.
    func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider]
}

/// Collision event emitted by the default physics system.
public struct CollisionEvent: GameEvent {
    public let a: Collider
    public let b: Collider

    public init(a: Collider, b: Collider) {
        self.a = a
        self.b = b
    }
}
