<p align="center">
    <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
        <img src="./logo.png" width="100">
    </a>
    <br/>
    <span><i><a href="https://logto.io" target="_blank">Logto</a> helps you build the sign-in experience and user identity within minutes.</i></span>
</p>

# Logto Swift SDKs

The monorepo for SDKs and social plugins written in Swift. Check out our [integration guide](https://docs.logto.io/docs/recipes/integrate-logto/ios) or [SDK reference](https://docs.logto.io/sdk/Swift) for more information.

We also provide [集成指南](https://docs.logto.io/zh-cn/docs/recipes/integrate-logto/ios) and [SDK 参考](https://docs.logto.io/zh-cn/sdk/Swift) in Simplified Chinese.

## Installation

### Swift Package Manager

Since Xcode 11, you can [directly import a swift package](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) w/o any additional tool. Use the following URL to add Logto SDKs as a dependency:

```bash
https://github.com/logto-io/swift.git
```

### Carthage

Carthage [needs a `xcodeproj` file to build](https://github.com/Carthage/Carthage/issues/1226#issuecomment-290931385), but `swift package generate-xcodeproj` will report a failure since we are using binary targets for native social plugins. We will try to find a workaround later.

### CocoaPods

CocoaPods [does not support local dependency](https://github.com/CocoaPods/CocoaPods/issues/3276) and monorepo, thus it's hard to create a `.podspec` for this repo.

## Products

| Name | Description |
|---|---|
| Logto | Logto swift core. |
| LogtoClient | Logto swift client. |
| LogtoSocialPlugin | Social plugin foundation for LogtoClient. |
| LogtoSocialPluginWeb | Social plugin for OAuth-like web IdPs. |
| LogtoSocialPluginAlipay | Social plugin for Alipay sign in. |
| LogtoSocialPluginWechat | Social plugin for WeChat sign in. |

In most cases, you only need to import `LogtoClient`, which includes `Logto` and `LogtoSocialPluginWeb` under the hood.

The related plugin is required when you integrate a [connector with native tag](https://docs.logto.io/connector/native).

## Resources

[![Website](https://img.shields.io/badge/website-logto.io-8262F8.svg)](https://logto.io/)
[![Logto Docs](https://img.shields.io/badge/docs-logto.io-green.svg)](https://docs.logto.io/)
[![Discord](https://img.shields.io/discord/965845662535147551?logo=discord&logoColor=ffffff&color=7389D8&cacheSeconds=600)](https://discord.gg/UEPaF3j5e6)
