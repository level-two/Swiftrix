import Foundation
import SwiftrixCore

/// Simple script used to verify game loop ticking.
final class CountingScript: Script {
    var updateCount = 0

    override func update(deltaTime: TimeInterval) {
        updateCount += 1
    }
}
