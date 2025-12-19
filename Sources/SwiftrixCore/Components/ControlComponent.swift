import Foundation

/// Receives logical input events after host mapping.
///
/// `Scene` dispatches `ControlEvent`s to any `ControlComponent`s found in the
/// scene graph.
open class ControlComponent: Component {
    /// Override to respond to control events.
    open func handle(event: ControlEvent) {}
}
