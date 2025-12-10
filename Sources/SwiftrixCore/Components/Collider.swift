import Foundation

/// Groups used for collision filtering.
public enum CollisionGroup: Hashable {
    case player
    case enemy
    case environment
    case custom(Int)
}

/// Collision component for the physics world.
public protocol Collider: Component {
    var localOffset: Vector2 { get set }
    var collisionGroup: CollisionGroup { get set }
    var isTrigger: Bool { get set }
    var size: Vector2 { get set }
}

/// Simple AABB collider used by the default physics world.
open class BoxCollider: Collider {
    public weak var gameObject: GameObjectInterface?
    public var isEnabled: Bool = true
    public var localOffset: Vector2
    public var collisionGroup: CollisionGroup
    public var isTrigger: Bool
    public var size: Vector2

    public init(size: Vector2, localOffset: Vector2 = .zero, collisionGroup: CollisionGroup = .environment, isTrigger: Bool = false) {
        self.size = size
        self.localOffset = localOffset
        self.collisionGroup = collisionGroup
        self.isTrigger = isTrigger
    }

    open func update(deltaTime: TimeInterval) {}
}
