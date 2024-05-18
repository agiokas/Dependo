// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Example",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "Example", targets: ["Example"]),
    ],
    dependencies: [
        .package(name: "Dependo", path: "..")
    ],
    targets: [
        .target(name: "Example",
                dependencies: ["Dependo"]),
        .testTarget(name: "ExampleTests",
                    dependencies: ["Example"]),
    ]
)
