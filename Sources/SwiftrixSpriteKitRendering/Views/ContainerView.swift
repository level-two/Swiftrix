import Foundation
import SpriteKit
import SwiftrixCore

/// Transform-only view that renders as a plain `SKNode`.
open class ContainerView: View, SpriteKitRenderable {

    public override init(anchor: Vector2 = Vector2(x: 0.5, y: 0.5), isEnabled: Bool = true) {
        super.init(anchor: anchor, isEnabled: isEnabled)
    }

    open override func update(deltaTime: TimeInterval) {}

    open func makeNode() -> SKNode {
        SKNode()
    }

    open func update(node: SKNode) {
        // Container nodes carry transforms only; no-op for properties.
    }
}
