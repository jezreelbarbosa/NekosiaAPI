// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "NekosiaAPI",
    products: [
        .library(name: "NekosiaAPI", targets: ["NekosiaAPI"])
    ],
    targets: [
        .target(name: "NekosiaAPI", dependencies: []),
        .testTarget(name: "NekosiaAPITests", dependencies: ["NekosiaAPI"]),
    ]
)
