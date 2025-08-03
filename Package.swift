// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSRealTimeCommunicationFramework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RealTimeCommunication",
            targets: ["RealTimeCommunication"]),
        .library(
            name: "RealTimeCommunicationCore",
            targets: ["RealTimeCommunicationCore"]),
        .library(
            name: "RealTimeCommunicationAnalytics",
            targets: ["RealTimeCommunicationAnalytics"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RealTimeCommunication",
            dependencies: [
                "RealTimeCommunicationCore",
                "RealTimeCommunicationAnalytics",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            path: "Sources/Communication"),
        .target(
            name: "RealTimeCommunicationCore",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/Core"),
        .target(
            name: "RealTimeCommunicationAnalytics",
            dependencies: [
                "RealTimeCommunicationCore",
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/Analytics"),
        .testTarget(
            name: "RealTimeCommunicationTests",
            dependencies: [
                "RealTimeCommunication",
                "RealTimeCommunicationCore",
                "RealTimeCommunicationAnalytics"
            ],
            path: "Tests/RealTimeCommunicationTests"),
        .testTarget(
            name: "RealTimeCommunicationCoreTests",
            dependencies: ["RealTimeCommunicationCore"],
            path: "Tests/RealTimeCommunicationCoreTests"),
        .testTarget(
            name: "RealTimeCommunicationAnalyticsTests",
            dependencies: ["RealTimeCommunicationAnalytics"],
            path: "Tests/RealTimeCommunicationAnalyticsTests"),
        .testTarget(
            name: "RealTimeCommunicationPerformanceTests",
            dependencies: ["RealTimeCommunication"],
            path: "Tests/RealTimeCommunicationPerformanceTests"),
    ]
) 