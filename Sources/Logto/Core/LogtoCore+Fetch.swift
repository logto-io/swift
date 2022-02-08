//
//  LogtoCore+Fetch.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

public extension LogtoCore {
    static let postHeaders: [String: String] = [
        "Content-Type": "application/x-www-form-urlencoded",
    ]

    // MARK: OIDC Config

    struct OidcConfigResponse: Codable, Equatable {
        public let authorizationEndpoint: String
        public let tokenEndpoint: String
        public let endSessionEndpoint: String
        public let revocationEndpoint: String
        // Use `userinfo` instead of `userInfo` per OIDC Discovery spec
        // https://openid.net/specs/openid-connect-discovery-1_0.html [3. OpenID Provider Metadata]
        public let userinfoEndpoint: String
        public let jwksUri: String
        public let issuer: String
    }

    static func fetchOidcConfig(
        useSession session: NetworkSession = URLSession.shared,
        endpoint: String,
        completion: @escaping HttpCompletion<OidcConfigResponse>
    ) {
        LogtoRequest.get(useSession: session, endpoint: endpoint, completion: completion)
    }

    // MARK: Token Endpoint

    // https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint

    private enum TokenGrantType: String {
        case code = "authorization_code"
        case refreshToken = "refresh_token"
    }

    struct CodeTokenResponse: Codable, Equatable {
        public let accessToken: String
        public let refreshToken: String
        public let idToken: String
        public let scope: String
        public let expiresIn: Int64
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
        redirectUri: String,
        completion: @escaping HttpCompletion<CodeTokenResponse>
    ) {
        let body: [String: String?] = [
            "grant_type": TokenGrantType.code.rawValue,
            "code": code,
            "code_verifier": codeVerifier,
            "client_id": clientId,
            "redirect_uri": redirectUri,
        ]

        LogtoRequest.post(
            useSession: session,
            endpoint: tokenEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8),
            completion: completion
        )
    }

    struct RefreshTokenTokenResponse: Codable, Equatable {
        public let accessToken: String
        public let refreshToken: String
        public let idToken: String?
        public let scope: String
        public let expiresIn: Int64
    }

    /// Fetch token by `refresh_token`.
    /// Note the func will NOT validate any token in the response.
    static func fetchToken(
        useSession session: NetworkSession = URLSession.shared,
        byRefreshToken refreshToken: String,
        tokenEndpoint: String,
        clientId: String,
        resource: String?,
        scopes: [String],
        completion: @escaping HttpCompletion<RefreshTokenTokenResponse>
    ) {
        let body: [String: String?] = [
            "grant_type": TokenGrantType.refreshToken.rawValue,
            "refresh_token": refreshToken,
            "client_id": clientId,
            "resource": resource,
            "scope": scopes.joined(separator: " "),
        ]

        LogtoRequest.post(
            useSession: session,
            endpoint: tokenEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8),
            completion: completion
        )
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
        LogtoRequest.get(
            useSession: session,
            endpoint: userInfoEndpoint,
            headers: ["Authorization": "Bearer \(accessToken)"],
            completion: completion
        )
    }
}
