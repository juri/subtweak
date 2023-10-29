// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Subtweak",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "SubtweakLib",
            targets: [
                "SubEdit",
            ]
        ),
        .executable(
            name: "subtweak",
            targets: [
                "CLI",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.13.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "CLI",
            dependencies: [
                "SRTParse",
                "SubEdit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Subtitles"
        ),
        .target(
            name: "SubEdit",
            dependencies: [
                "SRTParse",
                "Subtitles",
            ]
        ),
        .target(
            name: "SRTParse",
            dependencies: [
                "Subtitles",
                .product(name: "Parsing", package: "swift-parsing"),
            ]
        ),
        .testTarget(
            name: "SRTParseTests",
            dependencies: [
                "SRTParse",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
        .testTarget(
            name: "SubtweakTests",
            dependencies: [
                "SRTParse",
                "SubEdit",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
