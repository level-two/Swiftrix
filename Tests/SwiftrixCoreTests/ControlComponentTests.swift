import XCTest
@testable import SwiftrixCore

private final class RecordingControl: ControlComponent {
    var received: [ControlEvent] = []
    override func handle(event: ControlEvent) { received.append(event) }
    override func update(deltaTime: TimeInterval) {}
}

final class ControlComponentTests: XCTestCase {
    func testEventsDispatchedToControlComponents() {
        let input = DefaultInputSystem()
        let scene = Scene(inputSystem: input)

        let go = GameObject(name: "Player")
        let control = RecordingControl()
        go.addComponent(control)
        scene.addRootObject(go)

        input.send(event: .buttonDown("Jump"))
        scene.update(deltaTime: 0.016)

        XCTAssertEqual(control.received, [.buttonDown("Jump")])
    }
}
