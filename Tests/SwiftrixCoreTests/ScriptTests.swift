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
