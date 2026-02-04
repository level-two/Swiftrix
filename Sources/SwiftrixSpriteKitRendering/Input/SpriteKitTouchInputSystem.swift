import Foundation
import SpriteKit
import SwiftrixCore
#if canImport(UIKit)
import UIKit
#endif

/// Touch-capable input system that can be fed from SpriteKit touch callbacks.
public final class SpriteKitTouchInputSystem: InputSystem {
    private struct TouchRecord {
        var id: Int
        var position: Vector2
        var phase: TouchPhase
        var updatedThisFrame: Bool
        var removalPending: Bool
    }

    private var nextTouchId: Int = 0
    private var touchByObjectId: [ObjectIdentifier: Int] = [:]
    private var objectIdByTouch: [Int: ObjectIdentifier] = [:]
    private var records: [Int: TouchRecord] = [:]

    public init() {}

    public func update() {
        advanceFrame()
    }

    public func axis(named name: String) -> AxisValue {
        AxisValue(value: 0)
    }

    public func isButtonDown(_ name: String) -> Bool {
        false
    }

    public func isButtonUp(_ name: String) -> Bool {
        true
    }

    public func isButtonPressed(_ name: String) -> Bool {
        false
    }

    public func touches() -> [Touch] {
        records.values
            .map { Touch(id: $0.id, position: $0.position, phase: $0.phase) }
            .sorted { $0.id < $1.id }
    }

    public func eventsStream() -> AsyncStream<ControlEvent> {
        AsyncStream { _ in }
    }

    public func pendingEvents() -> [ControlEvent] {
        []
    }

    #if canImport(UIKit)
    func handleTouchesBegan(_ touches: Set<UITouch>, in scene: SKScene) {
        touches.forEach { touch in
            let position = touch.location(in: scene)
            let id = id(for: touch)
            setTouch(id: id, position: vector(from: position), phase: .began)
        }
    }

    func handleTouchesMoved(_ touches: Set<UITouch>, in scene: SKScene) {
        touches.forEach { touch in
            let position = touch.location(in: scene)
            let id = id(for: touch)
            setTouch(id: id, position: vector(from: position), phase: .moved)
        }
    }

    func handleTouchesEnded(_ touches: Set<UITouch>, in scene: SKScene) {
        touches.forEach { touch in
            let position = touch.location(in: scene)
            let id = id(for: touch)
            setTouch(id: id, position: vector(from: position), phase: .ended)
        }
    }

    func handleTouchesCancelled(_ touches: Set<UITouch>, in scene: SKScene) {
        touches.forEach { touch in
            let position = touch.location(in: scene)
            let id = id(for: touch)
            setTouch(id: id, position: vector(from: position), phase: .cancelled)
        }
    }
    #endif

    func beginTouch(id: Int, position: Vector2) {
        setTouch(id: id, position: position, phase: .began)
    }

    func moveTouch(id: Int, position: Vector2) {
        setTouch(id: id, position: position, phase: .moved)
    }

    func endTouch(id: Int, position: Vector2) {
        setTouch(id: id, position: position, phase: .ended)
    }

    func cancelTouch(id: Int, position: Vector2) {
        setTouch(id: id, position: position, phase: .cancelled)
    }

    private func advanceFrame() {
        var updated: [Int: TouchRecord] = [:]
        for (id, record) in records {
            if record.removalPending {
                if let objectId = objectIdByTouch[id] {
                    touchByObjectId.removeValue(forKey: objectId)
                    objectIdByTouch.removeValue(forKey: id)
                }
                continue
            }

            var next = record
            if record.phase == .ended || record.phase == .cancelled {
                next.removalPending = true
            } else if record.updatedThisFrame == false {
                next.phase = .stationary
            }
            next.updatedThisFrame = false
            updated[id] = next
        }
        records = updated
    }

    private func setTouch(id: Int, position: Vector2, phase: TouchPhase) {
        var record = records[id] ?? TouchRecord(
            id: id,
            position: position,
            phase: phase,
            updatedThisFrame: true,
            removalPending: false
        )
        record.position = position
        record.phase = phase
        record.updatedThisFrame = true
        records[id] = record
    }

    private func vector(from point: CGPoint) -> Vector2 {
        Vector2(x: Double(point.x), y: Double(point.y))
    }

    #if canImport(UIKit)
    private func id(for touch: UITouch) -> Int {
        let objectId = ObjectIdentifier(touch)
        if let existing = touchByObjectId[objectId] {
            return existing
        }
        let id = nextTouchId
        nextTouchId += 1
        touchByObjectId[objectId] = id
        objectIdByTouch[id] = objectId
        return id
    }
    #endif
}
