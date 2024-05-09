// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependo",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "Dependo", targets: ["Dependo"]),
    ],
    targets: [
        .target(name: "Dependo"),
        .testTarget(name: "DependoTests", dependencies: ["Dependo"]),
    ]
)
