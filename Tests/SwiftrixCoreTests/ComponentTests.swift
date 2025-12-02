import XCTest
@testable import SwiftrixCore

private final class CounterComponent: Component {
    weak var gameObject: GameObject?
    var isEnabled: Bool = true
    var count = 0
    func update(deltaTime: TimeInterval) { count += 1 }
}

final class ComponentTests: XCTestCase {
    func testEnabledComponentReceivesUpdate() {
        let go = DefaultGameObject(name: "GO")
        let component = CounterComponent()
        go.addComponent(component)
        go.update(deltaTime: 1)
        XCTAssertEqual(component.count, 1)
    }

    func testDisabledComponentDoesNotReceiveUpdate() {
        let go = DefaultGameObject(name: "GO")
        let component = CounterComponent()
        component.isEnabled = false
        go.addComponent(component)
        go.update(deltaTime: 1)
        XCTAssertEqual(component.count, 0)
    }
}
