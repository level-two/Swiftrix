// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftrixCore",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .library(name: "SwiftrixCore", targets: ["SwiftrixCore"])
    ],
    targets: [
        .target(
            name: "SwiftrixCore",
            path: "Sources/SwiftrixCore"
        ),
        .testTarget(
            name: "SwiftrixCoreTests",
            dependencies: ["SwiftrixCore"],
            path: "Tests/SwiftrixCoreTests"
        )
    ]
)
