import XCTest
@testable import SwiftrixCore

private final class RecordingComponent: Component {
    weak var gameObject: GameObject?
    var isEnabled: Bool = true
    private let record: (String) -> Void

    init(record: @escaping (String) -> Void) {
        self.record = record
    }

    func update(deltaTime: TimeInterval) {
        if let name = gameObject?.name { record(name) }
    }
}

final class SceneTests: XCTestCase {
    func testAddAndRemoveRoot() {
        let scene = DefaultScene()
        let go = DefaultGameObject(name: "Root")
        scene.addRootObject(go)
        XCTAssertEqual(scene.rootObjects.count, 1)
        scene.removeRootObject(go)
        XCTAssertEqual(scene.rootObjects.count, 0)
    }

    func testDepthFirstTraversalRespectsHierarchy() {
        var log: [String] = []
        let root = DefaultGameObject(name: "Root")
        root.addComponent(RecordingComponent { log.append($0) })

        let child = DefaultGameObject(name: "Child")
        child.addComponent(RecordingComponent { log.append($0) })
        root.addChild(child)

        let scene = DefaultScene()
        scene.addRootObject(root)
        scene.update(deltaTime: 1)

        XCTAssertEqual(log, ["Root", "Child"])
    }
}
