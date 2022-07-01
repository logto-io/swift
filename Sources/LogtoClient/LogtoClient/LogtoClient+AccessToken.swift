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
        // Force pass in offline_access as scope to avoid ID Token being returned
        let scopes = resource.map { _ in [LogtoUtilities.Scope.offlineAccess.rawValue] } ?? []
            
        let key = buildAccessTokenKey(for: resource, scopes: scopes)
        let oidcConfig = try await fetchOidcConfig()

        do {
            let response = try await LogtoCore.fetchToken(
                useSession: networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.appId,
                resource: resource,
                scopes: scopes
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
     Get an Access Token for the given resource. If resource is `nil`, return the Access Token for user endpoint.

     If the cached Access Token has expired, this function will try to use `refreshToken` to fetch a new Access Token from the OIDC provider.

     - Parameters:
        - resource: The resource indicator.
     - Throws: An error if failed to get a valid Access Token.
     - Returns: Access Token in string.
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
