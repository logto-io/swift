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
            URLQueryItem(
                name: "redirect_uri",
                value: redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ),
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
            throw LogtoErrors.UrlConstruction.invalidAuthorizationEndpoint
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

    static func verifyAndParseSignInCallbackUri(_ callbackUri: String, redirectUri: String,
                                                state: String) throws -> String
    {
        guard callbackUri.starts(with: redirectUri) else {
            throw LogtoErrors.UriVerification.redirectUriMismatched
        }

        guard let components = URLComponents(string: callbackUri) else {
            throw LogtoErrors.UriVerification.decodeComponentsFailed
        }

        guard components.queryItems?.contains(where: { $0.name == "state" && $0.value == state }) ?? false else {
            throw LogtoErrors.UriVerification.stateMismatched
        }

        let errorItems = components.queryItems?.filter { ["error", "error_description"].contains($0.name) } ?? []

        guard errorItems.count == 0 else {
            throw LogtoErrors.UriVerification.errorItemFound(items: errorItems)
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw LogtoErrors.UriVerification.missingCode
        }

        return code
    }
}
