// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CuroBridge",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CuroBridge",
            targets: ["CuroBridge"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/espressif/esp-idf-provisioning-ios.git", from: "2.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CuroBridge",
            dependencies: [
                .product(name: "ESPProvision", package: "esp-idf-provisioning-ios")
            ]
        ),
    ]
)
