import Foundation

/// Represents a 2D transform with position, rotation (radians), and scale.
///
/// Rotation is expressed in radians to match SpriteKit’s conventions.
public struct Transform2D: Equatable, Codable {
    public var position: Vector2
    public var rotation: Double
    public var scale: Vector2

    public init(position: Vector2 = .zero, rotation: Double = 0, scale: Vector2 = Vector2(x: 1, y: 1)) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    public static let identity = Transform2D()

    /// Applies another transform in parent-first order.
    public func applying(_ child: Transform2D) -> Transform2D {
        let scaledChild = Vector2(x: child.position.x * scale.x, y: child.position.y * scale.y)
        let combinedPosition = position + scaledChild
        let combinedRotation = rotation + child.rotation
        let combinedScale = Vector2(x: scale.x * child.scale.x, y: scale.y * child.scale.y)
        return Transform2D(position: combinedPosition, rotation: combinedRotation, scale: combinedScale)
    }
}
