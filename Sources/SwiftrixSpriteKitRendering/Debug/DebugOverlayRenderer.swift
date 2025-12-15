import Foundation
import SpriteKit

/// Renders lightweight overlays (bounds/anchor markers) for debug visibility.
public final class DebugOverlayRenderer {
    private var overlayNodes: [UUID: SKNode] = [:]

    public init() {}

    private func sceneSpaceBounds(for node: SKNode, in scene: SKScene) -> CGRect {
        let parentSpaceBounds = node.calculateAccumulatedFrame()
        guard let parent = node.parent else { return parentSpaceBounds }
        if parent === scene { return parentSpaceBounds }

        let corners = [
            CGPoint(x: parentSpaceBounds.minX, y: parentSpaceBounds.minY),
            CGPoint(x: parentSpaceBounds.minX, y: parentSpaceBounds.maxY),
            CGPoint(x: parentSpaceBounds.maxX, y: parentSpaceBounds.minY),
            CGPoint(x: parentSpaceBounds.maxX, y: parentSpaceBounds.maxY),
        ]

        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude

        for corner in corners {
            let world = parent.convert(corner, to: scene)
            minX = min(minX, world.x)
            minY = min(minY, world.y)
            maxX = max(maxX, world.x)
            maxY = max(maxY, world.y)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func sceneSpaceAnchor(for node: SKNode, in scene: SKScene) -> CGPoint {
        guard let parent = node.parent else { return node.position }
        if parent === scene { return node.position }
        return parent.convert(node.position, to: scene)
    }

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
            let frame = sceneSpaceBounds(for: binding.node, in: scene)
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
            let anchor = sceneSpaceAnchor(for: binding.node, in: scene)
            let anchorRect = CGRect(
                x: anchor.x - anchorSize / 2,
                y: anchor.y - anchorSize / 2,
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
