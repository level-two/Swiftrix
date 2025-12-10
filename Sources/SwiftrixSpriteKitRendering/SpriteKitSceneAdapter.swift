import Foundation
import SpriteKit
import SwiftrixCore

/// Bridges a Swiftrix Core scene into a SpriteKit scene, driving the game loop
/// with a display-linked clock and mirroring the object hierarchy into SKNodes.
public final class SpriteKitSceneAdapter {
    public let session: SceneAdapterSession
    private let gameLoop: GameLoop
    private let displayLinkDriver: DisplayLinkDriving
    public var onDiagnostic: ((String) -> Void)?
    private let overlayRenderer = DebugOverlayRenderer()
    private let hitTestBridge = HitTestBridge()

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
        session.skScene.isPaused = true
    }

    /// Fully clears node mappings and returns the adapter to the idle state.
    public func reset() {
        stop()
        session.state = .idle
    }

    /// Stops and immediately restarts the adapter, rebuilding node mappings.
    public func restart() {
        stop()
        start()
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
        processDirtyQueue()
    }

    private func rebuildSceneGraph() {
        var visited: Set<UUID> = []
        for root in session.coreScene.rootObjects where !root.isDestroyed {
            attach(object: root, parentObject: nil, to: session.skScene, visited: &visited)
        }
        let removed = session.registry.removeUnvisited(excluding: visited)
        removed.forEach {
            overlayRenderer.removeOverlay(for: $0.objectID)
            $0.node.removeFromParent()
        }
    }

    private func attach(object: GameObject, parentObject: GameObject?, to parentNode: SKNode, visited: inout Set<UUID>) {
        let renderable = firstRenderable(from: object)
        let binding = session.registry.binding(for: object, viewComponent: renderable)
        visited.insert(binding.objectID)

        let desiredParentID = parentObject?.id

        if binding.node.parent !== parentNode {
            binding.node.removeFromParent()
            parentNode.addChild(binding.node)
        }
        if binding.parentObjectID != desiredParentID {
            binding.parentObjectID = desiredParentID
            session.dirtyQueue.markDirty(binding.objectID)
        }

        let isVisible = object.isEnabled && (renderable?.isEnabled ?? true)
        if binding.lastVisibility != isVisible {
            session.dirtyQueue.markDirty(binding.objectID)
        }

        if binding.lastTransform != object.localTransform {
            session.dirtyQueue.markDirty(binding.objectID)
        }

        if let spriteView = renderable as? SpriteView {
            let signature = SpriteViewSignature(
                textureName: spriteView.textureName,
                colorComponents: colorComponents(from: spriteView.color),
                size: spriteView.size,
                anchorPoint: spriteView.anchorPoint,
                zPosition: spriteView.zPosition
            )
            if binding.spriteSignature != signature {
                session.dirtyQueue.markDirty(binding.objectID)
            }
        }

        if binding.isNew {
            session.dirtyQueue.markDirty(binding.objectID)
            binding.isNew = false
        }

        for child in object.children where !child.isDestroyed {
            attach(object: child, parentObject: object, to: binding.node, visited: &visited)
        }
    }

    private func processDirtyQueue() {
        let ids = session.dirtyQueue.drain(maxItems: session.performanceBudget.maxSyncOpsPerFrame)
        guard !ids.isEmpty else { return }
        for id in ids {
            guard let binding = session.registry.binding(forID: id),
                  let object = binding.gameObject else { continue }
            binding.node.name = object.name

            let isVisible = object.isEnabled && (binding.viewComponent?.isEnabled ?? true)
            binding.node.isHidden = !isVisible
            binding.lastVisibility = isVisible

            if binding.lastTransform != object.localTransform {
                applyTransform(object.localTransform, to: binding.node)
                binding.lastTransform = object.localTransform
            }

            if let spriteView = binding.viewComponent as? SpriteView {
                let signature = SpriteViewSignature(
                    textureName: spriteView.textureName,
                    colorComponents: colorComponents(from: spriteView.color),
                    size: spriteView.size,
                    anchorPoint: spriteView.anchorPoint,
                    zPosition: spriteView.zPosition
                )
                if spriteView.textureName != nil && spriteView.resolvedTexture() == nil {
                    onDiagnostic?("Missing texture named \(spriteView.textureName ?? "")")
                }
                spriteView.update(node: binding.node)
                binding.spriteSignature = signature
            } else {
                binding.viewComponent?.update(node: binding.node)
            }

            if let config = session.debugOverlayConfig {
                overlayRenderer.renderOverlay(for: binding, in: session.skScene, config: config)
            }
        }
        session.cameraController?.update(using: session.registry, in: session.skScene)
    }

    private func applyTransform(_ transform: Transform2D, to node: SKNode) {
        node.position = CGPoint(x: transform.position.x, y: transform.position.y)
        node.zRotation = CGFloat(transform.rotation)
        node.xScale = CGFloat(transform.scale.x)
        node.yScale = CGFloat(transform.scale.y)
    }

    private func colorComponents(from color: SKColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        #if os(macOS)
        let converted = color.usingColorSpace(.deviceRGB) ?? color
        #else
        let converted = color
        #endif
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        converted.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private func tearDownBindings() {
        session.registry.allBindings().forEach { $0.node.removeFromParent() }
        session.registry.clear()
        session.dirtyQueue.clear()
        overlayRenderer.clear()
    }

    private func firstRenderable(from object: GameObject) -> SpriteKitRenderable? {
        object.components.compactMap { $0 as? SpriteKitRenderable }.first
    }

    // MARK: - Debug helpers

    public func node(for objectID: UUID) -> SKNode? {
        session.registry.binding(forID: objectID)?.node
    }

    public func setDebugOverlayConfig(_ config: DebugOverlayConfig?) {
        session.debugOverlayConfig = config
        if config == nil || config?.isEnabled == false {
            overlayRenderer.clear()
        }
    }

    public func configureCamera(_ config: CameraConfig) {
        let controller = session.cameraController ?? CameraController(config: config)
        controller.config = config
        session.cameraController = controller
    }

    public func hitTestObjectID(at point: CGPoint) -> UUID? {
        hitTestBridge.objectID(at: point, in: session.skScene, registry: session.registry)
    }
}
