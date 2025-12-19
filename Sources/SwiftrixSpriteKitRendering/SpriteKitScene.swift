import Foundation
import SpriteKit
import SwiftrixCore

/// Lifecycle state of a `SpriteKitScene` adapter.
public enum SceneAdapterState {
    /// Constructed but not yet started (no bindings).
    case idle
    /// Actively running and ticking the Core loop.
    case running
    /// Paused (no ticks).
    case paused
    /// Stopped (bindings cleared, no ticks).
    case stopped
}

/// Performance budget configuration. When `maxSyncOpsPerFrame` is set,
/// sync work is spread across multiple frames to avoid hitches.
public struct PerformanceBudget {
    /// Limits how many bindings can be synchronized per frame. `nil` means “no limit”.
    public var maxSyncOpsPerFrame: Int?

    public init(maxSyncOpsPerFrame: Int? = nil) {
        self.maxSyncOpsPerFrame = maxSyncOpsPerFrame
    }

    public static let `default` = PerformanceBudget(maxSyncOpsPerFrame: nil)
}

/// SpriteKit-backed `SKScene` that owns a core `Scene` instance and mirrors
/// its game object graph into the SpriteKit node tree.
///
/// Subclass this type to create a concrete “scene asset” that wires up your
/// prefabs and controllers inside `bootstrapScene()`.
open class SpriteKitScene: SKScene {
    /// The engine core scene. This holds your game state and logic.
    public let coreScene: Scene
    /// Current lifecycle state for adapter control and diagnostics.
    public private(set) var state: SceneAdapterState = .idle
    /// Controls how aggressively Core → SpriteKit synchronization is performed.
    public var performanceBudget: PerformanceBudget
    /// Optional diagnostics callback (e.g., missing textures).
    public var onDiagnostic: ((String) -> Void)?
    /// Debug overlay configuration. Use `setDebugOverlayConfig(_:)` to update.
    public var debugOverlayConfig: DebugOverlayConfig?
    /// Optional camera controller driven after sync each frame.
    public var cameraController: CameraController?

    private let fixedDeltaTime: TimeInterval
    private let registry: NodeBindingRegistry
    private let dirtyQueue: DirtySyncQueue
    private let overlayRenderer = DebugOverlayRenderer()
    private let hitTestBridge = HitTestBridge()
    private let displayLinkDriver: DisplayLinkDriving?
    private var gameLoop: GameLoop?
    private var lastUpdateTime: TimeInterval?
    private var didBootstrapScene = false

    public init(
        coreScene: Scene,
        size: CGSize = CGSize(width: 640, height: 480),
        displayLinkDriver: DisplayLinkDriving? = nil,
        fixedDeltaTime: TimeInterval = 1.0 / 60.0,
        performanceBudget: PerformanceBudget = .default
    ) {
        self.coreScene = coreScene
        self.performanceBudget = performanceBudget
        self.fixedDeltaTime = fixedDeltaTime
        self.registry = NodeBindingRegistry()
        self.dirtyQueue = DirtySyncQueue()
        self.displayLinkDriver = displayLinkDriver
        super.init(size: size)
        self.gameLoop = GameLoop(scene: coreScene, fixedDeltaTime: fixedDeltaTime)
        self.displayLinkDriver?.onTick = { [weak self] delta in
            self?.tick(deltaTime: delta)
        }
        self.scaleMode = .resizeFill
    }

    public convenience init(
        size: CGSize = CGSize(width: 640, height: 480),
        displayLinkDriver: DisplayLinkDriving? = nil,
        fixedDeltaTime: TimeInterval = 1.0 / 60.0,
        performanceBudget: PerformanceBudget = .default,
        eventBus: EventBus = DefaultEventBus(),
        inputSystem: InputSystem? = nil,
        physicsWorld: PhysicsWorld = DefaultPhysicsWorld()
    ) {
        let coreScene = Scene(eventBus: eventBus, inputSystem: inputSystem, physicsWorld: physicsWorld)
        self.init(
            coreScene: coreScene,
            size: size,
            displayLinkDriver: displayLinkDriver,
            fixedDeltaTime: fixedDeltaTime,
            performanceBudget: performanceBudget
        )
    }

    required public init?(coder: NSCoder) {
        self.coreScene = Scene()
        self.performanceBudget = .default
        self.fixedDeltaTime = 1.0 / 60.0
        self.registry = NodeBindingRegistry()
        self.dirtyQueue = DirtySyncQueue()
        self.displayLinkDriver = nil
        super.init(coder: coder)
        self.gameLoop = GameLoop(scene: coreScene, fixedDeltaTime: fixedDeltaTime)
    }

    // MARK: - Lifecycle

    /// Starts the adapter:
    /// - calls `bootstrapScene()` once (first start only)
    /// - creates initial Core → SpriteKit bindings
    /// - begins ticking via `displayLinkDriver` (if provided) or `SKScene.update(_:)`
    open func start() {
        guard state == .idle || state == .stopped else { return }
        if !didBootstrapScene {
            didBootstrapScene = true
            bootstrapScene()
        }
        state = .running
        rebuildSceneGraph()
        processDirtyQueue()
        displayLinkDriver?.start()
        isPaused = false
        lastUpdateTime = nil
    }

