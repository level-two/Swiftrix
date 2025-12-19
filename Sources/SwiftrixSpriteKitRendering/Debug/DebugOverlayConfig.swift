import Foundation
import SpriteKit

/// Configuration for opt-in debug overlays rendered on top of bound nodes.
public struct DebugOverlayConfig {
    public var isEnabled: Bool
    public var showBounds: Bool
    public var showAnchors: Bool
    public var lineColor: SKColor
    public var lineWidth: CGFloat

    public init(
        isEnabled: Bool = false,
        showBounds: Bool = true,
        showAnchors: Bool = false,
        lineColor: SKColor = .magenta,
        lineWidth: CGFloat = 1.0
    ) {
        self.isEnabled = isEnabled
        self.showBounds = showBounds
        self.showAnchors = showAnchors
        self.lineColor = lineColor
        self.lineWidth = lineWidth
    }
}
