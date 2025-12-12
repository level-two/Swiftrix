public extension GameObject {
    var position: Vector2 {
        get { localTransform.position }
        set {
            var transform = localTransform
            transform.position = newValue
            localTransform = transform
        }
    }

    var rotation: Double {
        get { localTransform.rotation }
        set {
            var transform = localTransform
            transform.rotation = newValue
            localTransform = transform
        }
    }

    var scale: Vector2 {
        get { localTransform.scale }
        set {
            var transform = localTransform
            transform.scale = newValue
            localTransform = transform
        }
    }

    var globalPosition: Vector2 { globalTransform.position }
    var globalRotation: Double { globalTransform.rotation }
    var globalScale: Vector2 { globalTransform.scale }
}
