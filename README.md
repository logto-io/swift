<p align="center">
    <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
        <img src="https://raw.githubusercontent.com/logto-io/logto/master/logo.png" height="120">
    </a>
</p>

# Logto Swift SDKs

The monorepo for [Logto](https://github.com/logto-io) SDKs written in Swift. Check out our [docs](https://docs.logto.io/sdk/swift/) for more information.

## Installation

### Swift Package Manager

Since Xcode 11, you can [directly import a swift package](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) w/o any additional tool. Use the following URL to add Logto SDKs as a dependency:

```bash
https://github.com/logto-io/swift.git
```

### Carthage

Carthage [needs a `xcodeproj` file to build](https://github.com/Carthage/Carthage/issues/1226#issuecomment-290931385). We will try to find a workaround later.

### CocoaPods

CocoaPods [does not support local dependency](https://github.com/CocoaPods/CocoaPods/issues/3276) and monorepo, thus it's hard to create a `.podspec` for this repo.

## Products

| Name | Description |
|---|---|
| Logto | Logto swift core. |
| LogtoClient | Logto swift client. |

In most cases, you only need to import `LogtoClient`, which includes `Logto` under the hood.

## Resources

[![Website](https://img.shields.io/badge/website-logto.io-8262F8.svg)](https://logto.io/)
[![Logto Docs](https://img.shields.io/badge/docs-logto.io-green.svg)](https://docs.logto.io/)
[![Discord](https://img.shields.io/discord/965845662535147551?logo=discord&logoColor=ffffff&color=7389D8&cacheSeconds=600)](https://discord.gg/UEPaF3j5e6)
