import XCTest
import SpriteKit
import SwiftrixCore
@testable import SwiftrixSpriteKitRendering

final class DebugOverlayRendererTests: XCTestCase {
    private func assertRect(_ actual: CGRect, equals expected: CGRect, accuracy: CGFloat = 0.0001, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.origin.x, expected.origin.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.origin.y, expected.origin.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.size.width, expected.size.width, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.size.height, expected.size.height, accuracy: accuracy, file: file, line: line)
    }

    private func sceneSpaceBounds(node: SKNode, in scene: SKScene) -> CGRect {
        let parentSpaceBounds = node.calculateAccumulatedFrame()
        guard let parent = node.parent else { return parentSpaceBounds }
        if parent === scene { return parentSpaceBounds }

        let corners = [
            CGPoint(x: parentSpaceBounds.minX, y: parentSpaceBounds.minY),
            CGPoint(x: parentSpaceBounds.minX, y: parentSpaceBounds.maxY),
            CGPoint(x: parentSpaceBounds.maxX, y: parentSpaceBounds.minY),
            CGPoint(x: parentSpaceBounds.maxX, y: parentSpaceBounds.maxY),
        ]

        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude

        for corner in corners {
            let world = parent.convert(corner, to: scene)
            minX = min(minX, world.x)
            minY = min(minY, world.y)
            maxX = max(maxX, world.x)
            maxY = max(maxY, world.y)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func testDebugOverlayUsesSceneSpaceForBoundsAndAnchorUnderNestedTransforms() throws {
        let scene = SKScene(size: CGSize(width: 400, height: 400))
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let parent = SKNode()
        parent.position = CGPoint(x: 100, y: -40)
        parent.xScale = 2.0
        parent.yScale = 0.5
        parent.zRotation = .pi / 8
        scene.addChild(parent)

        let object = GameObject(name: "sprite")
        let spriteView = SpriteView(color: .green, size: CGSize(width: 10, height: 20), anchor: Vector2(x: 0.0, y: 0.0))
        let registry = NodeBindingRegistry()
        let binding = registry.binding(for: object, viewComponent: spriteView)

        binding.node.position = CGPoint(x: 7, y: 11)
        parent.addChild(binding.node)

        let renderer = DebugOverlayRenderer()
        let config = DebugOverlayConfig(isEnabled: true, showBounds: true, showAnchors: true, lineColor: .magenta, lineWidth: 1.0)
        renderer.renderOverlay(for: binding, in: scene, config: config)

        let overlayContainer = try XCTUnwrap(scene.children.first { $0 !== parent })
        XCTAssertEqual(overlayContainer.children.count, 2)

        let shapes = overlayContainer.children.compactMap { $0 as? SKShapeNode }
        XCTAssertEqual(shapes.count, 2)

        let boundsShape = try XCTUnwrap(shapes.first { $0.lineWidth > 0 })
        let anchorShape = try XCTUnwrap(shapes.first { $0.lineWidth == 0 })

        let expectedBounds = sceneSpaceBounds(node: binding.node, in: scene)
        let actualBounds = try XCTUnwrap(boundsShape.path).boundingBox
        assertRect(actualBounds, equals: expectedBounds)

        let expectedAnchor = parent.convert(binding.node.position, to: scene)
        let actualAnchorRect = try XCTUnwrap(anchorShape.path).boundingBox
        XCTAssertEqual(actualAnchorRect.midX, expectedAnchor.x, accuracy: 0.0001)
        XCTAssertEqual(actualAnchorRect.midY, expectedAnchor.y, accuracy: 0.0001)
    }
}
