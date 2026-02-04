import Foundation

/// Describes the state of a touch in the current frame.
public enum TouchPhase: Equatable {
    case began
    case moved
    case stationary
    case ended
    case cancelled
}

/// A single touch snapshot for the current frame.
public struct Touch: Equatable {
    /// Stable identifier for the touch across frames (Unity-like `fingerId`).
    public let id: Int
    /// Touch position in host-defined touch space.
    public var position: Vector2
    /// Current touch phase for this frame.
    public var phase: TouchPhase

    public init(id: Int, position: Vector2, phase: TouchPhase) {
        self.id = id
        self.position = position
        self.phase = phase
    }
}
