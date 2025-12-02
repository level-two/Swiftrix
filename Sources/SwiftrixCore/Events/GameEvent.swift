import Foundation

/// Marker protocol for events flowing through the engine.
public protocol GameEvent {}

/// Event bus contract for publish/subscribe.
public protocol EventBus {
    func post(_ event: GameEvent)
    func subscribe<T: GameEvent>(_ type: T.Type) -> AsyncStream<T>
}
