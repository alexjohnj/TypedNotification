// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TypedNotification",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        .library(name: "TypedNotification", targets: ["TypedNotification"])
    ],
    targets: [
        .target(name: "TypedNotification", dependencies: [], path: "Sources/"),
        .testTarget(name: "TypedNotificationTests", dependencies: ["TypedNotification"], path: "Tests/")
    ]
)
