// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "clipboard",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "clipboard", targets: ["clipboard"])
    ],
    dependencies: [
        .package(url: "https://github.com/IngmarStein/CommandLineKit", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "ClipboardCore",
            dependencies: ["CommandLineKit"],
            path: "Sources/ClipboardCore"),
        .target(
            name: "clipboard",
            dependencies: ["ClipboardCore"],
            path: "Sources/clipboard"),
        .testTarget(
            name: "clipboardTests",
            dependencies: ["ClipboardCore"]),
    ]
)
