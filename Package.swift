// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogtoSDK",
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
            name: "Logto",
            dependencies: ["JOSESwift"]
        ),
        .target(
            name: "LogtoMock",
            dependencies: ["Logto"],
            path: "Tests/LogtoMock"
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
            url: "https://github.com/logto-io/social-sdks/raw/9441f1c774e430fad54a900581f1091109772189/alipay/swift/AFServiceSDK.zip",
            checksum: "197f4e7e2930e5331642923c393ee9f1ea85b5db8a7ab82550c94b0c0facc8bc"
        ),
        .target(
            name: "LogtoSocialPluginAlipay",
            dependencies: ["LogtoSocialPlugin", "AFServiceSDK"]
        ),
        .binaryTarget(
            name: "WechatOpenSDK",
            url: "https://github.com/logto-io/social-sdks/raw/9441f1c774e430fad54a900581f1091109772189/wechat/swift/WechatOpenSDK.zip",
            checksum: "545fa87232593a76f69f799513096334cb0f491b165cc45ccdd0dc5bdddcd958"
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
