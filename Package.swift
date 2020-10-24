// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networker",
    products: [
        .library(
            name: "Networker",
            targets: ["Networker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    ],
    targets: [
        .target(
            name: "Networker",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkerTests",
            dependencies: [
                "Networker", "Quick", "Nimble"
            ]
        ),
    ]
)
