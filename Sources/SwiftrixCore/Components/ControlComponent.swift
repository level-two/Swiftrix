import Foundation

/// Receives logical input events after host mapping.
public protocol ControlComponent: Component {
    func handle(event: ControlEvent)
}

public extension ControlComponent {
    func handle(event: ControlEvent) {}
}
