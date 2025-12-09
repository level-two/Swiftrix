import Foundation
import SpriteKit
import SwiftrixCore

/// Contract for view components that can produce and update SpriteKit nodes.
public protocol SpriteKitRenderable: View {
    func makeNode() -> SKNode
    func update(node: SKNode)
}

/// Mapping between a Core game object and its SpriteKit node.
public final class NodeBinding {
    public let objectID: UUID
    public weak var gameObject: GameObject?
    public var viewComponent: SpriteKitRenderable?
    public let node: SKNode

    init(objectID: UUID, gameObject: GameObject?, viewComponent: SpriteKitRenderable?, node: SKNode) {
        self.objectID = objectID
        self.gameObject = gameObject
        self.viewComponent = viewComponent
        self.node = node
    }
}

/// Registry that manages bindings and removes stale entries.
public final class NodeBindingRegistry {
    private var bindings: [UUID: NodeBinding] = [:]

    public init() {}

    @discardableResult
    public func binding(for object: GameObject, viewComponent: SpriteKitRenderable?) -> NodeBinding {
        if let existing = bindings[object.id] {
            existing.gameObject = object
            existing.viewComponent = viewComponent
            return existing
        }

        let node = viewComponent?.makeNode() ?? SKNode()
        node.name = object.name
        let binding = NodeBinding(objectID: object.id, gameObject: object, viewComponent: viewComponent, node: node)
        bindings[object.id] = binding
        return binding
    }

    public func binding(forID id: UUID) -> NodeBinding? {
        bindings[id]
    }

    /// Removes bindings that were not visited during the latest sync cycle.
    public func removeUnvisited(excluding visited: Set<UUID>) -> [NodeBinding] {
        let staleIDs = bindings.keys.filter { !visited.contains($0) }
        let removed = staleIDs.compactMap { bindings.removeValue(forKey: $0) }
        return removed
    }

    public func allBindings() -> [NodeBinding] {
        Array(bindings.values)
    }
}
