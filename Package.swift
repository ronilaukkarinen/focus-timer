// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "focus-timer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "focus-timer",
            path: "Sources"
        )
    ]
)
