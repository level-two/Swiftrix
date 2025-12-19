import Foundation
import SpriteKit
import SwiftrixCore

/// Contract for view components that can produce and update SpriteKit nodes.
public protocol SpriteKitRenderable: AnyObject {
    var isEnabled: Bool { get }
    func makeNode() -> SKNode
    func update(node: SKNode)
}

/// Captures the visual properties of `SpriteView` used for change detection.
public struct SpriteViewSignature: Equatable {
    public var textureName: String?
    public var colorComponents: (CGFloat, CGFloat, CGFloat, CGFloat)
    public var size: CGSize?
    public var anchorPoint: CGPoint
    public var zPosition: CGFloat
    public var animationNonce: Int

    public static func == (lhs: SpriteViewSignature, rhs: SpriteViewSignature) -> Bool {
        return lhs.textureName == rhs.textureName &&
        lhs.colorComponents.0 == rhs.colorComponents.0 &&
        lhs.colorComponents.1 == rhs.colorComponents.1 &&
        lhs.colorComponents.2 == rhs.colorComponents.2 &&
        lhs.colorComponents.3 == rhs.colorComponents.3 &&
        lhs.size == rhs.size &&
        lhs.anchorPoint == rhs.anchorPoint &&
        lhs.zPosition == rhs.zPosition &&
        lhs.animationNonce == rhs.animationNonce
    }
}

/// Mapping between a Core game object and its SpriteKit node.
public final class NodeBinding {
    public let objectID: UUID
    public weak var gameObject: GameObject?
    public var viewComponent: SpriteKitRenderable?
    public let node: SKNode
    public var parentObjectID: UUID?
    public var lastTransform: Transform2D?
    public var lastVisibility: Bool?
    public var spriteSignature: SpriteViewSignature?
    public var isNew: Bool = true

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
            let viewChanged = existing.viewComponent !== viewComponent
            existing.gameObject = object
            existing.viewComponent = viewComponent
            if viewChanged {
                existing.isNew = true
            }
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

    public func clear() {
        bindings.removeAll()
    }
}
