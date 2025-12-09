import Foundation
import SpriteKit

/// Renders lightweight overlays (bounds/anchor markers) for debug visibility.
public final class DebugOverlayRenderer {
    private var overlayNodes: [UUID: SKNode] = [:]

    public init() {}

    public func removeOverlay(for id: UUID) {
        overlayNodes[id]?.removeFromParent()
        overlayNodes.removeValue(forKey: id)
    }

    public func clear() {
        overlayNodes.values.forEach { $0.removeFromParent() }
        overlayNodes.removeAll()
    }

    public func renderOverlay(for binding: NodeBinding, in scene: SKScene, config: DebugOverlayConfig) {
        guard config.isEnabled else {
            removeOverlay(for: binding.objectID)
            return
        }

        let container: SKNode
        if let existing = overlayNodes[binding.objectID] {
            container = existing
        } else {
            container = SKNode()
            overlayNodes[binding.objectID] = container
            scene.addChild(container)
        }
        container.removeAllChildren()

        if config.showBounds {
            let rectPath = CGMutablePath()
            let frame = binding.node.calculateAccumulatedFrame()
            rectPath.addRect(frame)
            let shape = SKShapeNode(path: rectPath)
            shape.strokeColor = config.lineColor
            shape.lineWidth = config.lineWidth
            shape.fillColor = .clear
            shape.zPosition = .greatestFiniteMagnitude
            container.addChild(shape)
        }

        if config.showAnchors {
            let anchorSize: CGFloat = 4
            let frame = binding.node.calculateAccumulatedFrame()
            let anchorRect = CGRect(
                x: frame.midX - anchorSize / 2,
                y: frame.midY - anchorSize / 2,
                width: anchorSize,
                height: anchorSize
            )
            let path = CGMutablePath()
            path.addRect(anchorRect)
            let anchorShape = SKShapeNode(path: path)
            anchorShape.fillColor = config.lineColor
            anchorShape.strokeColor = config.lineColor
            anchorShape.lineWidth = 0
            anchorShape.zPosition = .greatestFiniteMagnitude
            container.addChild(anchorShape)
        }
    }
}
