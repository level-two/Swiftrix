import Foundation
import SpriteKit
import SwiftrixCore

/// Sprite-based view that maps to `SKSpriteNode`.
public final class SpriteView: View, SpriteKitRenderable {

    public var textureName: String?
    public var color: SKColor
    public var size: CGSize?
    public var zPosition: CGFloat

    public init(
        textureName: String? = nil,
        color: SKColor = .white,
        size: CGSize? = nil,
        anchor: Vector2 = Vector2(x: 0.5, y: 0.5),
        zPosition: CGFloat = 0,
        isEnabled: Bool = true
    ) {
        self.textureName = textureName
        self.color = color
        self.size = size
        self.zPosition = zPosition
        super.init(anchor: anchor, isEnabled: isEnabled)
    }

    public override func update(deltaTime: TimeInterval) {}

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

    public var anchorPoint: CGPoint {
        get { CGPoint(x: anchor.x, y: anchor.y) }
        set { anchor = Vector2(x: Double(newValue.x), y: Double(newValue.y)) }
    }

    func resolvedTexture() -> SKTexture? {
        guard let textureName, !textureName.isEmpty else { return nil }
        return SKTexture(imageNamed: textureName)
    }
}
