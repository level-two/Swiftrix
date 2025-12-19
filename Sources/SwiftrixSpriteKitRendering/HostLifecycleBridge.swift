import Foundation

/// Lightweight bridge that maps host lifecycle events into SpriteKitScene pause/resume.
public final class HostLifecycleBridge {
    private weak var scene: SpriteKitScene?

    /// Creates a lifecycle bridge for the given scene.
    public init(scene: SpriteKitScene) {
        self.scene = scene
    }

    public func applicationDidEnterBackground() {
        scene?.pause()
    }

    public func applicationWillEnterForeground() {
        scene?.resume()
    }
}
