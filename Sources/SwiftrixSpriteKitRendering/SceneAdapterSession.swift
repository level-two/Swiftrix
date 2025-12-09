import Foundation
import SpriteKit
import SwiftrixCore

public enum SceneAdapterState {
    case idle
    case running
    case paused
    case stopped
}

/// Performance budget configuration. When `maxSyncOpsPerFrame` is set,
/// sync work is spread across multiple frames to avoid hitches.
public struct PerformanceBudget {
    public var maxSyncOpsPerFrame: Int?

    public init(maxSyncOpsPerFrame: Int? = nil) {
        self.maxSyncOpsPerFrame = maxSyncOpsPerFrame
    }

    public static let `default` = PerformanceBudget(maxSyncOpsPerFrame: nil)
}

/// Tracks the active binding between a Core scene and a SpriteKit scene.
public final class SceneAdapterSession {
    public let id = UUID()
    public let coreScene: Scene
    public let skScene: SKScene
    public var state: SceneAdapterState = .idle
    public var performanceBudget: PerformanceBudget
    public let registry: NodeBindingRegistry
    public let dirtyQueue: DirtySyncQueue

    init(coreScene: Scene, skScene: SKScene, performanceBudget: PerformanceBudget, registry: NodeBindingRegistry, dirtyQueue: DirtySyncQueue) {
        self.coreScene = coreScene
        self.skScene = skScene
        self.performanceBudget = performanceBudget
        self.registry = registry
        self.dirtyQueue = dirtyQueue
    }
}
