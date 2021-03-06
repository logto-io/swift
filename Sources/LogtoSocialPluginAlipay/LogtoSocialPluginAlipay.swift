//
//  LogtoSocialPluginAlipay.swift
//
//
//  Created by Gao Sun on 2022/3/31.
//

#if !os(macOS)

    @_exported import AFServiceSDK
    import Foundation
    import LogtoSocialPlugin

    // Follows Alipay official docs: https://opendocs.alipay.com/open/218/wy75xo
    public class LogtoSocialPluginAlipay: LogtoSocialPlugin {
        public let connectorPlatform: LogtoSocialPluginPlatform = .native
        public let connectorTarget: String? = "alipay"
        public let urlSchemes = ["alipay"]

        public init() {}

        public func start(_ configuration: LogtoSocialPluginConfiguration) {
            guard let redirectComponents = URLComponents(url: configuration.redirectTo, resolvingAgainstBaseURL: true)
            else {
                configuration.errorHandler(LogtoSocialPluginError.invalidRedirectTo)
                return
            }

            guard var callbackComponents = URLComponents(url: configuration.callbackUri, resolvingAgainstBaseURL: true)
            else {
                configuration.errorHandler(LogtoSocialPluginError.invalidCallbackUri)
                return
            }

            var components = URLComponents()

            components.scheme = "https"
            components.host = "authweb.alipay.com"
            components.path = "/auth"
            components.queryItems = [
                URLQueryItem(name: "auth_type", value: "PURE_OAUTH_SDK"),
                URLQueryItem(name: "scope", value: "auth_user"),
            ] + (redirectComponents.queryItems ?? [])

            AFServiceCenter.call(.auth, withParams: [
                kAFServiceOptionBizParams: [
                    "url": components.string,
                ],
                kAFServiceOptionCallbackScheme: "logto-demo",
            ]) { response in
                guard let response = response, response.responseCode == AFResCode.success else {
                    configuration
                        .errorHandler(LogtoSocialPluginError
                            .authenticationFailed(
                                socialCode: response?.responseCode.rawValue.description ?? "unknown",
                                socialMessage: nil
                            ))
                    return
                }

                callbackComponents.queryItems = (callbackComponents.queryItems ?? []) + response.result
                    .map { key, value in
                        URLQueryItem(name: key.description, value: String(describing: value))
                    }

                guard let url = callbackComponents.url else {
                    configuration.errorHandler(LogtoSocialPluginError.unableToConstructCallbackUri)
                    return
                }

                configuration.completion(url)
            }
        }

        public func handle(url: URL) -> Bool {
            // https://opendocs.alipay.com/open/218/wy75xo#iOS%20%E7%A4%BA%E4%BE%8B
            guard url.host == "apmqpdispatch" else {
                return false
            }

            AFServiceCenter.handleResponseURL(url) { _ in
                print("the app has been killed")
            }

            return true
        }
    }

#endif
