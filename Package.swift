// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Multi",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .executable(name: "Builder", targets: ["Builder"]),
        .executable(name: "Runner", targets: ["Runner"]),
        .executable(name: "Stub", targets: ["Stub"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Builder"),
        .target(name: "Runner"),
        .target(name: "Stub"),
    ]
)
