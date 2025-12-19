import Foundation
import SpriteKit

/// Translates SpriteKit hit tests back to Core GameObject identifiers.
public final class HitTestBridge {
    public init() {}

    /// Returns the first Core object id whose bound node appears in the hit test results.
    public func objectID(at point: CGPoint, in scene: SKScene, registry: NodeBindingRegistry) -> UUID? {
        let nodes = scene.nodes(at: point)
        for node in nodes {
            if let match = registry.allBindings().first(where: { $0.node === node || node.inParentHierarchy($0.node) }) {
                return match.objectID
            }
        }
        return nil
    }
}
