import Foundation

/// Drives a scene using a fixed timestep for deterministic systems and a variable update for scripts.
public final class GameLoop {
    private let scene: Scene
    private var lastFrameTime: TimeInterval?
    private var accumulator: TimeInterval = 0
    private let fixedDeltaTime: TimeInterval

    public init(scene: Scene, fixedDeltaTime: TimeInterval = 1.0 / 60.0) {
        self.scene = scene
        self.fixedDeltaTime = fixedDeltaTime
    }

    /// Steps the game loop by the provided delta time. Intended for tests/tools.
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
