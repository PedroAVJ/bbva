// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BBVA",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BBVA", targets: ["BBVA"]),
    ],
    targets: [
        .executableTarget(
            name: "BBVA",
            resources: [.process("Resources")],
            linkerSettings: [.linkedLibrary("sqlite3")]
        ),
        .testTarget(name: "BBVATests", dependencies: ["BBVA"]),
    ],
    swiftLanguageModes: [.v5]
)
