// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PulsePanelProtocol",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PulsePanelProtocol",
            targets: ["PulsePanelProtocol"]
        )
    ],
    targets: [
        .target(
            name: "PulsePanelProtocol",
            path: "Sources/PulsePanelProtocol"
        ),
        .testTarget(
            name: "PulsePanelProtocolTests",
            dependencies: ["PulsePanelProtocol"],
            path: "Tests/PulsePanelProtocolTests"
        )
    ]
)
