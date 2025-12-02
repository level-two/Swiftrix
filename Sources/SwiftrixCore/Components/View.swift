import Foundation

/// Visual representation of a game object. Host apps provide rendering.
public protocol View: Component {
    func draw()
}

public extension View {
    func draw() {}
}
