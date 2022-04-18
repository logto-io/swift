//
//  LogtoSocialPluginWeb.swift
//
//
//  Created by Gao Sun on 2022/3/30.
//

import AuthenticationServices
import Foundation
import LogtoSocialPlugin

class LogtoSocialPluginWebContextProviding: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

public class LogtoSocialPluginWeb: LogtoSocialPlugin {
    private static let callbackUrlScheme = "logto-callback"

    public let connectorId = "web"
    public let urlSchemes = ["http", "https"]

    public init() {}

    public func start(_ configuration: LogtoSocialPluginConfiguration) {
        guard var callbackComponents = URLComponents(url: configuration.callbackUri, resolvingAgainstBaseURL: true)
        else {
            configuration.errorHandler(LogtoSocialPluginError.invalidCallbackUri)
            return
        }

        let session = ASWebAuthenticationSession(
            url: configuration.redirectTo,
            callbackURLScheme: LogtoSocialPluginWeb.callbackUrlScheme
        ) { customUri, error in
            let error = error as? NSError
            guard let customUri = customUri else {
                configuration
                    .errorHandler(LogtoSocialPluginError.authenticationFailed(
                        socialCode: error?.code.description,
                        socialMessage: error?.localizedDescription
                    ))
                return
            }

            // Construct callback URL for WebView
            let customComponents = URLComponents(url: customUri, resolvingAgainstBaseURL: true)
            callbackComponents
                .queryItems = (callbackComponents.queryItems ?? []) + (customComponents?.queryItems ?? [])

            guard let url = callbackComponents.url else {
                configuration.errorHandler(LogtoSocialPluginError.unableToConstructCallbackUri)
                return
            }

            configuration.completion(url)
        }
        let context = LogtoSocialPluginWebContextProviding()

        session.presentationContextProvider = context
        session.start()
    }
}
