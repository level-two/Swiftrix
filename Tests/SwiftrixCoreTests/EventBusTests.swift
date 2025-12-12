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

    func testEventsDeliveredInPostOrder() async {
        let bus = DefaultEventBus()
        let stream = bus.subscribe(TestEvent.self)
        var received: [Int] = []

        let task = Task {
            for await event in stream.prefix(3) {
                received.append(event.value)
            }
        }

        bus.post(TestEvent(value: 1))
        bus.post(TestEvent(value: 2))
        bus.post(TestEvent(value: 3))

        await task.value
        XCTAssertEqual(received, [1, 2, 3])
    }

    func testCancellingSubscriberStopsDelivery() async {
        let bus = DefaultEventBus()
        let stream = bus.subscribe(TestEvent.self)
        var received: [Int] = []

        let task = Task {
            for await event in stream {
                received.append(event.value)
                break // consume first event then exit
            }
        }

        bus.post(TestEvent(value: 1))
        await task.value

        // Cancel to trigger termination cleanup
        task.cancel()
        bus.post(TestEvent(value: 2))

        // Give the bus a moment to deliver if it were going to.
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(received, [1])
    }
}
