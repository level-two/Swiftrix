import Foundation
import CoreGraphics

/// Minimal physics world interface for registering colliders and stepping collisions.
public protocol PhysicsWorld: AnyObject {
    func addCollider(_ collider: Collider)
    func removeCollider(_ collider: Collider)
    func step(fixedDeltaTime: TimeInterval, eventBus: EventBus)
    func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider]
}

public struct CollisionEvent: GameEvent {
    public let a: Collider
    public let b: Collider

    public init(a: Collider, b: Collider) {
        self.a = a
        self.b = b
    }
}
