// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftrixCore",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .library(name: "SwiftrixCore", targets: ["SwiftrixCore"]),
        .library(name: "SwiftrixSpriteKitRendering", targets: ["SwiftrixSpriteKitRendering"])
    ],
    targets: [
        .target(
            name: "SwiftrixCore",
            path: "Sources/SwiftrixCore"
        ),
        .target(
            name: "SwiftrixSpriteKitRendering",
            dependencies: ["SwiftrixCore"],
            path: "Sources/SwiftrixSpriteKitRendering"
        ),
        .testTarget(
            name: "SwiftrixCoreTests",
            dependencies: ["SwiftrixCore"],
            path: "Tests/SwiftrixCoreTests"
        ),
        .testTarget(
            name: "SwiftrixSpriteKitRenderingTests",
            dependencies: ["SwiftrixSpriteKitRendering", "SwiftrixCore"],
            path: "Tests/SwiftrixSpriteKitRenderingTests"
        )
    ]
)
