//
//  LogtoCore+Fetch.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

extension LogtoCore {
    struct OidcConfigResponse: Codable, Equatable {
        let authorizationEndpoint: String
        let tokenEndpoint: String
        let endSessionEndpoint: String
        let revocationEndpoint: String
        let jwksUri: String
        let issuer: String
    }

    static func fetchOidcConfig(
        useSession session: NetworkSession = URLSession.shared,
        endpoint: String,
        completion: @escaping HttpCompletion<OidcConfigResponse>
    ) {
        Utilities.httpGet(useSession: session, endpoint: endpoint, completion: completion)
    }

    private static let tokenGrantType = "authorization_code"

    struct CodeTokenResponse: Codable, Equatable {
        let accessToken: String
        let refreshToken: String
        let idToken: String
        let tokenType: String
        let scope: String
        let expiresIn: UInt64
    }

    static func fetchToken(
        useSession session: URLSession = .shared,
        byAuthorizationCode code: String,
        codeVerifier: String,
        tokenEndpoint: String,
        clientId: String,
        redirectUri: String,
        completion: @escaping HttpCompletion<CodeTokenResponse>
    ) throws {
        guard var components = URLComponents(string: tokenEndpoint), components.scheme != nil,
              components.host != nil
        else {
            throw LogtoErrors.UrlConstruction.invalidEndpoint
        }

        components.queryItems = [
            URLQueryItem(name: "grant_type", value: tokenGrantType),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeVerifier),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
        ]

        guard let url = components.url else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        Utilities.httpGet(useSession: session, endpoint: url.absoluteString, completion: completion)
    }
}
