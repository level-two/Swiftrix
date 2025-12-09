import Foundation
import SpriteKit
import SwiftrixCore

/// Bridges a Swiftrix Core scene into a SpriteKit scene, driving the game loop
/// with a display-linked clock and mirroring the object hierarchy into SKNodes.
public final class SpriteKitSceneAdapter {
    public let session: SceneAdapterSession
    private let gameLoop: GameLoop
    private let displayLinkDriver: DisplayLinkDriving

    public init(
        scene: Scene,
        skScene: SKScene = SKScene(),
        displayLinkDriver: DisplayLinkDriving? = nil,
        fixedDeltaTime: TimeInterval = 1.0 / 60.0,
        performanceBudget: PerformanceBudget = .default
    ) {
        let registry = NodeBindingRegistry()
        let dirtyQueue = DirtySyncQueue()
        self.session = SceneAdapterSession(
            coreScene: scene,
            skScene: skScene,
            performanceBudget: performanceBudget,
            registry: registry,
            dirtyQueue: dirtyQueue
        )
        self.gameLoop = GameLoop(scene: scene, fixedDeltaTime: fixedDeltaTime)
        self.displayLinkDriver = displayLinkDriver ?? CADisplayLinkDriver()
        self.displayLinkDriver.onTick = { [weak self] delta in
            self?.tick(deltaTime: delta)
        }
        self.session.skScene.scaleMode = .resizeFill
    }

    // MARK: - Lifecycle

    public func start() {
        guard session.state == .idle || session.state == .stopped else { return }
        session.state = .running
        rebuildSceneGraph()
        markSceneDirty()
        processDirtyQueue()
        displayLinkDriver.start()
        session.skScene.isPaused = false
    }

    public func pause() {
        guard session.state == .running else { return }
        session.state = .paused
        displayLinkDriver.pause()
        session.skScene.isPaused = true
    }

    public func resume() {
        guard session.state == .paused else { return }
        session.state = .running
        session.skScene.isPaused = false
        displayLinkDriver.resume()
    }

    public func stop() {
        guard session.state != .stopped else { return }
        displayLinkDriver.stop()
        tearDownBindings()
        session.state = .stopped
    }

    /// Manual stepping helper used by tests or tooling.
    public func step(deltaTime: TimeInterval) {
        tick(deltaTime: deltaTime)
    }

    // MARK: - Sync pipeline

    private func tick(deltaTime: TimeInterval) {
        guard session.state == .running else { return }
        gameLoop.tick(deltaTime: deltaTime)
        rebuildSceneGraph()
        markSceneDirty()
        processDirtyQueue()
    }

    private func rebuildSceneGraph() {
        var visited: Set<UUID> = []
        for root in session.coreScene.rootObjects where !root.isDestroyed {
            attach(object: root, to: session.skScene, visited: &visited)
        }
        let removed = session.registry.removeUnvisited(excluding: visited)
        removed.forEach { $0.node.removeFromParent() }
    }

    private func attach(object: GameObject, to parentNode: SKNode, visited: inout Set<UUID>) {
        let renderable = firstRenderable(from: object)
        let binding = session.registry.binding(for: object, viewComponent: renderable)
        visited.insert(binding.objectID)

        if binding.node.parent !== parentNode {
            binding.node.removeFromParent()
            parentNode.addChild(binding.node)
        }

        renderable?.update(node: binding.node)

        for child in object.children where !child.isDestroyed {
            attach(object: child, to: binding.node, visited: &visited)
        }
    }

    private func markSceneDirty() {
        mark(objects: session.coreScene.rootObjects)
    }

    private func mark(objects: [GameObject]) {
        for object in objects where !object.isDestroyed {
            session.dirtyQueue.markDirty(object.id)
            mark(objects: object.children)
        }
    }

    private func processDirtyQueue() {
        let ids = session.dirtyQueue.drain(maxItems: session.performanceBudget.maxSyncOpsPerFrame)
        guard !ids.isEmpty else { return }
        for id in ids {
            guard let binding = session.registry.binding(forID: id),
                  let object = binding.gameObject else { continue }
            applyTransform(object.localTransform, to: binding.node)
            binding.node.name = object.name

            let isVisible = object.isEnabled && (binding.viewComponent?.isEnabled ?? true)
            binding.node.isHidden = !isVisible
            binding.viewComponent?.update(node: binding.node)
        }
    }

    private func applyTransform(_ transform: Transform2D, to node: SKNode) {
        node.position = CGPoint(x: transform.position.x, y: transform.position.y)
        node.zRotation = CGFloat(transform.rotation)
        node.xScale = CGFloat(transform.scale.x)
        node.yScale = CGFloat(transform.scale.y)
    }

    private func tearDownBindings() {
        session.registry.allBindings().forEach { $0.node.removeFromParent() }
        session.dirtyQueue.clear()
    }

    private func firstRenderable(from object: GameObject) -> SpriteKitRenderable? {
        object.components.compactMap { $0 as? SpriteKitRenderable }.first
    }

    // MARK: - Debug helpers

    public func node(for objectID: UUID) -> SKNode? {
        session.registry.binding(forID: objectID)?.node
    }
}
