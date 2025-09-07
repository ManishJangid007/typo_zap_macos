// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TypoZap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TypoZap",
            targets: ["TypoZap"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.1")
    ],
    targets: [
        .executableTarget(
            name: "TypoZap",
            dependencies: ["HotKey"],
            path: "Sources/TypoZap",
            resources: [
                .process("../../tones.json")
            ]
        )
    ]
)
