import XCTest
@testable import SwiftrixCore

private final class LoggingComponent: Component {
    weak var gameObject: GameObjectInterface?
    var isEnabled: Bool = true
    var log: [String]

    init(log: [String]) {
        self.log = log
    }

    func update(deltaTime: TimeInterval) {
        if let name = gameObject?.name {
            log.append(name)
        }
    }
}

final class SceneTraversalTests: XCTestCase {
    func testDepthFirstUpdateOrder() {
        var updates: [String] = []
        let root = GameObject(name: "Root")
        let childA = GameObject(name: "ChildA")
        let childB = GameObject(name: "ChildB")
        root.addChild(childA)
        root.addChild(childB)

        class Recorder: Component {
            weak var gameObject: GameObjectInterface?
            var isEnabled: Bool = true
            var output: () -> Void
            init(output: @escaping () -> Void) { self.output = output }
            func update(deltaTime: TimeInterval) { output() }
        }

        root.addComponent(Recorder { updates.append("Root") })
        childA.addComponent(Recorder { updates.append("ChildA") })
        childB.addComponent(Recorder { updates.append("ChildB") })

        SceneGraphTraversal.depthFirstUpdate(objects: [root], deltaTime: 1)

        XCTAssertEqual(updates, ["Root", "ChildA", "ChildB"])
    }
}
