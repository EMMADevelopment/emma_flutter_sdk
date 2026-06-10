// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "emma_flutter_sdk",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(name: "emma-flutter-sdk", targets: ["emma_flutter_sdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/EMMADevelopment/eMMa-iOS-SDK", from: "4.16.0"),
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "emma_flutter_sdk",
            dependencies: [
                .product(name: "EMMA_iOS", package: "eMMa-iOS-SDK"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/emma_flutter_sdk",
        )
    ]
)
