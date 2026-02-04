import Foundation

/// Read-only view over an optional `InputSystem` with safe defaults.
public struct InputProxy {
    private let inputSystem: InputSystem?

    public init(_ inputSystem: InputSystem?) {
        self.inputSystem = inputSystem
    }

    public var touches: [Touch] {
        inputSystem?.touches() ?? []
    }

    public func axis(named name: String) -> AxisValue {
        inputSystem?.axis(named: name) ?? AxisValue(value: 0)
    }

    public func isButtonDown(_ name: String) -> Bool {
        inputSystem?.isButtonDown(name) ?? false
    }

    public func isButtonUp(_ name: String) -> Bool {
        inputSystem?.isButtonUp(name) ?? true
    }

    public func isButtonPressed(_ name: String) -> Bool {
        inputSystem?.isButtonPressed(name) ?? false
    }
}
