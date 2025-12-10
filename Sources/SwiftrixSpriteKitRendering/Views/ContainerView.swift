import Foundation
import SpriteKit
import SwiftrixCore

/// Transform-only view that renders as a plain `SKNode`.
public final class ContainerView: SpriteKitRenderable {
    public weak var gameObject: GameObjectInterface?
    public var isEnabled: Bool = true

    public init() {}

    public func update(deltaTime: TimeInterval) {}

    public func makeNode() -> SKNode {
        SKNode()
    }

    public func update(node: SKNode) {
        // Container nodes carry transforms only; no-op for properties.
    }
}
