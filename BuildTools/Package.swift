// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", .exact("0.53.5")),
    ],
    targets: [.target(name: "BuildTools", path: "")]
)
