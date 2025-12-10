import Foundation
import SwiftrixCore

/// Simple script used to verify game loop ticking.
final class CountingScript: Script {
    var gameObject: GameObject?
    var isEnabled: Bool = true
    var updateCount = 0

    func update(deltaTime: TimeInterval) {
        updateCount += 1
    }
}
