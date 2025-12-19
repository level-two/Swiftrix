import Foundation

/// Groups used for collision filtering.
public enum CollisionGroup: Hashable {
    case player
    case enemy
    case environment
    case custom(Int)
}

/// Collision component for the physics world.
///
/// The default physics world treats `size` as an axis-aligned box (AABB) in the
/// Core coordinate system. `anchor` and `localOffset` control how the box is
/// positioned relative to the owning object’s transform.
open class Collider: Component {
    public var localOffset: Vector2
    public var anchor: Vector2
    public var collisionGroup: CollisionGroup
    public var isTrigger: Bool
    public var size: Vector2

    public init(
        size: Vector2,
        anchor: Vector2 = Vector2(x: 0.5, y: 0.5),
        localOffset: Vector2 = .zero,
        collisionGroup: CollisionGroup = .environment,
        isTrigger: Bool = false,
        isEnabled: Bool = true
    ) {
        self.size = size
        self.anchor = anchor
        self.localOffset = localOffset
        self.collisionGroup = collisionGroup
        self.isTrigger = isTrigger
        super.init(isEnabled: isEnabled)
    }
}

/// Simple AABB collider used by the default physics world.
open class BoxCollider: Collider {}
