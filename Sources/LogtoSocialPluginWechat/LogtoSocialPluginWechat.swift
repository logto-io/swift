//
//  LogtoSocialPluginWechat.swift
//
//
//  Created by Gao Sun on 2022/4/1.
//

import Foundation
import LogtoSocialPlugin
@_exported import WechatOpenSDK

public enum LogtoSocialPluginWechatError: LogtoSocialPluginError {
    case authFailed(withCode: String)
    case insufficientInfo

    public var code: String {
        switch self {
        case .insufficientInfo:
            return "insufficient_info"
        case .authFailed:
            return "auth_failed"
        }
    }

    var localizedDescription: String {
        switch self {
        case .insufficientInfo:
            return "The redirect URL contains insufficient information."
        case let .authFailed(withCode):
            return "Wechat auth failed with code \(withCode)."
        }
    }
}

public class LogtoSocialPluginWechatApiDelegate: NSObject, WXApiDelegate {
    var configuration: LogtoSocialPluginConfiguration?

    public func onResp(_ resp: BaseResp) {
        guard let configuration = configuration, let response = resp as? SendAuthResp else {
            return
        }

        // https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html
        guard response.errCode == 0 else {
            configuration.errorHandler(LogtoSocialPluginWechatError.authFailed(withCode: response.errCode.description))
            return
        }

        guard var callbackComponents = URLComponents(url: configuration.callbackUri, resolvingAgainstBaseURL: true)
        else {
            configuration.errorHandler(LogtoSocialPluginUriError.unableToConstructCallbackComponents)
            return
        }

        callbackComponents.queryItems = (callbackComponents.queryItems ?? []) + [
            URLQueryItem(name: "code", value: response.code),
            URLQueryItem(name: "state", value: response.state),
            URLQueryItem(name: "language", value: response.lang),
            URLQueryItem(name: "country", value: response.country),
        ]

        guard let url = callbackComponents.url else {
            configuration.errorHandler(LogtoSocialPluginUriError.unableToConstructCallbackUri)
            return
        }

        configuration.completion(url)
    }
}

public class LogtoSocialPluginWechat: LogtoSocialPlugin {
    let apiDelegate = LogtoSocialPluginWechatApiDelegate()

    public let connectorId = "wechat"
    public let urlSchemes = ["wechat"]

    public init() {}

    public func start(_ configuration: LogtoSocialPluginConfiguration) {
        guard let redirectComponents = URLComponents(url: configuration.redirectUri, resolvingAgainstBaseURL: true)
        else {
            configuration.errorHandler(LogtoSocialPluginUriError.unableToConstructRedirectComponents)
            return
        }

        guard
            let appId = redirectComponents.queryItems?.first(where: { $0.name == "app_id" })?.value,
            let universalLink = redirectComponents.queryItems?.first(where: { $0.name == "universal_link" })?.value,
            let state = redirectComponents.queryItems?.first(where: { $0.name == "state" })?.value
        else {
            configuration.errorHandler(LogtoSocialPluginWechatError.insufficientInfo)
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
