// swift-tools-version:4.2

import PackageDescription

#if SWIFT3
let package = Package(name: "Multi")

#else
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
#endif
