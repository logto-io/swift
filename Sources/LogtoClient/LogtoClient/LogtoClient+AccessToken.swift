//
//  LogtoClient+AccessToken.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

public extension LogtoClient {
    internal func buildAccessTokenKey(for resource: String?, in organizationId: String?) -> String {
        guard let organizationId = organizationId else {
            return resource ?? "@"
        }

        return (resource ?? "@") + "#" + organizationId
    }

    internal func getAccessToken(by refreshToken: String, for resource: String?,
                                 in organizationId: String?) async throws -> String
    {
        let key = buildAccessTokenKey(for: resource, in: organizationId)
        let oidcConfig = try await fetchOidcConfig()

        do {
            let response = try await LogtoCore.fetchToken(
                useSession: networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.appId,
                resource: resource,
                scopes: nil,
                organizationId: organizationId
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
     Get an Access Token for the given resource.
     - If both `resource` and `organizationId` are `nil`, return the Access Token for user endpoint.
     - If `resource` is provided but `organizationId` is `nil`, return the Access Token for the given resource.
     - If both `resource` and `organizationId` are provided, return the Access Token for the given resource in the given organization.
     - If `resource` is `nil` but `organizationId` is provided, an error will be thrown. Use `getOrganizationToken(forId:)` instead.

     If the cached Access Token has expired, this function will try to use `refreshToken` to fetch a new Access Token from the OIDC provider.

     - Parameters:
        - for: The resource indicator.
        - organizationId: The ID of the organization that the access token is granted for.
     - Throws: An error if failed to get a valid Access Token.
     - Returns: Access Token in string.
     */
    @MainActor func getAccessToken(for resource: String?, organizationId: String? = nil) async throws -> String {
        let key = buildAccessTokenKey(for: resource, in: organizationId)

        // Cached access token is still valid
        if let accessToken = accessTokenMap[key], Date().timeIntervalSince1970 < accessToken.expiresAt {
            return accessToken.token
        }

        // Use refresh token to fetch a new access token
        guard let refreshToken = refreshToken else {
            throw LogtoClientErrors.AccessToken(type: .noRefreshTokenFound, innerError: nil)
        }

        return try await getAccessToken(by: refreshToken, for: resource, in: organizationId)
    }

    /**
     Get structured Access Token claims WITHOUT validation. See `getAccessToken(for:organizationId:)` for more details.

     - Parameters:
        - for: The resource indicator.
        - organizationId: The ID of the organization that the access token is granted for.
     - Throws: An error if failed to get a valid Access Token or decode token failed.
     - Returns: A dictionary of Access Token claims.
     */
    @MainActor func getAccessTokenClaims(for resource: String?,
                                         organizationId: String? = nil) async throws -> JsonObject
    {
        let accessToken = try await getAccessToken(for: resource, organizationId: organizationId)
        return try LogtoUtilities.decodeAccessToken(accessToken)
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
    @MainActor func getOrganizationToken(forId id: String) async throws -> String {
        try await getAccessToken(for: LogtoUtilities.buildOrganizationUrn(forId: id))
    }

    /**
     Get structured Access Token claims for the given organization ID WITHOUT validation. See `getOrganizationToken(forId:)` for more details.

     - Parameters:
        - forId: The ID of the organization that the access token is granted for.
     - Throws: An error if failed to get a valid Access Token or decode token failed.
     - Returns: A dictionary of Access Token claims.
     */
    @MainActor func getOrganizationTokenClaims(forId id: String) async throws -> JsonObject {
        let accessToken = try await getOrganizationToken(forId: id)
        return try LogtoUtilities.decodeAccessToken(accessToken)
    }
}
