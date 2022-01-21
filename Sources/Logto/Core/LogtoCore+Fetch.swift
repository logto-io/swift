//
//  LogtoCore+Fetch.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

extension LogtoCore {
    // MARK: OIDC Config

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

    // MARK: Token Endpoint

    // https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint

    private enum TokenGrantType: String {
        case code = "authorization_code"
        case refreshToken = "refresh_token"
    }

    struct CodeTokenResponse: Codable, Equatable {
        let accessToken: String
        let refreshToken: String
        let idToken: String
        let scope: String
        let expiresIn: Int64
    }

    /// Fetch token by `authorization_code`.
    /// The returned `access_token` is only for user info enpoint.
    /// Note the func will NOT validate any token in the response.
    static func fetchToken(
        useSession session: NetworkSession = URLSession.shared,
        byAuthorizationCode code: String,
        codeVerifier: String,
        tokenEndpoint: String,
        clientId: String,
        resource: String? = nil,
        redirectUri: String,
        completion: @escaping HttpCompletion<CodeTokenResponse>
    ) {
        let body: [String: Any] = [
            "grant_type": TokenGrantType.code.rawValue,
            "code": code,
            "code_verifier": codeVerifier,
            "client_id": clientId,
            "resource": resource as Any,
            "redirect_uri": redirectUri,
        ].compactMapValues { $0 }

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            Utilities.httpPost(useSession: session, endpoint: tokenEndpoint, body: data, completion: completion)
        } catch {
            completion(nil, error)
        }
    }

    struct RefreshTokenTokenResponse: Codable, Equatable {
        let accessToken: String
        let refreshToken: String
        let idToken: String?
        let scope: String
        let expiresIn: Int64
    }

    /// Fetch token by `refresh_token`.
    /// Note the func will NOT validate any token in the response.
    static func fetchToken(
        useSession session: NetworkSession = URLSession.shared,
        byRefreshToken refreshToken: String,
        tokenEndpoint: String,
        clientId: String,
        resource: String? = nil,
        scope: ValueOrArray<String>? = nil,
        completion: @escaping HttpCompletion<CodeTokenResponse>
    ) {
        let body: [String: Any] = [
            "grant_type": TokenGrantType.refreshToken.rawValue,
            "refresh_token": refreshToken,
            "client_id": clientId,
            "resource": resource as Any,
            "scope": scope?.inArray.joined(separator: " ") as Any,
        ].compactMapValues { $0 }

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            Utilities.httpPost(useSession: session, endpoint: tokenEndpoint, body: data, completion: completion)
        } catch {
            completion(nil, error)
        }
    }

    // MARK: User Info

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
