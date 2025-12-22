import XCTest
@testable import SwiftrixCore

private final class TestScript: Script {
    var updates: Int = 0
    var collisions: Int = 0
    var controls: Int = 0

    override func update(deltaTime: TimeInterval) { updates += 1 }
    override func onCollision(with other: Collider) { collisions += 1 }
    override func onControl(_ event: ControlEvent) { controls += 1 }
}

final class ScriptTests: XCTestCase {
    func testScriptUpdateCalled() {
        let go = GameObject(name: "GO")
        let script = TestScript()
        go.addComponent(script)
        go.update(deltaTime: 0.5)
        XCTAssertEqual(script.updates, 1)
    }

    func testDisabledScriptNotCalled() {
        let go = GameObject(name: "GO")
        let script = TestScript()
        script.isEnabled = false
        go.addComponent(script)
        go.update(deltaTime: 0.5)
        XCTAssertEqual(script.updates, 0)
    }

    func testPreAndPostUpdateWrapComponentUpdate() {
        final class EventLog {
            var events: [String] = []
        }

        final class OrderedScript: Script {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func preUpdate(deltaTime: TimeInterval) { log.events.append("pre") }
            override func update(deltaTime: TimeInterval) { log.events.append("update") }
            override func postUpdate(deltaTime: TimeInterval) { log.events.append("post") }
        }

        final class MarkerComponent: Component {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func update(deltaTime: TimeInterval) { log.events.append("component") }
        }

        let log = EventLog()
        let go = GameObject(name: "GO")
        go.addComponent(OrderedScript(log: log))
        go.addComponent(MarkerComponent(log: log))

        go.update(deltaTime: 0.5)

        XCTAssertEqual(log.events, ["pre", "update", "component", "post"])
    }

    func testPreUpdateRunsBeforeAnyComponentUpdateForObject() {
        final class EventLog {
            var events: [String] = []
        }

        final class RecordingScript: Script {
            let label: String
            let log: EventLog
            init(label: String, log: EventLog) {
                self.label = label
                self.log = log
            }
            override func preUpdate(deltaTime: TimeInterval) { log.events.append("pre:\(label)") }
            override func update(deltaTime: TimeInterval) { log.events.append("update:\(label)") }
        }

        final class MarkerComponent: Component {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func update(deltaTime: TimeInterval) { log.events.append("component") }
        }

        let log = EventLog()
        let go = GameObject(name: "GO")
        go.addComponent(RecordingScript(label: "A", log: log))
        go.addComponent(MarkerComponent(log: log))
        go.addComponent(RecordingScript(label: "B", log: log))

        go.update(deltaTime: 0.5)

        XCTAssertEqual(log.events.first, "pre:A")
        XCTAssertEqual(log.events[1], "pre:B")
        XCTAssertEqual(log.events.contains("component"), true)

        let firstUpdateIndex = log.events.firstIndex(where: { $0.hasPrefix("update:") })!
        let lastPreIndex = log.events.lastIndex(where: { $0.hasPrefix("pre:") })!
        XCTAssertGreaterThan(firstUpdateIndex, lastPreIndex)
    }

    func testDestroyedObjectDoesNotReceiveAnyUpdateSignals() {
        final class EventLog {
            var events: [String] = []
        }

        final class RecordingScript: Script {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func preUpdate(deltaTime: TimeInterval) { log.events.append("pre") }
            override func update(deltaTime: TimeInterval) { log.events.append("update") }
            override func postUpdate(deltaTime: TimeInterval) { log.events.append("post") }
        }

        let log = EventLog()
        let go = GameObject(name: "GO")
        go.addComponent(RecordingScript(log: log))

        go.destroy()
        go.update(deltaTime: 0.5)

        XCTAssertEqual(log.events, [])
    }

    func testDestroyDuringPreUpdateStopsFurtherSignals() {
        final class EventLog {
            var events: [String] = []
        }

        final class DestroyingScript: Script {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func preUpdate(deltaTime: TimeInterval) {
                log.events.append("pre")
                gameObject.destroy()
            }
            override func update(deltaTime: TimeInterval) { log.events.append("update") }
            override func postUpdate(deltaTime: TimeInterval) { log.events.append("post") }
        }

        final class MarkerComponent: Component {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func update(deltaTime: TimeInterval) { log.events.append("component") }
        }

        let log = EventLog()
        let go = GameObject(name: "GO")
        go.addComponent(DestroyingScript(log: log))
        go.addComponent(MarkerComponent(log: log))

        go.update(deltaTime: 0.5)

        XCTAssertEqual(log.events, ["pre"])
    }

    func testDestroyDuringUpdateStopsPostUpdateAndRemainingComponents() {
        final class EventLog {
            var events: [String] = []
        }

        final class DestroyingScript: Script {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func update(deltaTime: TimeInterval) {
                log.events.append("script:update")
                gameObject.destroy()
            }
            override func postUpdate(deltaTime: TimeInterval) { log.events.append("post") }
        }

        final class MarkerComponent: Component {
            let log: EventLog
            init(log: EventLog) { self.log = log }
            override func update(deltaTime: TimeInterval) { log.events.append("component") }
        }

        let log = EventLog()
        let go = GameObject(name: "GO")
        go.addComponent(DestroyingScript(log: log))
        go.addComponent(MarkerComponent(log: log))

        go.update(deltaTime: 0.5)

        XCTAssertEqual(log.events, ["script:update"])
    }

    func testTransformHelpersMutateGameObject() {
        final class MoveScript: Script {
            override func update(deltaTime: TimeInterval) {
                position = Vector2(x: 2, y: 3)
                scale = Vector2(x: 4, y: 5)
            }
        }

        let go = GameObject(name: "Mover")
        let script = MoveScript()
        go.addComponent(script)

        go.update(deltaTime: 0.1)

        XCTAssertEqual(go.position, Vector2(x: 2, y: 3))
        XCTAssertEqual(go.scale, Vector2(x: 4, y: 5))
    }

    func testOnStartAndOnDestroyAreCalledOncePerScript() {
        final class HookedScript: Script {
            var starts = 0
            var destroys = 0
            override func onStart() { starts += 1 }
            override func onDestroy() { destroys += 1 }
        }

        let go = GameObject(name: "player")
        let script = HookedScript()
        go.addComponent(script)

        go.update(deltaTime: 1)
        go.update(deltaTime: 1)
        XCTAssertEqual(script.starts, 1)

        go.destroy()
        go.destroy()
        XCTAssertEqual(script.destroys, 1)
    }
}
