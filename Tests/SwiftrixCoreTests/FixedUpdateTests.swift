import XCTest
@testable import SwiftrixCore

private final class FixedLoggingComponent: Component, FixedUpdatable {
    let label: String
    let log: (String) -> Void

    init(label: String, log: @escaping (String) -> Void, isEnabled: Bool = true) {
        self.label = label
        self.log = log
        super.init(isEnabled: isEnabled)
    }

    func fixedUpdate(fixedDeltaTime: TimeInterval) {
        log(label)
    }
}

private final class FixedLoggingScript: Script {
    let label: String
    let log: (String) -> Void

    init(label: String, log: @escaping (String) -> Void, isEnabled: Bool = true) {
        self.label = label
        self.log = log
        super.init(isEnabled: isEnabled)
    }

    override func fixedUpdate(fixedDeltaTime: TimeInterval) {
        log(label)
    }
}

final class FixedUpdateTests: XCTestCase {
    func testFixedUpdateCallsScriptsAndFixedComponents() {
        var events: [String] = []
        let go = GameObject(name: "Root")
        go.addComponent(FixedLoggingScript(label: "script", log: { events.append($0) }))
        go.addComponent(FixedLoggingComponent(label: "component", log: { events.append($0) }))

        go.fixedUpdate(fixedDeltaTime: 0.02)

        XCTAssertEqual(events, ["script", "component"])
    }

    func testFixedUpdateSkipsDisabledScriptsAndComponents() {
        var events: [String] = []
        let go = GameObject(name: "Root")
        go.addComponent(FixedLoggingScript(label: "script", log: { events.append($0) }, isEnabled: false))
        go.addComponent(FixedLoggingComponent(label: "component", log: { events.append($0) }, isEnabled: false))

        go.fixedUpdate(fixedDeltaTime: 0.02)

        XCTAssertEqual(events, [])
    }

    func testFixedUpdateSkipsDestroyedObjects() {
        var events: [String] = []
        let go = GameObject(name: "Root")
        go.addComponent(FixedLoggingScript(label: "script", log: { events.append($0) }))
        go.destroy()

        go.fixedUpdate(fixedDeltaTime: 0.02)

        XCTAssertEqual(events, [])
    }

    func testFixedUpdateDestroyStopsRemainingComponentsAndChildren() {
        var events: [String] = []

        final class DestroyingScript: Script {
            let log: (String) -> Void
            init(log: @escaping (String) -> Void) { self.log = log }
            override func fixedUpdate(fixedDeltaTime: TimeInterval) {
                log("script")
                gameObject.destroy()
            }
        }

        let root = GameObject(name: "Root")
        root.addComponent(DestroyingScript(log: { events.append($0) }))
        root.addComponent(FixedLoggingComponent(label: "component", log: { events.append($0) }))

        let child = GameObject(name: "Child")
        child.addComponent(FixedLoggingComponent(label: "child", log: { events.append($0) }))
        root.addChild(child)

        root.fixedUpdate(fixedDeltaTime: 0.02)

        XCTAssertEqual(events, ["script"])
    }

    func testFixedUpdateTraversalIsDepthFirst() {
        var events: [String] = []
        let root = GameObject(name: "Root")
        let child = GameObject(name: "Child")
        root.addChild(child)

        root.addComponent(FixedLoggingComponent(label: "root", log: { events.append($0) }))
        child.addComponent(FixedLoggingComponent(label: "child", log: { events.append($0) }))

        SceneGraphTraversal.depthFirstFixedUpdate(objects: [root], fixedDeltaTime: 0.02)

        XCTAssertEqual(events, ["root", "child"])
    }
}
