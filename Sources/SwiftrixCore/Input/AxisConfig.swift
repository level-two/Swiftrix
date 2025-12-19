import Foundation

/// Configuration describing how a logical axis is constructed from input keys.
public struct AxisConfig: Equatable {
    public let name: String
    public let positiveKeys: [InputKey]
    public let negativeKeys: [InputKey]
    public let sensitivity: Double

    public init(name: String, positiveKeys: [InputKey], negativeKeys: [InputKey], sensitivity: Double = 1.0) {
        self.name = name
        self.positiveKeys = positiveKeys
        self.negativeKeys = negativeKeys
        self.sensitivity = sensitivity
    }
}

/// Represents logical keys independent of device.
public enum InputKey: Equatable, Hashable {
    case leftArrow
    case rightArrow
    case upArrow
    case downArrow
    case space
    case custom(String)
}
