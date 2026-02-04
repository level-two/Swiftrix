import XCTest
@testable import SwiftrixCore

private final class RecordingInputSystem: InputSystem {
    private let record: (String) -> Void

    init(record: @escaping (String) -> Void) {
        self.record = record
    }

    func update() { record("input") }
    func axis(named name: String) -> AxisValue { AxisValue(value: 0) }
    func isButtonDown(_ name: String) -> Bool { false }
    func isButtonUp(_ name: String) -> Bool { true }
    func isButtonPressed(_ name: String) -> Bool { false }
    func eventsStream() -> AsyncStream<ControlEvent> { AsyncStream { _ in } }
    func pendingEvents() -> [ControlEvent] { [] }
    func touches() -> [Touch] { [] }
}

private final class RecordingFixedComponent: Component, FixedUpdatable {
    private let record: (String) -> Void

    init(record: @escaping (String) -> Void) {
        self.record = record
        super.init()
    }

    func fixedUpdate(fixedDeltaTime: TimeInterval) {
        record("fixed")
    }
}

private final class RecordingUpdateScript: Script {
    private let record: (String) -> Void

    init(record: @escaping (String) -> Void) {
        self.record = record
        super.init()
    }

    override func update(deltaTime: TimeInterval) {
        record("update")
    }
}

final class GameLoopInputSamplingTests: XCTestCase {
    func testInputSamplingHappensAfterFixedAndBeforeUpdate() {
        var log: [String] = []
        let input = RecordingInputSystem(record: { log.append($0) })
        let scene = TestScene(inputSystem: input)

        let root = GameObject(name: "Root")
        root.addComponent(RecordingFixedComponent(record: { log.append($0) }))
        root.addComponent(RecordingUpdateScript(record: { log.append($0) }))
        scene.addRootObject(root)

        let loop = GameLoop(scene: scene, fixedDeltaTime: 0.1)
        loop.tick(deltaTime: 0.1)

        XCTAssertEqual(log, ["fixed", "input", "update"])
    }
}
