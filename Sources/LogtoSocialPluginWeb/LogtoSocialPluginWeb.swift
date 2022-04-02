//
//  LogtoSocialPluginWeb.swift
//
//
//  Created by Gao Sun on 2022/3/30.
//

import AuthenticationServices
import Foundation
import LogtoSocialPlugin

public enum LogtoSocialPluginWebError: LogtoSocialPluginError {
    case webAuthFailed(innerError: Error?)

    public var code: String {
        switch self {
        case .webAuthFailed:
            return "web_auth_failed"
        }
    }

    var localizedDescription: String {
        switch self {
        case let .webAuthFailed(innerError):
            return innerError?.localizedDescription ?? "Web authentication failed."
        }
    }
}

class LogtoSocialPluginWebContextProviding: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

public class LogtoSocialPluginWeb: LogtoSocialPlugin {
    private static let callbackUrlScheme = "logto-callback"

    public let urlSchemes = ["http", "https"]

    public init() {}

    public func start(_ configuration: LogtoSocialPluginConfiguration) {
        guard var callbackComponents = URLComponents(url: configuration.callbackUri, resolvingAgainstBaseURL: true)
        else {
            configuration.errorHandler(LogtoSocialPluginUriError.unableToConstructCallbackUri)
            return
        }

        let session = ASWebAuthenticationSession(
            url: configuration.redirectUri,
            callbackURLScheme: LogtoSocialPluginWeb.callbackUrlScheme
        ) { customUri, error in
            guard let customUri = customUri else {
                configuration.errorHandler(LogtoSocialPluginWebError.webAuthFailed(innerError: error))
                return
            }

            // Construct callback URL for WebView
            let customComponents = URLComponents(url: customUri, resolvingAgainstBaseURL: true)
            callbackComponents
                .queryItems = (callbackComponents.queryItems ?? []) + (customComponents?.queryItems ?? [])

            guard let url = callbackComponents.url else {
                configuration.errorHandler(LogtoSocialPluginUriError.unableToConstructCallbackUri)
                return
            }

            configuration.completion(url)
        }
        let context = LogtoSocialPluginWebContextProviding()

        session.presentationContextProvider = context
        session.start()
    }
}
