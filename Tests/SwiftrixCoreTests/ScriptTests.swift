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
}
