// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SampleApp",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "SampleApp",
            dependencies: ["OpenCoreLocation"]
        )
    ]
)
