// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CuroBridge",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CuroBridge",
            targets: ["CuroBridge"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/espressif/esp-idf-provisioning-ios.git", from: "3.0.3"),
        .package(url: "https://github.com/GetStream/stream-video-swift.git", from: "1.45.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.2.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CuroBridge",
            dependencies: [
                .product(name: "ESPProvision", package: "esp-idf-provisioning-ios"),
                .product(name: "StreamVideo", package: "stream-video-swift"),
                .product(name: "StreamVideoSwiftUI", package: "stream-video-swift"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit")
                
            ]
        ),
    ]
)
