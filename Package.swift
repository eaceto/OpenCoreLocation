// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenCoreLocation",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OpenCoreLocation",
            targets: ["OpenCoreLocation"])
    ],
    targets: [
        .target(
            name: "OpenCoreLocation"),
        .testTarget(
            name: "OpenCoreLocationTests",
            dependencies: ["OpenCoreLocation"]
        )
    ]
)
