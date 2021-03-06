//
//  LogtoCore+Fetch.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation
import JOSESwift

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
        public let jwksUri: String
        public let issuer: String
    }

    static func fetchOidcConfig(
        useSession session: NetworkSession = URLSession.shared,
        uri: URL
    ) async throws -> OidcConfigResponse {
        try await LogtoRequest.get(useSession: session, url: uri)
    }

    // MARK: Token Endpoint

    // https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint

    private enum TokenGrantType: String {
        case code = "authorization_code"
        case refreshToken = "refresh_token"
    }

    struct CodeTokenResponse: Codable, Equatable {
        public let accessToken: String
        public let refreshToken: String?
        public let idToken: String
        public let scope: String
        public let expiresIn: Int64
    }

    /// Fetch token by `authorization_code`.
    /// The returned `access_token` is only for [UserInfo Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo).
    /// Note the function will NOT validate any token in the response.
    static func fetchToken(
        useSession session: NetworkSession = URLSession.shared,
        byAuthorizationCode code: String,
        codeVerifier: String,
        tokenEndpoint: String,
        clientId: String,
        redirectUri: String
    ) async throws -> CodeTokenResponse {
        let body: [String: String?] = [
            "grant_type": TokenGrantType.code.rawValue,
            "code": code,
            "code_verifier": codeVerifier,
            "client_id": clientId,
            "redirect_uri": redirectUri,
        ]

        return try await LogtoRequest.post(
            useSession: session,
            endpoint: tokenEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8)
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
    /// Note the function will NOT validate any token in the response.
    static func fetchToken(
        useSession session: NetworkSession = URLSession.shared,
        byRefreshToken refreshToken: String,
        tokenEndpoint: String,
        clientId: String,
        resource: String?,
        scopes: [String]
    ) async throws -> RefreshTokenTokenResponse {
        let body: [String: String?] = [
            "grant_type": TokenGrantType.refreshToken.rawValue,
            "refresh_token": refreshToken,
            "client_id": clientId,
            "resource": resource,
            "scope": scopes.joined(separator: " "),
        ]

        return try await LogtoRequest.post(
            useSession: session,
            endpoint: tokenEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8)
        )
    }

    // MARK: JWK Set

    static func fetchJwkSet(
        useSession session: NetworkSession = URLSession.shared,
        jwksUri: String
    ) async throws -> JWKSet {
        try await LogtoRequest.get(
            useSession: session,
            endpoint: jwksUri
        )
    }
}
