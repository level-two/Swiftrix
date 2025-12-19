import Foundation

/// Drives a `Scene` using a fixed timestep for deterministic systems (e.g., physics)
/// and a variable timestep for per-frame updates.
///
/// Hosts typically call `tick(deltaTime:)` once per rendered frame.
public final class GameLoop {
    private let scene: Scene
    private var lastFrameTime: TimeInterval?
    private var accumulator: TimeInterval = 0
    private let fixedDeltaTime: TimeInterval

    public init(scene: Scene, fixedDeltaTime: TimeInterval = 1.0 / 60.0) {
        self.scene = scene
        self.fixedDeltaTime = fixedDeltaTime
    }

    /// Steps the loop by the provided delta time.
    ///
    /// This method is deterministic given the same input stream and tick deltas.
    public func tick(deltaTime: TimeInterval) {
        defer { lastFrameTime = (lastFrameTime ?? 0) + deltaTime }
        accumulator += deltaTime

        while accumulator >= fixedDeltaTime {
            scene.fixedUpdate(fixedDeltaTime: fixedDeltaTime)
            accumulator -= fixedDeltaTime
        }

        scene.update(deltaTime: deltaTime)
        scene.draw()
    }
}
