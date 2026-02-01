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
        let scene = DefaultScene(inputSystem: input)

        let go = GameObject(name: "Player")
        let control = RecordingControl()
        go.addComponent(control)
        scene.addRootObject(go)

        input.send(event: .buttonDown("Jump"))
        scene.update(deltaTime: 0.016)

        XCTAssertEqual(control.received, [.buttonDown("Jump")])
    }

    func testDispatchOrderIsDepthFirstAndSkipsDisabled() {
        var log: [String] = []

        final class NamedControl: ControlComponent {
            let name: String
            let log: (String) -> Void
            init(name: String, log: @escaping (String) -> Void, isEnabled: Bool = true) {
                self.name = name
                self.log = log
                super.init(isEnabled: isEnabled)
            }
            override func handle(event: ControlEvent) { log(name) }
        }

        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        let grandchild = GameObject(name: "Grandchild")
        root.addChild(child)
        child.addChild(grandchild)

        root.addComponent(NamedControl(name: "root", log: { log.append($0) }))
        child.addComponent(NamedControl(name: "child", log: { log.append($0) }, isEnabled: false))
        grandchild.addComponent(NamedControl(name: "grandchild", log: { log.append($0) }))

        SceneGraphTraversal.dispatchControlEvents([.buttonDown("Jump")], to: [root])

        XCTAssertEqual(log, ["root", "grandchild"])
    }
}
