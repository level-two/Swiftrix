import Foundation

/// Utility functions to traverse a scene's object hierarchy.
public enum SceneGraphTraversal {
    public static func depthFirstUpdate(objects: [GameObject], deltaTime: TimeInterval) {
        for object in objects where object.isEnabled && !object.isDestroyed {
            object.update(deltaTime: deltaTime)
        }
    }

    public static func depthFirstFixedUpdate(objects: [GameObject], fixedDeltaTime: TimeInterval) {
        for object in objects where object.isEnabled && !object.isDestroyed {
            if let fixed = object as? FixedUpdatable {
                fixed.fixedUpdate(fixedDeltaTime: fixedDeltaTime)
            }
            for child in object.children {
                depthFirstFixedUpdate(objects: [child], fixedDeltaTime: fixedDeltaTime)
            }
        }
    }

    public static func depthFirstDraw(objects: [GameObject]) {
        for object in objects where object.isEnabled && !object.isDestroyed {
            let views = object.components.compactMap { $0 as? View }
            for view in views where view.isEnabled {
                view.draw()
            }
            depthFirstDraw(objects: object.children)
        }
    }

    public static func dispatchControlEvents(_ events: [ControlEvent], to objects: [GameObject]) {
        guard !events.isEmpty else { return }
        for object in objects where object.isEnabled && !object.isDestroyed {
            let controls = object.components.compactMap { $0 as? ControlComponent }
            for control in controls where control.isEnabled {
                events.forEach { control.handle(event: $0) }
            }
            dispatchControlEvents(events, to: object.children)
        }
    }
}
