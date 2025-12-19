import Foundation

/// Marker protocol for events flowing through the engine.
///
/// Events are plain values posted to an `EventBus` and observed through
/// `AsyncStream` subscriptions.
public protocol GameEvent {}

/// Publish/subscribe contract for engine events.
public protocol EventBus {
    /// Posts an event to current subscribers of its concrete type.
    func post(_ event: GameEvent)
    /// Subscribes to events of the given type.
    func subscribe<T: GameEvent>(_ type: T.Type) -> AsyncStream<T>
}
