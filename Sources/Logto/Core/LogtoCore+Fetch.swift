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
        useSession session: NetworkSession = URLSession.shared,
        byAuthorizationCode code: String,
        codeVerifier: String,
        tokenEndpoint: String,
        clientId: String,
        redirectUri: String,
        completion: @escaping HttpCompletion<CodeTokenResponse>
    ) {
        let body: [String: Any] = [
            "grant_type": tokenGrantType,
            "code": code,
            "code_verifier": codeVerifier,
            "client_id": clientId,
            "redirect_uri": redirectUri,
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            Utilities.httpPost(useSession: session, endpoint: tokenEndpoint, body: data, completion: completion)
        } catch {
            completion(nil, error)
        }
    }

    struct UserInfoResponse: Codable, Equatable {
        let sub: String
        // More props TBD by LOG-561
    }

    static func fetchUserInfo(
        useSession session: NetworkSession = URLSession.shared,
        userInfoEndpoint: String,
        accessToken: String,
        completion: @escaping HttpCompletion<UserInfoResponse>
    ) {
        Utilities.httpGet(
            useSession: session,
            endpoint: userInfoEndpoint,
            headers: ["Authorization": "Bearer \(accessToken)"],
            completion: completion
        )
    }
}
