// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Multi",
    products: [
        .executable(name: "Multi", targets: ["Multi"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Multi"),
    ]
)
