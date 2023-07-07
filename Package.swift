// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Multi",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "App",     targets: ["MultiApp"]),
        .executable(name: "Runtime", targets: ["MultiRuntime"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "MultiApp",     dependencies: ["MultiSettings"]),
        .target(name: "MultiRuntime", dependencies: ["MultiSettings"]),
        .target(name: "MultiSettings"),
    ]
)
