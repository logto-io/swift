// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logto SDK",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v5)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Logto",
            targets: ["Logto"]
        ),
        .library(
            name: "LogtoClient",
            targets: ["LogtoClient"]
        ),
        .library(
            name: "LogtoSocialPlugin",
            targets: ["LogtoSocialPlugin"]
        ),
        .library(
            name: "LogtoSocialPluginWeb",
            targets: ["LogtoSocialPluginWeb"]
        ),
        .library(
            name: "LogtoSocialPluginAlipay",
            targets: ["LogtoSocialPluginAlipay"]
        ),
        .library(
            name: "LogtoSocialPluginWechat",
            targets: ["LogtoSocialPluginWechat"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "2.3.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LogtoMock",
            dependencies: ["Logto"],
            path: "Tests/LogtoMock"
        ),
        .target(
            name: "Logto",
            dependencies: ["JOSESwift"]
        ),
        .testTarget(
            name: "LogtoTests",
            dependencies: ["Logto", "LogtoMock"]
        ),
        .target(
            name: "LogtoClient",
            dependencies: ["Logto", "KeychainAccess", "LogtoSocialPlugin", "LogtoSocialPluginWeb"]
        ),
        .testTarget(
            name: "LogtoClientTests",
            dependencies: ["LogtoClient", "LogtoMock"]
        ),
        .target(
            name: "LogtoSocialPlugin",
            dependencies: []
        ),
        .target(
            name: "LogtoSocialPluginWeb",
            dependencies: ["LogtoSocialPlugin"]
        ),
        .binaryTarget(
            name: "AFServiceSDK",
            url: "https://github.com/logto-io/social-sdks/raw/92065b00d61dde0d44b4e76394a81334b87000a1/alipay/swift/AFServiceSDK.zip",
            checksum: "d140f1e4c6a73e3488e5572ccb6e0a4e23227549b7d04b9793423cf2e8608c57"
        ),
        .target(
            name: "LogtoSocialPluginAlipay",
            dependencies: ["LogtoSocialPlugin", "AFServiceSDK"]
        ),
        .binaryTarget(
            name: "WechatOpenSDK",
            url: "https://github.com/logto-io/social-sdks/raw/eadafc84b6c0c7a0eb774fd7029cba8209561334/wechat/swift/WechatOpenSDK.zip",
            checksum: "0e57d10a3e817e843028eac8f2fd29ba45b3ea2ccbf760ec0842ac76e7e1dec6"
        ),
        .target(
            name: "LogtoSocialPluginWechat",
            dependencies: ["LogtoSocialPlugin", "WechatOpenSDK"],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
            ]
        ),
    ]
)
