import XCTest
@testable import SwiftrixCore

private struct TestEvent: GameEvent, Equatable {
    let value: Int
}

final class EventBusTests: XCTestCase {
    func testSubscribeAndPost() async {
        let bus = DefaultEventBus()
        var received: [Int] = []
        let stream = bus.subscribe(TestEvent.self)

        let task = Task {
            for await event in stream.prefix(2) {
                received.append(event.value)
            }
        }

        bus.post(TestEvent(value: 1))
        bus.post(TestEvent(value: 2))
        await task.value

        XCTAssertEqual(received, [1, 2])
    }
}
