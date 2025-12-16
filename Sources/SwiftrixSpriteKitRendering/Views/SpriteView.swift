import Foundation
import SpriteKit
import SwiftrixCore

/// Sprite-based view that maps to `SKSpriteNode`.
public final class SpriteView: View, SpriteKitRenderable {

    public var textureName: String?
    public var color: SKColor
    public var size: CGSize?
    public var zPosition: CGFloat
    private var pendingAnimation: SKAction?
    private var stopAnimationRequested: Bool = false
    private var animationNonce: Int = 0

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

    /// Starts a texture animation on the bound SpriteKit node.
    /// - Parameters:
    ///   - textures: Ordered frames.
    ///   - timePerFrame: Duration per frame in seconds.
    ///   - repeatForever: If true, the animation loops. Otherwise it plays once.
    public func animate(with textures: [SKTexture], timePerFrame: TimeInterval, repeatForever: Bool = true) {
        guard !textures.isEmpty else { return }
        let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        pendingAnimation = repeatForever ? SKAction.repeatForever(animation) : animation
        stopAnimationRequested = false
        animationNonce &+= 1
    }

    /// Convenience to animate by texture names.
    /// - Parameters:
    ///   - textureNames: Ordered frame names passed to `SKTexture(imageNamed:)`.
    ///   - timePerFrame: Duration per frame in seconds.
    ///   - repeatForever: If true, the animation loops. Otherwise it plays once.
    public func animate(textureNames: [String], timePerFrame: TimeInterval, repeatForever: Bool = true) {
        let textures = textureNames
            .filter { !$0.isEmpty }
            .map { SKTexture(imageNamed: $0) }
        animate(with: textures, timePerFrame: timePerFrame, repeatForever: repeatForever)
    }

    /// Stops any running animation started via `animate`.
    public func stopAnimation() {
        stopAnimationRequested = true
        pendingAnimation = nil
        animationNonce &+= 1
    }

    public func makeNode() -> SKNode {
        let sprite = SKSpriteNode(texture: resolvedTexture())
        applyProperties(on: sprite)
        return sprite
    }

    public func update(node: SKNode) {
        guard let sprite = node as? SKSpriteNode else { return }
        sprite.texture = resolvedTexture()
        applyProperties(on: sprite)

        if stopAnimationRequested {
            sprite.removeAction(forKey: Self.animationKey)
            stopAnimationRequested = false
        }

        if let animation = pendingAnimation {
            sprite.removeAction(forKey: Self.animationKey)
            sprite.run(animation, withKey: Self.animationKey)
            pendingAnimation = nil
        }
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

    var currentAnimationNonce: Int { animationNonce }

    func resolvedTexture() -> SKTexture? {
        guard let textureName, !textureName.isEmpty else { return nil }
        return SKTexture(imageNamed: textureName)
    }

    static let animationKey = "SpriteView.animation"
}
