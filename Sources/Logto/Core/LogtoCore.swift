//
//  LogtoCore.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

enum LogtoCore {
    private static let codeChallengeMethod = "S256"
    private static let responseType = "authorization_code"
    private static let prompt = "consent"

    static func generateSignInUrl(
        authorizationEndpoint: String,
        clientId: String,
        redirectUri: String,
        codeChallenge: String,
        state: String,
        scope: ValueOrArray<String>? = nil,
        resource: ValueOrArray<String>? = nil
    ) throws -> URL {
        guard
            var components = URLComponents(string: authorizationEndpoint),
            components.scheme != nil,
            components.host != nil
        else {
            throw LogtoErrors.UrlConstruction.invalidAuthorizationEndpoint
        }

        let baseQueryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: LogtoCore.codeChallengeMethod),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: (scope?.inArray ?? []).joined(separator: " ")),
            URLQueryItem(name: "response_type", value: LogtoCore.responseType),
            URLQueryItem(name: "prompt", value: LogtoCore.prompt),
        ]
        let resourceQueryItems = (resource?.inArray ?? []).map {
            URLQueryItem(name: "resource", value: $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }

        components.queryItems = (baseQueryItems + resourceQueryItems).filter { $0.value != "" }

        guard let url = components.url else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        return url
    }
}
