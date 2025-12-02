import Foundation

/// Groups used for collision filtering.
public enum CollisionGroup: Hashable {
    case player
    case enemy
    case environment
    case custom(Int)
}

/// Collision component placeholder; default physics is minimal in MVP.
public protocol Collider: Component {
    var localOffset: Vector2 { get set }
    var collisionGroup: CollisionGroup { get set }
    var isTrigger: Bool { get set }
}
