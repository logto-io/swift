<p align="center">
    <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
        <img src="./logo.png" width="100">
    </a>
    <br/>
    <span><i><a href="https://logto.io" target="_blank">Logto</a> helps you quickly focus on everything after signing in.</i></span>
</p>

# Logto Swift SDKs

The monorepo for SDKs and social plugins written in Swift. Check out our [integration guide](https://docs.logto.io/integrate-sdk/swift) or [docs](https://docs.logto.io/sdk/swift) for more information.

We also provide [集成指南](https://docs.logto.io/zh-cn/integrate-sdk/swift) and [文档](https://docs.logto.io/zh-cn/sdk/swift) in Simplified Chinese.

## Installation

### Swift Package Manager

Use the following URL to add Logto SDKs as a dependency:

```bash
https://github.com/logto-io/swift.git
```

## Products

| Name | Description |
|---|---|
| Logto | Logto swift core. |
| LogtoClient | Logto swift client. |
| LogtoSocialPlugin | Social plugin foundation for LogtoClient. |
| LogtoSocialPluginWeb | Social plugin for OAuth-like web IdPs. |
| LogtoSocialPluginAlipay | Social plugin for Alipay sign in. |
| LogtoSocialPluginWechat | Social plugin for Wechat sign in. |

In most cases, you only need to import `LogtoClient`, which includes `Logto` and `LogtoSocialPluginWeb` under the hood.

The related plugin is required when you integrate a [connector with native tag](https://docs.logto.io/connector/native).

## Resources

TBD: Discord, posts, etc.
