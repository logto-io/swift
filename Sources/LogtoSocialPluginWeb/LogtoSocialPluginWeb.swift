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
    case unableToConstructCallbackUri

    public var code: String {
        switch self {
        case .webAuthFailed:
            return "web_auth_failed"
        case .unableToConstructCallbackUri:
            return "unable_to_construct_callback_uri"
        }
    }

    var localizedDescription: String {
        switch self {
        case let .webAuthFailed(innerError):
            return innerError?.localizedDescription ?? "Web authentication failed."
        case .unableToConstructCallbackUri:
            return "Unable to construct callback URI."
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
            configuration.errorHandler(LogtoSocialPluginWebError.unableToConstructCallbackUri)
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
                configuration.errorHandler(LogtoSocialPluginWebError.unableToConstructCallbackUri)
                return
            }

            configuration.completion(url)
        }
        let context = LogtoSocialPluginWebContextProviding()

        session.presentationContextProvider = context
        session.start()
    }
}
