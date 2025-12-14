import Foundation
import SpriteKit
import SwiftrixCore

/// Transform-only view that renders as a plain `SKNode`.
open class ContainerView: View, SpriteKitRenderable {

    public override init(isEnabled: Bool = true) {
        super.init(isEnabled: isEnabled)
    }

    open override func update(deltaTime: TimeInterval) {}

    open func makeNode() -> SKNode {
        SKNode()
    }

    open func update(node: SKNode) {
        // Container nodes carry transforms only; no-op for properties.
    }
}
