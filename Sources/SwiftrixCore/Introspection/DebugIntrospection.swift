import Foundation

/// Utilities for inspecting scenes and game object trees.
public enum DebugIntrospection {
    public static func describeScene(_ scene: Scene) -> String {
        var lines: [String] = []
        for object in scene.rootObjects {
            lines.append(contentsOf: describeObject(object, indent: 0))
        }
        if let input = scene.inputSystem as? DefaultInputSystem {
            lines.append("Input axes: \(inputAxesSummary(input))")
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

    private static func inputAxesSummary(_ input: DefaultInputSystem) -> String {
        let axes = input.snapshotAxes()
        guard !axes.isEmpty else { return "none" }
        return axes.keys.sorted().joined(separator: ", ")
    }
}
