import XCTest
@testable import SwiftrixCore

private final class RecordingControl: ControlComponent {
    weak var gameObject: GameObject?
    var isEnabled: Bool = true
    var received: [ControlEvent] = []
    func handle(event: ControlEvent) { received.append(event) }
    func update(deltaTime: TimeInterval) {}
}

final class ControlComponentTests: XCTestCase {
    func testEventsDispatchedToControlComponents() {
        let input = DefaultInputSystem()
        let scene = DefaultScene(inputSystem: input)

        let go = DefaultGameObject(name: "Player")
        let control = RecordingControl()
        go.addComponent(control)
        scene.addRootObject(go)

        input.send(event: .buttonDown("Jump"))
        scene.update(deltaTime: 0.016)

        XCTAssertEqual(control.received, [.buttonDown("Jump")])
    }
}
