// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Dependo",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "Dependo", targets: ["Dependo"]),
        .library(name: "DependoMacro", targets: ["DependoMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
    ],
    targets: [
        .target(name: "Dependo", dependencies: ["DependoMacro"]),
        .target(name: "DependoMacro", dependencies: ["DependoMacros"]),
        .macro(
            name: "DependoMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .executableTarget(name: "DependoExample", dependencies: ["Dependo"]),
        .testTarget(name: "DependoTests", dependencies: ["Dependo", "DependoMacro"]),
        .testTarget(name: "DependoMacroTests",
                    dependencies: [
                        "DependoMacros",
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                    ]),
    ]
)
