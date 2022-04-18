//
//  LogtoSocialPluginWechat.swift
//
//
//  Created by Gao Sun on 2022/4/1.
//

#if !os(macOS)

    import Foundation
    import LogtoSocialPlugin
    @_exported import WechatOpenSDK

    public class LogtoSocialPluginWechatApiDelegate: NSObject, WXApiDelegate {
        var configuration: LogtoSocialPluginConfiguration?

        public func onResp(_ resp: BaseResp) {
            guard let configuration = configuration, let response = resp as? SendAuthResp else {
                return
            }

            // https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html
            guard response.errCode == 0 else {
                configuration
                    .errorHandler(LogtoSocialPluginError.authenticationFailed(socialCode: response.errCode.description, socialMessage: response.errStr))
                return
            }

            guard var callbackComponents = URLComponents(url: configuration.callbackUri, resolvingAgainstBaseURL: true)
            else {
                configuration.errorHandler(LogtoSocialPluginError.invalidCallbackUri)
                return
            }

            callbackComponents.queryItems = (callbackComponents.queryItems ?? []) + [
                URLQueryItem(name: "code", value: response.code),
                URLQueryItem(name: "state", value: response.state),
                URLQueryItem(name: "language", value: response.lang),
                URLQueryItem(name: "country", value: response.country),
            ]

            guard let url = callbackComponents.url else {
                configuration.errorHandler(LogtoSocialPluginError.unableToConstructCallbackUri)
                return
            }

            configuration.completion(url)
        }
    }

    public class LogtoSocialPluginWechat: LogtoSocialPlugin {
        let apiDelegate = LogtoSocialPluginWechatApiDelegate()

        public let connectorId = "wechat"
        public let urlSchemes = ["wechat"]
        public var isAvailable: Bool {
            WXApi.isWXAppInstalled()
        }

        public init() {}

        public func start(_ configuration: LogtoSocialPluginConfiguration) {
            guard let redirectComponents = URLComponents(url: configuration.redirectTo, resolvingAgainstBaseURL: true)
            else {
                configuration.errorHandler(LogtoSocialPluginError.invalidRedirectTo)
                return
            }

            guard
                let appId = redirectComponents.queryItems?.first(where: { $0.name == "app_id" })?.value,
                let universalLink = redirectComponents.queryItems?.first(where: { $0.name == "universal_link" })?.value,
                let state = redirectComponents.queryItems?.first(where: { $0.name == "state" })?.value
            else {
                configuration.errorHandler(LogtoSocialPluginError.insufficientInformation)
                return
            }

            WXApi.registerApp(appId, universalLink: universalLink)

            let request = SendAuthReq()

            request.scope = "snsapi_userinfo"
            request.state = state

            apiDelegate.configuration = configuration
            WXApi.send(request)
        }

        public func handle(url: URL) -> Bool {
            WXApi.handleOpen(url, delegate: apiDelegate)
        }
    }

#endif
