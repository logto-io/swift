//
//  LogtoClient+AccessToken.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

public extension LogtoClient {
    func buildAccessTokenKey(for resource: String?, scopes: [String]) -> String {
        "\(scopes.sorted().joined(separator: " "))@\(resource ?? "")"
    }

    func getAccessToken(for resource: String?) async throws -> String {
        let key = buildAccessTokenKey(for: resource, scopes: [])

        // Cached access token is still valid
        if let accessToken = accessTokenMap[key], Date().timeIntervalSince1970 < accessToken.expiresAt {
            return accessToken.token
        }

        // Use refresh token to fetch a new access token
        guard let refreshToken = refreshToken else {
            throw Errors.AccessToken(type: .noRefreshTokenFound, innerError: nil)
        }

        let oidcConfig = try await fetchOidcConfig()

        return try await withCheckedThrowingContinuation { continuation in
            LogtoCore.fetchToken(
                useSession: self.networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: self.logtoConfig.clientId,
                resource: resource,
                scopes: []
            ) { response, error in
                guard let response = response else {
                    continuation
                        .resume(throwing: Errors
                            .AccessToken(type: .unableToFetchTokenByRefreshToken, innerError: error))
                    return
                }

                let accessToken = AccessToken(
                    token: response.accessToken,
                    scope: response.scope,
                    expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
                )

                self.accessTokenMap[key] = accessToken
                self.refreshToken = response.refreshToken

                response.idToken.map {
                    self.idToken = $0
                }

                continuation.resume(returning: accessToken.token)
            }
        }
    }
}
