import Foundation

/// Logical input events delivered to control components and scripts.
public enum ControlEvent: Equatable {
    case buttonDown(String)
    case buttonUp(String)
    case axisChanged(name: String, value: AxisValue)
}

/// Represents a normalized axis value.
public struct AxisValue: Equatable {
    public var value: Double

    public init(value: Double) {
        self.value = value
    }
}
