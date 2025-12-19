import Foundation

/// Logical input events delivered to control components and scripts.
public enum ControlEvent: Equatable {
    /// Button transitions to down.
    case buttonDown(String)
    /// Button transitions to up.
    case buttonUp(String)
    /// Axis value changes.
    case axisChanged(name: String, value: AxisValue)
}

/// Represents a normalized axis value (typically in `[-1, 1]`).
public struct AxisValue: Equatable {
    public var value: Double

    public init(value: Double) {
        self.value = value
    }
}
