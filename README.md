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

## Redirect URIs on iOS

`signInWithBrowser(redirectUri:)` supports both custom scheme redirect URIs and HTTPS Universal Links.

For a custom scheme such as `io.logto.app://callback`, register the scheme in your app's `Info.plist` and add the same URI to your Logto application's Redirect URIs. This works with automatic `ASWebAuthenticationSession` completion on all supported iOS versions.

### Use Universal Links instead of a custom scheme

You can also use an HTTPS redirect URI such as `https://example.com/callback`:

1. Add the Associated Domains capability to your app.
2. Configure the domain as `webcredentials:example.com` so `ASWebAuthenticationSession` can match HTTPS callbacks on iOS 17.4 and newer.
3. If the same URL should also open your app as a Universal Link outside the authentication session, configure `applinks:example.com` and host a valid `apple-app-site-association` file for the domain and path.
4. Add the HTTPS URI to your Logto application's Redirect URIs.

On iOS 17.4 and newer, the SDK uses `ASWebAuthenticationSession`'s HTTPS callback matching API so HTTPS redirects can automatically complete and dismiss the session. On older iOS versions, the authorization request can still use the HTTPS redirect URI, but the session may not close automatically unless your app handles the Universal Link callback itself. Keep a custom scheme redirect as a compatibility option if you need automatic completion on older iOS versions.

## Resources

[![Website](https://img.shields.io/badge/website-logto.io-8262F8.svg)](https://logto.io/)
[![Logto Docs](https://img.shields.io/badge/docs-logto.io-green.svg)](https://docs.logto.io/)
[![Discord](https://img.shields.io/discord/965845662535147551?logo=discord&logoColor=ffffff&color=7389D8&cacheSeconds=600)](https://discord.gg/UEPaF3j5e6)
