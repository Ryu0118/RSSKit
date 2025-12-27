// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "RSSKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "RSSKit", targets: ["RSSKit"]),
        .library(name: "RSS1Kit", targets: ["RSS1Kit"]),
        .library(name: "RSS2Kit", targets: ["RSS2Kit"]),
    ],
    targets: [
        .target(name: "RSSCore"),
        .target(name: "RSS2Kit", dependencies: ["RSSCore"]),
        .target(name: "RSS1Kit", dependencies: ["RSSCore"]),
        .target(name: "RSSKit", dependencies: ["RSS1Kit", "RSS2Kit"]),
        .testTarget(
            name: "RSSKitTests",
            dependencies: ["RSSKit", "RSSCore", "RSS1Kit", "RSS2Kit"],
            exclude: ["Fixtures"]
        ),
    ]
)
