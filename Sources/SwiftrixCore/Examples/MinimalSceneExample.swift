import Foundation

/// A tiny example showing how to assemble a scene programmatically.
public enum MinimalSceneExample {
    public static func buildScene() -> Scene {
        let scene = DefaultScene()
        let player = DefaultGameObject(name: "Player")
        let script = SimpleMoveScript()
        player.addComponent(script)
        scene.addRootObject(player)
        return scene
    }
}

private final class SimpleMoveScript: Script {
    weak public var gameObject: GameObject?
    public var isEnabled: Bool = true
    private var totalTime: TimeInterval = 0

    public func update(deltaTime: TimeInterval) {
        totalTime += deltaTime
        if var transform = gameObject?.localTransform {
            transform.position.x += totalTime
            gameObject?.localTransform = transform
        }
    }
}
