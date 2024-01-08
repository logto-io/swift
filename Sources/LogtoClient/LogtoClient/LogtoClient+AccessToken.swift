//
//  LogtoClient+AccessToken.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

extension LogtoClient {
    func buildAccessTokenKey(for resource: String?) -> String {
        resource ?? "@"
    }

    func getAccessToken(by refreshToken: String, for resource: String?) async throws -> String {
        let key = buildAccessTokenKey(for: resource)
        let oidcConfig = try await fetchOidcConfig()

        do {
            let response = try await LogtoCore.fetchToken(
                useSession: networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.appId,
                resource: resource,
                scopes: nil
            )

            let accessToken = AccessToken(
                token: response.accessToken,
                scope: response.scope,
                expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
            )

            accessTokenMap[key] = accessToken

            response.refreshToken.map {
                self.refreshToken = $0
            }

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
        let key = buildAccessTokenKey(for: resource)

        // Cached access token is still valid
        if let accessToken = accessTokenMap[key], Date().timeIntervalSince1970 < accessToken.expiresAt {
            return accessToken.token
        }

        // Use refresh token to fetch a new access token
        guard let refreshToken = refreshToken else {
            throw LogtoClientErrors.AccessToken(type: .noRefreshTokenFound, innerError: nil)
        }

        let token = try await getAccessToken(by: refreshToken, for: resource)

        return token
    }

    /**
     Get an Access Token for the given organization ID. Scope `UserScope.organizations` is required in the config to use organization-related
     methods.

     If the cached Access Token has expired, this function will try to use `refreshToken` to fetch a new Access Token from the OIDC provider.

     - Parameters:
        - forId: The ID of the organization that the access token is granted for.
     - Throws: An error if failed to get a valid Access Token.
     - Returns: Access Token in string.
     */
    @MainActor public func getOrganizationToken(forId id: String) async throws -> String {
        try await getAccessToken(for: LogtoUtilities.buildOrganizationUrn(forId: id))
    }
}
