import Foundation
import SpriteKit
import SwiftrixCore

/// Transform-only view that renders as a plain `SKNode`.
public final class ContainerView: View, SpriteKitRenderable {

    public override init(isEnabled: Bool = true) {
        super.init(isEnabled: isEnabled)
    }

    public override func update(deltaTime: TimeInterval) {}

    public func makeNode() -> SKNode {
        SKNode()
    }

    public func update(node: SKNode) {
        // Container nodes carry transforms only; no-op for properties.
    }
}
