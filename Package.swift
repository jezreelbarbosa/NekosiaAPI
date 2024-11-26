// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "NekosiaAPI",
    products: [
        .library(name: "NekosiaAPI", targets: ["NekosiaAPI"]),
        .executable(name: "NekosiaAPISample", targets: ["NekosiaAPISample"])
    ],
    targets: [
        .target(name: "NekosiaAPI", dependencies: []),
        .executableTarget(name: "NekosiaAPISample", dependencies: ["NekosiaAPI"]),
        .testTarget(name: "NekosiaAPITests", dependencies: ["NekosiaAPI"]),
    ]
)
