// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusBuild",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "FocusBuild", targets: ["FocusBuild"])
    ],
    targets: [
        .executableTarget(name: "FocusBuild", path: "Sources")
    ]
)
