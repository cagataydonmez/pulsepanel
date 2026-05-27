// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PulsePanel",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PulsePanelProtocol",
            targets: ["PulsePanelProtocol"]
        ),
        .library(
            name: "PulsePaneliOSApp",
            targets: ["PulsePaneliOSApp"]
        ),
        .executable(
            name: "PulsePanelMac",
            targets: ["PulsePanelMac"]
        )
    ],
    targets: [
        .target(
            name: "PulsePanelProtocol",
            path: "Packages/PulsePanelProtocol/Sources/PulsePanelProtocol"
        ),
        .target(
            name: "PulsePaneliOSApp",
            dependencies: ["PulsePanelProtocol"],
            path: "Apps/PulsePaneliOS",
            exclude: ["Resources"],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "PulsePanelMac",
            dependencies: ["PulsePanelProtocol"],
            path: "Apps/PulsePanelMac",
            exclude: ["Resources"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PulsePanelProtocolTests",
            dependencies: ["PulsePanelProtocol"],
            path: "Packages/PulsePanelProtocol/Tests/PulsePanelProtocolTests"
        )
    ]
)
