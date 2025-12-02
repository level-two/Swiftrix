import Foundation

/// Simple AsyncStream-backed event bus suitable for tests and tools.
public final class DefaultEventBus: EventBus {
    private struct AnyContinuation {
        let typeId: ObjectIdentifier
        let yield: (GameEvent) -> Void
    }

    private var continuations: [AnyContinuation] = []
    private let queue = DispatchQueue(label: "swiftrix.eventbus", attributes: .concurrent)

    public init() {}

    public func post(_ event: GameEvent) {
        let id = ObjectIdentifier(type(of: event))
        queue.sync {
            for continuation in continuations where continuation.typeId == id {
                continuation.yield(event)
            }
        }
    }

    public func subscribe<T: GameEvent>(_ type: T.Type) -> AsyncStream<T> {
        AsyncStream { continuation in
            let wrapper = AnyContinuation(
                typeId: ObjectIdentifier(T.self),
                yield: { event in
                    guard let typed = event as? T else { return }
                    continuation.yield(typed)
                }
            )

            queue.async(flags: .barrier) {
                self.continuations.append(wrapper)
            }

            continuation.onTermination = { [weak self] _ in
                self?.queue.async(flags: .barrier) {
                    self?.continuations.removeAll { $0.typeId == wrapper.typeId }
                }
            }
        }
    }
}
