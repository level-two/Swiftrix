import Foundation

/// Utilities for inspecting scenes and game object trees.
public enum DebugIntrospection {
    public static func describeScene(_ scene: Scene) -> String {
        var lines: [String] = []
        for object in scene.rootObjects {
            lines.append(contentsOf: describeObject(object, indent: 0))
        }
        return lines.joined(separator: "\n")
    }

    public static func describeObject(_ object: GameObject, indent: Int) -> [String] {
        let prefix = String(repeating: "  ", count: indent)
        var lines = ["\(prefix)- \(object.name) [\(object.components.count) components]"]
        for child in object.children {
            lines.append(contentsOf: describeObject(child, indent: indent + 1))
        }
        return lines
    }
}
