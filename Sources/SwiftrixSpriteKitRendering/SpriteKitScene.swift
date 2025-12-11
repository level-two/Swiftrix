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

/// SpriteKit-backed scene that subclasses the core `Scene` and mirrors the
/// game object graph into an `SKScene`, driven by a display-linked clock.
public final class SpriteKitScene: Scene {
    public private(set) var state: SceneAdapterState = .idle
    public let skScene: SKScene
    public var performanceBudget: PerformanceBudget
    public var onDiagnostic: ((String) -> Void)?
    public var debugOverlayConfig: DebugOverlayConfig?
    public var cameraController: CameraController?

    private let fixedDeltaTime: TimeInterval
    private let registry: NodeBindingRegistry
    private let dirtyQueue: DirtySyncQueue
    private let overlayRenderer = DebugOverlayRenderer()
    private let hitTestBridge = HitTestBridge()
    private let displayLinkDriver: DisplayLinkDriving
    private var gameLoop: GameLoop?

    public init(
        skScene: SKScene = SKScene(),
        displayLinkDriver: DisplayLinkDriving? = nil,
        fixedDeltaTime: TimeInterval = 1.0 / 60.0,
        performanceBudget: PerformanceBudget = .default,
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        self.skScene = skScene
        self.performanceBudget = performanceBudget
        self.fixedDeltaTime = fixedDeltaTime
        self.registry = NodeBindingRegistry()
        self.dirtyQueue = DirtySyncQueue()
        self.displayLinkDriver = displayLinkDriver ?? CADisplayLinkDriver()
        super.init(eventBus: eventBus, inputSystem: inputSystem, physicsWorld: physicsWorld)
        self.gameLoop = GameLoop(scene: self, fixedDeltaTime: fixedDeltaTime)
        self.displayLinkDriver.onTick = { [weak self] delta in
            self?.tick(deltaTime: delta)
        }
        self.skScene.scaleMode = .resizeFill
    }

    // MARK: - Lifecycle

    public func start() {
        guard state == .idle || state == .stopped else { return }
        state = .running
        rebuildSceneGraph()
        processDirtyQueue()
        displayLinkDriver.start()
        skScene.isPaused = false
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        displayLinkDriver.pause()
        skScene.isPaused = true
    }

    public func resume() {
        guard state == .paused else { return }
        state = .running
        skScene.isPaused = false
        displayLinkDriver.resume()
    }

    public func stop() {
        guard state != .stopped else { return }
        displayLinkDriver.stop()
        tearDownBindings()
        state = .stopped
        skScene.isPaused = true
    }

    /// Fully clears node mappings and returns the scene to the idle state.
    public func reset() {
        stop()
        state = .idle
    }

    /// Stops and immediately restarts, rebuilding node mappings.
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
        guard state == .running else { return }
        gameLoop?.tick(deltaTime: deltaTime)
        rebuildSceneGraph()
        processDirtyQueue()
    }

    private func rebuildSceneGraph() {
        var visited: Set<UUID> = []
        for root in rootObjects where !root.isDestroyed {
            attach(object: root, parentObject: nil, to: skScene, visited: &visited)
        }
        let removed = registry.removeUnvisited(excluding: visited)
        removed.forEach {
            overlayRenderer.removeOverlay(for: $0.objectID)
            $0.node.removeFromParent()
        }
    }

    private func attach(object: GameObject, parentObject: GameObject?, to parentNode: SKNode, visited: inout Set<UUID>) {
        let renderable = firstRenderable(from: object)
        let binding = registry.binding(for: object, viewComponent: renderable)
        visited.insert(binding.objectID)

        let desiredParentID = parentObject?.id

        if binding.node.parent !== parentNode {
            binding.node.removeFromParent()
            parentNode.addChild(binding.node)
        }
        if binding.parentObjectID != desiredParentID {
            binding.parentObjectID = desiredParentID
            dirtyQueue.markDirty(binding.objectID)
        }

        let isVisible = object.isEnabled && (renderable?.isEnabled ?? true)
        if binding.lastVisibility != isVisible {
            dirtyQueue.markDirty(binding.objectID)
        }

        if binding.lastTransform != object.localTransform {
            dirtyQueue.markDirty(binding.objectID)
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
                dirtyQueue.markDirty(binding.objectID)
            }
        }

        if binding.isNew {
            dirtyQueue.markDirty(binding.objectID)
            binding.isNew = false
        }

        for child in object.children where !child.isDestroyed {
            attach(object: child, parentObject: object, to: binding.node, visited: &visited)
        }
    }

    private func processDirtyQueue() {
        let ids = dirtyQueue.drain(maxItems: performanceBudget.maxSyncOpsPerFrame)
        guard !ids.isEmpty else { return }
        for id in ids {
            guard let binding = registry.binding(forID: id),
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

            if let config = debugOverlayConfig {
                overlayRenderer.renderOverlay(for: binding, in: skScene, config: config)
            }
        }
        cameraController?.update(using: registry, in: skScene)
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
        registry.allBindings().forEach { $0.node.removeFromParent() }
        registry.clear()
        dirtyQueue.clear()
        overlayRenderer.clear()
    }

    private func firstRenderable(from object: GameObject) -> SpriteKitRenderable? {
        object.components.compactMap { $0 as? SpriteKitRenderable }.first
    }

    // MARK: - Debug helpers

    public func node(for objectID: UUID) -> SKNode? {
        registry.binding(forID: objectID)?.node
    }

    public func setDebugOverlayConfig(_ config: DebugOverlayConfig?) {
        debugOverlayConfig = config
        if config == nil || config?.isEnabled == false {
            overlayRenderer.clear()
        }
    }

    public func configureCamera(_ config: CameraConfig) {
        let controller = cameraController ?? CameraController(config: config)
        controller.config = config
        cameraController = controller
    }

    public func hitTestObjectID(at point: CGPoint) -> UUID? {
        hitTestBridge.objectID(at: point, in: skScene, registry: registry)
    }
}
