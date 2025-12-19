import Foundation
import CoreGraphics

/// Extremely simple 2D physics world that performs AABB overlap checks.
///
/// This implementation is intentionally basic:
/// - colliders are axis-aligned rectangles (AABB)
/// - rotation is ignored for collision shape
/// - overlaps result in `CollisionEvent` posted to the `EventBus`
/// - involved objects’ `Script` components receive `onCollision(with:)`
public final class DefaultPhysicsWorld: PhysicsWorld {
    private struct Entry: Identifiable {
        let id = UUID()
        weak var collider: Collider?
    }

    private var entries: [Entry] = []

    public init() {}

    public func addCollider(_ collider: Collider) {
        entries.append(Entry(collider: collider))
    }

    public func removeCollider(_ collider: Collider) {
        entries.removeAll { $0.collider === collider }
    }

    public func step(fixedDeltaTime: TimeInterval, eventBus: EventBus) {
        // Remove released colliders
        entries = entries.filter { $0.collider != nil }

        let colliders = entries.compactMap { $0.collider }.filter { collider in
            guard let go = collider.gameObject else { return false }
            return go.isEnabled && !go.isDestroyed && collider.isEnabled
        }

        for i in 0..<colliders.count {
            for j in (i + 1)..<colliders.count {
                let a = colliders[i]
                let b = colliders[j]
                guard overlaps(a, b) else { continue }

                let event = CollisionEvent(a: a, b: b)
                eventBus.post(event)

                // Notify scripts on each collider's game object
                let aScripts = a.gameObject?.components.compactMap { $0 as? Script } ?? []
                let bScripts = b.gameObject?.components.compactMap { $0 as? Script } ?? []
                aScripts.forEach { $0.onCollision(with: b) }
                bScripts.forEach { $0.onCollision(with: a) }
            }
        }
    }

    public func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider] {
        entries.compactMap { $0.collider }.filter { collider in
            guard let go = collider.gameObject else { return false }
            guard overlaps(rect, collider: collider, object: go) else { return false }
            if let group = group { return collider.collisionGroup == group }
            return true
        }
    }

    // MARK: - Helpers

    private func overlaps(_ a: Collider, _ b: Collider) -> Bool {
        guard let goA = a.gameObject, let goB = b.gameObject else { return false }
        let rectA = colliderRect(collider: a, object: goA)
        let rectB = colliderRect(collider: b, object: goB)
        return rectA.intersects(rectB)
    }

    private func overlaps(_ rect: CGRect, collider: Collider, object: GameObject) -> Bool {
        colliderRect(collider: collider, object: object).intersects(rect)
    }

    private func colliderRect(collider: Collider, object: GameObject) -> CGRect {
        let position = object.globalTransform.position
        let center = CGPoint(x: position.x + collider.localOffset.x, y: position.y + collider.localOffset.y)
        let origin = CGPoint(
            x: center.x - CGFloat(collider.size.x * collider.anchor.x),
            y: center.y - CGFloat(collider.size.y * collider.anchor.y)
        )
        return CGRect(origin: origin, size: CGSize(width: collider.size.x, height: collider.size.y))
    }
}
