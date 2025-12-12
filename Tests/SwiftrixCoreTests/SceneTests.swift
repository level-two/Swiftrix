import XCTest
import CoreGraphics
@testable import SwiftrixCore

private final class RecordingComponent: Component {
    private let record: (String) -> Void

    init(record: @escaping (String) -> Void) {
        self.record = record
    }

    override func update(deltaTime: TimeInterval) {
        if let name = gameObject?.name { record(name) }
    }
}

private final class RecordingPhysicsWorld: PhysicsWorld {
    var added: [Collider] = []
    var removed: [Collider] = []

    func addCollider(_ collider: Collider) { added.append(collider) }
    func removeCollider(_ collider: Collider) { removed.append(collider) }
    func step(fixedDeltaTime: TimeInterval, eventBus: EventBus) {}
    func query(overlap rect: CGRect, in group: CollisionGroup?) -> [Collider] { [] }
}

private final class RecordingControlComponent: ControlComponent {
    var handled: [ControlEvent] = []
    override func handle(event: ControlEvent) { handled.append(event) }
}

private final class RecordingInputSystem: InputSystem {
    var log: [String] = []
    var queuedEvents: [ControlEvent]

    init(events: [ControlEvent]) {
        self.queuedEvents = events
    }

    func update() { log.append("update") }
    func axis(named name: String) -> AxisValue { AxisValue(value: 0) }
    func isButtonDown(_ name: String) -> Bool { false }
    func isButtonUp(_ name: String) -> Bool { true }
    func isButtonPressed(_ name: String) -> Bool { false }
    func eventsStream() -> AsyncStream<ControlEvent> { AsyncStream { _ in } }
    func pendingEvents() -> [ControlEvent] {
        log.append("pending")
        let events = queuedEvents
        queuedEvents.removeAll()
        return events
    }
}

final class SceneTests: XCTestCase {
    func testAddAndRemoveRoot() {
        let scene = Scene()
        let go = GameObject(name: "Root")
        scene.addRootObject(go)
        XCTAssertEqual(scene.rootObjects.count, 1)
        scene.removeRootObject(go)
        XCTAssertEqual(scene.rootObjects.count, 0)
    }

    func testDepthFirstTraversalRespectsHierarchy() {
        var log: [String] = []
        let root = GameObject(name: "Root")
        root.addComponent(RecordingComponent { log.append($0) })

        let child = GameObject(name: "Child")
        child.addComponent(RecordingComponent { log.append($0) })
        root.addChild(child)

        let scene = Scene()
        scene.addRootObject(root)
        scene.update(deltaTime: 1)

        XCTAssertEqual(log, ["Root", "Child"])
    }

    func testAddRootRegistersCollidersInSubtree() {
        let physics = RecordingPhysicsWorld()
        let scene = Scene(physicsWorld: physics)

        let rootCollider = BoxCollider(size: Vector2(x: 1, y: 1))
        let childCollider = BoxCollider(size: Vector2(x: 1, y: 1))

        let root = GameObject(name: "Root")
        root.addComponent(rootCollider)

        let child = GameObject(name: "Child")
        child.addComponent(childCollider)
        root.addChild(child)

        scene.addRootObject(root)
        XCTAssertEqual(physics.added.count, 2)
        XCTAssertIdentical(physics.added[0], rootCollider)
        XCTAssertIdentical(physics.added[1], childCollider)

        scene.removeRootObject(root)
        XCTAssertEqual(physics.removed.count, 2)
        XCTAssertIdentical(physics.removed[0], rootCollider)
        XCTAssertIdentical(physics.removed[1], childCollider)
    }

    func testUpdateSkipsDisabledOrDestroyedRootsAndSubtrees() {
        var log: [String] = []
        let root = GameObject(name: "Root")
        root.addComponent(RecordingComponent { log.append($0) })

        let child = GameObject(name: "Child")
        child.addComponent(RecordingComponent { log.append($0) })
        root.addChild(child)

        let scene = Scene()
        scene.addRootObject(root)

        root.isEnabled = false
        scene.update(deltaTime: 1)
        XCTAssertTrue(log.isEmpty)

        root.isEnabled = true
        root.destroy()
        scene.update(deltaTime: 1)
        XCTAssertTrue(log.isEmpty)
    }

    func testSceneUpdateDispatchesInputBeforeTraversal() {
        let input = RecordingInputSystem(events: [.buttonDown("Jump")])
        let scene = Scene(inputSystem: input)

        let root = GameObject(name: "Root")
        let control = RecordingControlComponent()
        root.addComponent(control)
        scene.addRootObject(root)

        scene.update(deltaTime: 1)

        XCTAssertEqual(input.log, ["update", "pending"])
        XCTAssertEqual(control.handled, [.buttonDown("Jump")])
    }
}
