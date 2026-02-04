import Foundation

/// Abstraction for logical input state; hosts implement physical input polling.
///
/// The engine core works with *logical* concepts: named axes and named buttons.
/// Platform-specific input should be mapped in the host and surfaced through
/// this protocol (or by using `DefaultInputSystem` for tests and prototypes).
public protocol InputSystem {
    /// Called once per frame before input is queried or events are dispatched.
    func update()
    /// Returns the current value of a named axis.
    func axis(named name: String) -> AxisValue
    /// Returns true while the named button is held down.
    func isButtonDown(_ name: String) -> Bool
    /// Returns true when the named button is not held down.
    func isButtonUp(_ name: String) -> Bool
    /// Returns true only on the first frame the button transitions to down.
    func isButtonPressed(_ name: String) -> Bool
    /// Returns the current frame's touch snapshot.
    func touches() -> [Touch]
    /// Streams control events as they occur.
    func eventsStream() -> AsyncStream<ControlEvent>
    /// Returns and clears pending events since the last call.
    func pendingEvents() -> [ControlEvent]
}

public extension InputSystem {
    func touches() -> [Touch] { [] }
    func pendingEvents() -> [ControlEvent] { [] }
}

/// Simple in-memory input system suitable for tests and prototypes.
public final class DefaultInputSystem: InputSystem {
    private struct EventContinuation: Identifiable {
        let id = UUID()
        let continuation: AsyncStream<ControlEvent>.Continuation
    }

    private var axisValues: [String: AxisValue] = [:]
    private var buttonsDown: Set<String> = []
    private var buttonsPressed: Set<String> = []
    private var continuations: [EventContinuation] = []
    private var eventQueue: [ControlEvent] = []

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

    public func pendingEvents() -> [ControlEvent] {
        let events = eventQueue
        eventQueue.removeAll()
        return events
    }

    /// Returns a copy of current axis values for debugging purposes.
    public func snapshotAxes() -> [String: AxisValue] {
        axisValues
    }

    // MARK: - Host/test helpers
    /// Feeds an input event into the system and makes it observable via `pendingEvents` / `eventsStream`.
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
        eventQueue.append(event)
        continuations.forEach { $0.continuation.yield(event) }
    }
}
