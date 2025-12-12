import XCTest
@testable import SwiftrixCore

private final class LoggingComponent: Component {
    var log: [String]

    init(log: [String]) {
        self.log = log
    }

    override func update(deltaTime: TimeInterval) {
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
            var output: () -> Void
            init(output: @escaping () -> Void) { self.output = output }
            override func update(deltaTime: TimeInterval) { output() }
        }

        root.addComponent(Recorder { updates.append("Root") })
        childA.addComponent(Recorder { updates.append("ChildA") })
        childB.addComponent(Recorder { updates.append("ChildB") })

        SceneGraphTraversal.depthFirstUpdate(objects: [root], deltaTime: 1)

        XCTAssertEqual(updates, ["Root", "ChildA", "ChildB"])
    }

    func testDepthFirstDrawSkipsDisabledAndDestroyed() {
        var draws: [String] = []

        final class LoggingView: View {
            let name: String
            let log: (String) -> Void
            init(name: String, log: @escaping (String) -> Void, isEnabled: Bool = true) {
                self.name = name
                self.log = log
                super.init(isEnabled: isEnabled)
            }
            override func draw() { log(name) }
        }

        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        let destroyed = GameObject(name: "Destroyed")
        root.addChild(child)
        root.addChild(destroyed)

        root.addComponent(LoggingView(name: "root", log: { draws.append($0) }))
        child.addComponent(LoggingView(name: "child", log: { draws.append($0) }, isEnabled: false))
        destroyed.addComponent(LoggingView(name: "destroyed", log: { draws.append($0) }))
        destroyed.destroy()

        SceneGraphTraversal.depthFirstDraw(objects: [root])

        XCTAssertEqual(draws, ["root"])
    }
}
