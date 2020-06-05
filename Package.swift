// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Multi",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .executable(name: "Preferences", targets: ["Preferences"]),
        .executable(name: "Runtime",     targets: ["Runtime"]),
        .executable(name: "Stub",        targets: ["Stub"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Preferences", dependencies: ["Shared"]),
        .target(name: "Runtime",     dependencies: ["Shared"]),
        .target(name: "Stub",        dependencies: ["Shared"]),
        .target(name: "Shared"),
    ]
)
