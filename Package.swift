// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Multi",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "App",     targets: ["MultiApp"]),
        .executable(name: "Runtime", targets: ["MultiRuntime"]),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(name: "MultiApp",     dependencies: ["MultiSettings"]),
        .executableTarget(name: "MultiRuntime", dependencies: ["MultiSettings"]),
        .target(name: "MultiSettings"),
    ]
)
