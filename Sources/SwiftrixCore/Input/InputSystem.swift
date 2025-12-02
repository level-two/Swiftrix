import Foundation

/// Abstraction for logical input state; host implements physical input polling.
public protocol InputSystem {
    func update()
    func axis(named name: String) -> AxisValue
    func isButtonDown(_ name: String) -> Bool
    func isButtonUp(_ name: String) -> Bool
    func isButtonPressed(_ name: String) -> Bool
    func eventsStream() -> AsyncStream<ControlEvent>
}

/// Simple in-memory input system suitable for tests.
public final class DefaultInputSystem: InputSystem {
    private struct EventContinuation: Identifiable {
        let id = UUID()
        let continuation: AsyncStream<ControlEvent>.Continuation
    }

    private var axisValues: [String: AxisValue] = [:]
    private var buttonsDown: Set<String> = []
    private var buttonsPressed: Set<String> = []
    private var continuations: [EventContinuation] = []

    public init() {}

    public func update() {
        buttonsPressed.removeAll()
    }

    public func axis(named name: String) -> AxisValue {
        axisValues[name, default: AxisValue(value: 0)]
    }

    public func isButtonDown(_ name: String) -> Bool {
        buttonsDown.contains(name)
    }

    public func isButtonUp(_ name: String) -> Bool {
        !buttonsDown.contains(name)
    }

    public func isButtonPressed(_ name: String) -> Bool {
        buttonsPressed.contains(name)
    }

    public func eventsStream() -> AsyncStream<ControlEvent> {
        AsyncStream { continuation in
            let wrapper = EventContinuation(continuation: continuation)
            continuations.append(wrapper)
            continuation.onTermination = { [weak self] _ in
                self?.continuations.removeAll { $0.id == wrapper.id }
            }
        }
    }

    // MARK: - Test helpers
    public func send(event: ControlEvent) {
        switch event {
        case .axisChanged(let name, let value):
            axisValues[name] = value
        case .buttonDown(let name):
            buttonsDown.insert(name)
            buttonsPressed.insert(name)
        case .buttonUp(let name):
            buttonsDown.remove(name)
        }
        continuations.forEach { $0.continuation.yield(event) }
    }
}
