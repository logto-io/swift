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
        // Use `userinfo` instead of `userInfo` per OIDC Discovery spec
        // https://openid.net/specs/openid-connect-discovery-1_0.html [3. OpenID Provider Metadata]
        public let userinfoEndpoint: String
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
        public let idToken: String?
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
        public let refreshToken: String?
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
        scopes: [String]?
    ) async throws -> RefreshTokenTokenResponse {
        let isResourceOrganizationUrn = LogtoUtilities.isOrganizationUrn(resource)
        let body: [String: String?] = [
            "grant_type": TokenGrantType.refreshToken.rawValue,
            "refresh_token": refreshToken,
            "client_id": clientId,
            "resource": isResourceOrganizationUrn ? nil : resource,
            "organization_id": isResourceOrganizationUrn ? resource?
                .suffix(from: LogtoUtilities.organizationUrnPrefix.endIndex).description : nil,
            "scope": scopes?.joined(separator: " "),
        ]

        return try await LogtoRequest.post(
            useSession: session,
            endpoint: tokenEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8)
        )
    }

    // MARK: User Info

    struct UserInfoResponse: UserInfoProtocol {
        public let sub: String
        public let name: String?
        public let picture: String?
        public let username: String?
        public let email: String?
        public let emailVerified: Bool?
        public let phoneNumber: String?
        public let phoneNumberVerified: Bool?
        public let roles: [String]?
        public let organizations: [String]?
        public let organizationRoles: [String]?
        public let customData: JsonObject?
        public let identities: JsonObject?
    }

    static func fetchUserInfo(
        useSession session: NetworkSession = URLSession.shared,
        userInfoEndpoint: String,
        accessToken: String
    ) async throws -> UserInfoResponse {
        try await LogtoRequest.get(
            useSession: session,
            endpoint: userInfoEndpoint,
            headers: ["Authorization": "Bearer \(accessToken)"]
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
