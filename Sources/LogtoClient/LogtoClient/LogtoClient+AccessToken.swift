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

    func getAccessToken(
        for resource: String?,
        completion: @escaping Completion<String, Errors.AccessToken>
    ) {
        let key = buildAccessTokenKey(for: resource, scopes: [])

        // Cached access token is still valid
        if let accessToken = accessTokenMap[key], Date().timeIntervalSince1970 < accessToken.expiresAt {
            completion(accessToken.token, nil)
            return
        }

        // Use refresh token to fetch a new access token
        guard let refreshToken = refreshToken else {
            completion(nil, Errors.AccessToken(type: .noRefreshTokenFound, innerError: nil))
            return
        }

        fetchOidcConfig { oidcConfig, error in
            guard let oidcConfig = oidcConfig else {
                completion(nil, Errors.AccessToken(type: .unableToFetchOidcConfig, innerError: error))
                return
            }

            LogtoCore.fetchToken(
                useSession: self.networkSession,
                byRefreshToken: refreshToken,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: self.logtoConfig.clientId,
                resource: resource,
                scopes: []
            ) { response, error in
                guard let response = response else {
                    completion(nil, Errors.AccessToken(type: .unableToFetchTokenByRefreshToken, innerError: error))
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

                completion(accessToken.token, nil)
            }
        }
    }
}
