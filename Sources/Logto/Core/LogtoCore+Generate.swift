//
//  LogtoCore+Generate.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

public extension LogtoCore {
    enum Prompt: String {
        case login
        case consent
    }

    enum DirectSignInMethod: String {
        case social
        case sso
    }

    struct DirectSignInOptions {
        let method: DirectSignInMethod
        let target: String

        public init(method: DirectSignInMethod, target: String) {
            self.method = method
            self.target = target
        }
    }

    private static let codeChallengeMethod = "S256"
    private static let responseType = "code"

    static func generateSignInUri(
        authorizationEndpoint: String,
        clientId: String,
        redirectUri: URL,
        codeChallenge: String,
        state: String,
        scopes: [String] = [],
        resources: [String] = [],
        prompt: Prompt = .consent,
        loginHint: String? = nil,
        directSignIn: DirectSignInOptions? = nil,
        extraParams: [String: String]? = nil
    ) throws -> URL {
        guard
            var components = URLComponents(string: authorizationEndpoint),
            components.scheme != nil,
            components.host != nil
        else {
            throw LogtoErrors.UrlConstruction.invalidEndpoint
        }

        let baseQueryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(
                name: "redirect_uri",
                value: redirectUri.absoluteString
            ),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: LogtoCore.codeChallengeMethod),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: LogtoUtilities.withReservedScopes(scopes).joined(separator: " ")),
            URLQueryItem(name: "response_type", value: LogtoCore.responseType),
            URLQueryItem(name: "prompt", value: prompt.rawValue),
        ]
        let resourceQueryItems = resources.map {
            URLQueryItem(name: "resource", value: $0)
        }
        var optionalQueryItems = [URLQueryItem]()

        if let loginHint, !loginHint.isEmpty {
            optionalQueryItems.append(URLQueryItem(name: "login_hint", value: loginHint))
        }

        if let directSignIn {
            let trimmedTarget = directSignIn.target.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedTarget.isEmpty {
                optionalQueryItems.append(URLQueryItem(
                    name: "direct_sign_in",
                    value: "\(directSignIn.method.rawValue):\(trimmedTarget)"
                ))
            }
        }

        let extraQueryItems = extraParams?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        } ?? []

        components.queryItems = (baseQueryItems + resourceQueryItems + optionalQueryItems + extraQueryItems)
            .filter { $0.value != "" }

        guard let url = components.url else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        return url
    }

    static func generateSignOutUri(
        endSessionEndpoint: String,
        idToken: String,
        postLogoutRedirectUri: String?
    ) throws -> URL {
        guard
            var components = URLComponents(string: endSessionEndpoint),
            components.scheme != nil,
            components.host != nil
        else {
            throw LogtoErrors.UrlConstruction.invalidEndpoint
        }

        let queryItems = [
            URLQueryItem(name: "id_token_hint", value: idToken),
            URLQueryItem(name: "post_logout_redirect_uri", value: postLogoutRedirectUri),
        ]
        components.queryItems = queryItems.filter { $0.value != "" }

        guard let url = components.url else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        return url
    }
}
