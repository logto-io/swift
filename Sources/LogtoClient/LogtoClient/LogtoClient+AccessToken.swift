//
//  LogtoClient+AccessToken.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

extension LogtoClient {
    func buildAccessTokenKey(for resource: String?, scopes: [String]) -> String {
        "\(scopes.sorted().joined(separator: " "))@\(resource ?? "")"
    }

    func getAccessToken(by refreshToken: String, for resource: String?) async throws -> String {
        let key = buildAccessTokenKey(for: resource, scopes: [])
        let oidcConfig = try await fetchOidcConfig()

        do {
            let response = try await LogtoCore.fetchToken(
                useSession: networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.appId,
                resource: resource,
                scopes: []
            )

            let accessToken = AccessToken(
                token: response.accessToken,
                scope: response.scope,
                expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
            )

            accessTokenMap[key] = accessToken
            self.refreshToken = response.refreshToken

            response.idToken.map {
                self.idToken = $0
            }

            return accessToken.token
        } catch {
            throw LogtoClientErrors
                .AccessToken(type: .unableToFetchTokenByRefreshToken, innerError: error)
        }
    }

    /**
     Get access token for the given resrouce. If resource is `nil`, return the access token for user endpoint.

     If the cached access token has expired, this function will try to use `refreshToken` to fetch a new access token from the OIDC provider.

     - Parameters:
        - resource: The resource indicator.
     - Throws: An error if failed to get a valid access token.
     - Returns: Access token in string.
     */
    @MainActor public func getAccessToken(for resource: String?) async throws -> String {
        let key = buildAccessTokenKey(for: resource, scopes: [])

        // Cached access token is still valid
        if let accessToken = accessTokenMap[key], Date().timeIntervalSince1970 < accessToken.expiresAt {
            return accessToken.token
        }

        // Check existing task
        if let task = getAccessTokenTaskMap[key] {
            return try await task.value
        }

        // Use refresh token to fetch a new access token
        guard let refreshToken = refreshToken else {
            throw LogtoClientErrors.AccessToken(type: .noRefreshTokenFound, innerError: nil)
        }

        let task = Task {
            try await self.getAccessToken(by: refreshToken, for: resource)
        }
        getAccessTokenTaskMap.updateValue(task, forKey: key)

        let token = try await task.value
        getAccessTokenTaskMap.removeValue(forKey: key)

        return token
    }
}