    /// Pauses ticking and SpriteKit updates (bindings are retained).
    open func pause() {
        guard state == .running else { return }
        state = .paused
        displayLinkDriver?.pause()
        isPaused = true
    }

    /// Resumes ticking after `pause()`.
    open func resume() {
        guard state == .paused else { return }
        state = .running
        isPaused = false
        displayLinkDriver?.resume()
    }

    /// Stops ticking and clears all bindings and overlays.
    open func stop() {
        guard state != .stopped else { return }
        displayLinkDriver?.stop()
        tearDownBindings()
        state = .stopped
        isPaused = true
        lastUpdateTime = nil
    }

    /// Fully clears node mappings and returns the scene to the idle state.
    open func reset() {
        stop()
        state = .idle
    }

    /// Stops and immediately restarts, rebuilding node mappings.
    open func restart() {
        stop()
        start()
    }

    /// Manual stepping helper used by tests or tooling.
    open func step(deltaTime: TimeInterval) {
        tick(deltaTime: deltaTime)
    }

    /// Override to populate the Core scene with prefabs and controllers.
    open func bootstrapScene() {}

    // MARK: - SKScene hooks

    open override func update(_ currentTime: TimeInterval) {
        guard displayLinkDriver == nil else { return }
        guard state == .running else { return }
        defer { lastUpdateTime = currentTime }
        guard let lastTime = lastUpdateTime else { return }
        let delta = currentTime - lastTime
        tick(deltaTime: delta)
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
        for root in coreScene.rootObjects where !root.isDestroyed {
            attach(object: root, parentObject: nil, to: self, visited: &visited, ancestorVisible: true)
        }
        let removed = registry.removeUnvisited(excluding: visited)
        removed.forEach {
            overlayRenderer.removeOverlay(for: $0.objectID)
            $0.node.removeFromParent()
        }
    }

    private func attach(
        object: GameObject,
        parentObject: GameObject?,
        to parentNode: SKNode,
        visited: inout Set<UUID>,
        ancestorVisible: Bool
    ) {
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

        let isVisible = ancestorVisible && object.isEnabled && (renderable?.isEnabled ?? true)
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
                zPosition: spriteView.zPosition,
                animationNonce: spriteView.currentAnimationNonce
            )
            if binding.spriteSignature != signature {
                dirtyQueue.markDirty(binding.objectID)
            }
        }

        if binding.isNew {
            dirtyQueue.markDirty(binding.objectID)
            binding.isNew = false
        }

        let nextAncestorVisible = ancestorVisible && object.isEnabled
        for child in object.children where !child.isDestroyed {
            attach(object: child, parentObject: object, to: binding.node, visited: &visited, ancestorVisible: nextAncestorVisible)
        }
    }

    private func processDirtyQueue() {
        let ids = dirtyQueue.drain(maxItems: performanceBudget.maxSyncOpsPerFrame)
        guard !ids.isEmpty else { return }
        for id in ids {
            guard let binding = registry.binding(forID: id),
                  let object = binding.gameObject else { continue }
            binding.node.name = object.name

            let ancestorVisible = ancestorsVisible(binding: binding)
            let isVisible = ancestorVisible && object.isEnabled && (binding.viewComponent?.isEnabled ?? true)
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
                zPosition: spriteView.zPosition,
                animationNonce: spriteView.currentAnimationNonce
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
                overlayRenderer.renderOverlay(for: binding, in: self, config: config)
            }
        }
        cameraController?.update(using: registry, in: self)
    }

    private func ancestorsVisible(binding: NodeBinding) -> Bool {
        var currentParentID = binding.parentObjectID
        while let parentID = currentParentID {
            guard let parentBinding = registry.binding(forID: parentID),
                  let parentObject = parentBinding.gameObject else { return false }
            if !parentObject.isEnabled { return false }
            currentParentID = parentBinding.parentObjectID
        }
        return true
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

    /// Returns the bound SpriteKit node for a Core object id, if currently mapped.
    public func node(for objectID: UUID) -> SKNode? {
        registry.binding(forID: objectID)?.node
    }

    /// Enables/disables debug overlay rendering.
    public func setDebugOverlayConfig(_ config: DebugOverlayConfig?) {
        debugOverlayConfig = config
        if config == nil || config?.isEnabled == false {
            overlayRenderer.clear()
        }
    }

    /// Creates or updates the camera controller configuration.
    public func configureCamera(_ config: CameraConfig) {
        let controller = cameraController ?? CameraController(config: config)
        controller.config = config
        cameraController = controller
    }

    /// Returns the Core object id for the top-most hit-tested SpriteKit node, if any.
    public func hitTestObjectID(at point: CGPoint) -> UUID? {
        hitTestBridge.objectID(at: point, in: self, registry: registry)
    }
}
