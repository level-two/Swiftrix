import Foundation

/// Lightweight bridge that maps host lifecycle events into adapter pause/resume.
public final class HostLifecycleBridge {
    private weak var adapter: SpriteKitSceneAdapter?

    public init(adapter: SpriteKitSceneAdapter) {
        self.adapter = adapter
    }

    public func applicationDidEnterBackground() {
        adapter?.pause()
    }

    public func applicationWillEnterForeground() {
        adapter?.resume()
    }
}
