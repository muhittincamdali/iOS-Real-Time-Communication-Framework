// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealTimeCommunication",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "RealTimeCommunication",
            targets: ["RealTimeCommunication"]),
        .library(
            name: "RealTimeCommunicationCore",
            targets: ["RealTimeCommunicationCore"]),
        .library(
            name: "RealTimeCommunicationWebSocket",
            targets: ["RealTimeCommunicationWebSocket"]),
        .library(
            name: "RealTimeCommunicationPush",
            targets: ["RealTimeCommunicationPush"]),
        .library(
            name: "RealTimeCommunicationQueue",
            targets: ["RealTimeCommunicationQueue"]),
        .library(
            name: "RealTimeCommunicationAnalytics",
            targets: ["RealTimeCommunicationAnalytics"]),
        .library(
            name: "RealTimeCommunicationConnection",
            targets: ["RealTimeCommunicationConnection"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "RealTimeCommunicationCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics")
            ],
            path: "Sources/Core"),
        .target(
            name: "RealTimeCommunicationWebSocket",
            dependencies: [
                "RealTimeCommunicationCore",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio")
            ],
            path: "Sources/WebSocket"),
        .target(
            name: "RealTimeCommunicationPush",
            dependencies: [
                "RealTimeCommunicationCore"
            ],
            path: "Sources/PushNotifications"),
        .target(
            name: "RealTimeCommunicationQueue",
            dependencies: [
                "RealTimeCommunicationCore"
            ],
            path: "Sources/MessageQueue"),
        .target(
            name: "RealTimeCommunicationAnalytics",
            dependencies: [
                "RealTimeCommunicationCore",
                .product(name: "Metrics", package: "swift-metrics")
            ],
            path: "Sources/Analytics"),
        .target(
            name: "RealTimeCommunicationConnection",
            dependencies: [
                "RealTimeCommunicationCore",
                "RealTimeCommunicationWebSocket",
                "RealTimeCommunicationPush"
            ],
            path: "Sources/Connection"),
        .target(
            name: "RealTimeCommunication",
            dependencies: [
                "RealTimeCommunicationCore",
                "RealTimeCommunicationWebSocket",
                "RealTimeCommunicationPush",
                "RealTimeCommunicationQueue",
                "RealTimeCommunicationAnalytics",
                "RealTimeCommunicationConnection"
            ]),
        .testTarget(
            name: "RealTimeCommunicationTests",
            dependencies: [
                "RealTimeCommunication",
                "RealTimeCommunicationCore",
                "RealTimeCommunicationWebSocket",
                "RealTimeCommunicationPush",
                "RealTimeCommunicationQueue",
                "RealTimeCommunicationAnalytics",
                "RealTimeCommunicationConnection"
            ],
            path: "Tests"),
        .testTarget(
            name: "RealTimeCommunicationCoreTests",
            dependencies: ["RealTimeCommunicationCore"],
            path: "Tests/Unit/Core"),
        .testTarget(
            name: "RealTimeCommunicationWebSocketTests",
            dependencies: ["RealTimeCommunicationWebSocket"],
            path: "Tests/Unit/WebSocket"),
        .testTarget(
            name: "RealTimeCommunicationPushTests",
            dependencies: ["RealTimeCommunicationPush"],
            path: "Tests/Unit/PushNotifications"),
        .testTarget(
            name: "RealTimeCommunicationQueueTests",
            dependencies: ["RealTimeCommunicationQueue"],
            path: "Tests/Unit/MessageQueue"),
        .testTarget(
            name: "RealTimeCommunicationAnalyticsTests",
            dependencies: ["RealTimeCommunicationAnalytics"],
            path: "Tests/Unit/Analytics"),
        .testTarget(
            name: "RealTimeCommunicationConnectionTests",
            dependencies: ["RealTimeCommunicationConnection"],
            path: "Tests/Unit/Connection"),
        .testTarget(
            name: "RealTimeCommunicationIntegrationTests",
            dependencies: ["RealTimeCommunication"],
            path: "Tests/Integration"),
        .testTarget(
            name: "RealTimeCommunicationPerformanceTests",
            dependencies: ["RealTimeCommunication"],
            path: "Tests/Performance"),
        .testTarget(
            name: "RealTimeCommunicationSecurityTests",
            dependencies: ["RealTimeCommunication"],
            path: "Tests/Security")
    ]
) 