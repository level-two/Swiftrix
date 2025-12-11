public extension GameObject {
    public var position: Vector2 {
        get { localTransform.position }
        set {
            var transform = localTransform
            transform.position = newValue
            localTransform = transform
        }
    }

    public var rotation: Double {
        get { localTransform.rotation }
        set {
            var transform = localTransform
            transform.rotation = newValue
            localTransform = transform
        }
    }

    public var scale: Vector2 {
        get { localTransform.scale }
        set {
            var transform = localTransform
            transform.scale = newValue
            localTransform = transform
        }
    }

    public var globalPosition: Vector2 { globalTransform.position }
    public var globalRotation: Double { globalTransform.rotation }
    public var globalScale: Vector2 { globalTransform.scale }
}
