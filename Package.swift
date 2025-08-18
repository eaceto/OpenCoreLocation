// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenCoreLocation",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "OpenCoreLocation",
            targets: ["OpenCoreLocation"]),
        .executable(
            name: "LocationAccuracyExample",
            targets: ["LocationAccuracyExample"]),
        .executable(
            name: "DistanceFilterDemo", 
            targets: ["DistanceFilterDemo"]),
        .executable(
            name: "LocationUtilsDemo",
            targets: ["LocationUtilsDemo"]),
        .executable(
            name: "RegionMonitoringExample",
            targets: ["RegionMonitoringExample"])
    ],
    targets: [
        .target(
            name: "OpenCoreLocation"),
        .testTarget(
            name: "OpenCoreLocationTests",
            dependencies: ["OpenCoreLocation"]
        ),
        .executableTarget(
            name: "LocationAccuracyExample",
            dependencies: ["OpenCoreLocation"],
            path: "Examples",
            sources: ["LocationAccuracyExample.swift"]),
        .executableTarget(
            name: "DistanceFilterDemo",
            dependencies: ["OpenCoreLocation"],
            path: "Examples",
            sources: ["DistanceFilterDemo.swift"]),
        .executableTarget(
            name: "LocationUtilsDemo",
            dependencies: ["OpenCoreLocation"],
            path: "Examples",
            sources: ["LocationUtilsDemo.swift"]),
        .executableTarget(
            name: "RegionMonitoringExample",
            dependencies: ["OpenCoreLocation"],
            path: "Examples",
            sources: ["RegionMonitoringExample.swift"])
    ]
)
