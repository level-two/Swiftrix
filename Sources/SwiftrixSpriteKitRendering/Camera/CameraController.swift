import Foundation
import SpriteKit

public struct CameraConfig {
    public enum Mode {
        case staticOffset(CGPoint)
        case followObject(UUID, offset: CGPoint = .zero)
    }

    public var mode: Mode
    public var zoom: CGFloat

    public init(mode: Mode, zoom: CGFloat = 1.0) {
        self.mode = mode
        self.zoom = zoom
    }
}

/// Minimal camera wrapper that positions an `SKCameraNode` based on Core object transforms.
public final class CameraController {
    public let cameraNode: SKCameraNode
    public var config: CameraConfig

    public init(config: CameraConfig = CameraConfig(mode: .staticOffset(.zero), zoom: 1.0)) {
        self.config = config
        self.cameraNode = SKCameraNode()
    }

    public func update(using registry: NodeBindingRegistry, in scene: SKScene) {
        switch config.mode {
        case .staticOffset(let offset):
            cameraNode.position = offset
        case .followObject(let objectID, let offset):
            guard let binding = registry.binding(forID: objectID) else { return }
            let worldPoint = binding.node.convert(CGPoint.zero, to: scene)
            cameraNode.position = CGPoint(x: worldPoint.x + offset.x, y: worldPoint.y + offset.y)
        }
        cameraNode.setScale(config.zoom)
        if scene.camera !== cameraNode {
            scene.camera = cameraNode
            if cameraNode.parent !== scene {
                scene.addChild(cameraNode)
            }
        }
    }
}
