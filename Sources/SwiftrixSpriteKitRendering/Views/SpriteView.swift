import Foundation
import SpriteKit
import SwiftrixCore

/// Sprite-based view that maps to `SKSpriteNode`.
public final class SpriteView: SpriteKitRenderable {
    public weak var gameObject: GameObjectInterface?
    public var isEnabled: Bool = true

    public var textureName: String?
    public var color: SKColor
    public var size: CGSize?
    public var anchorPoint: CGPoint
    public var zPosition: CGFloat

    public init(
        textureName: String? = nil,
        color: SKColor = .white,
        size: CGSize? = nil,
        anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
        zPosition: CGFloat = 0
    ) {
        self.textureName = textureName
        self.color = color
        self.size = size
        self.anchorPoint = anchorPoint
        self.zPosition = zPosition
    }

    public func update(deltaTime: TimeInterval) {}

    public func makeNode() -> SKNode {
        let sprite = SKSpriteNode(texture: resolvedTexture())
        applyProperties(on: sprite)
        return sprite
    }

    public func update(node: SKNode) {
        guard let sprite = node as? SKSpriteNode else { return }
        sprite.texture = resolvedTexture()
        applyProperties(on: sprite)
    }

    private func applyProperties(on sprite: SKSpriteNode) {
        sprite.anchorPoint = anchorPoint
        sprite.color = color
        sprite.colorBlendFactor = 1.0
        if let size {
            sprite.size = size
        }
        sprite.zPosition = zPosition
    }

    func resolvedTexture() -> SKTexture? {
        guard let textureName, !textureName.isEmpty else { return nil }
        return SKTexture(imageNamed: textureName)
    }
}
